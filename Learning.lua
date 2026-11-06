-- Account-wide evidence learned from loot that the client actually displays.
-- Unlike reference tables, these are observed items. Boss attribution is
-- inferred from published item tables or a successful encounter-end event;
-- unknown boss drops are kept in their own bucket instead of fabricated.
local _, FL = ...
local Learning = {}
FL.Learning = Learning
local UNKNOWN_BOSS = -99000
local recent
local pending = {}
local f = CreateFrame("Frame")
local function plain(value)
    return value ~= nil and (not issecretvalue or not issecretvalue(value))
end
-- CHAT_MSG_LOOT is broadcast for group members as well as the player.
-- Only self-loot is evidence that this character received an item.
-- The localized Blizzard templates avoid English-only player-name parsing.
local function isOwnLoot(message)
    if not plain(message) or type(message) ~= "string" then return false end
    for _, key in ipairs({"LOOT_ITEM_SELF", "LOOT_ITEM_SELF_MULTIPLE",
                           "LOOT_ITEM_PUSHED_SELF", "LOOT_ITEM_PUSHED_SELF_MULTIPLE"}) do
        local template = _G[key]
        if plain(template) and type(template) == "string" then
            local pattern = "^" .. template:gsub("([%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
                :gsub("%%%%", "\001")
                :gsub("%%[%d%.]*%$?s", ".+")
                :gsub("%%[%d%.]*%$?d", "%%d+")
                :gsub("\001", "%%%%") .. "$"
            local ok, matched = pcall(string.match, message, pattern)
            if ok and matched then return true end
        end
    end
    return false
end
local function instance()
    if type(GetInstanceInfo) ~= "function" then return end
    local ok, name, kind = pcall(GetInstanceInfo)
    if not ok or not plain(name) or type(name) ~= "string"
        or (kind ~= "party" and kind ~= "raid") then return end
    return FL.NormalizeName(name), name
end
local function getDB()
    if not ForeverLootDB then return end
    ForeverLootDB.observed = ForeverLootDB.observed or {}
    return ForeverLootDB.observed
end
local function itemsFor(key, boss)
    local db=getDB()
    local data=db and db[key]
    return data and data.bosses and data.bosses[tostring(boss)] or nil
end
function Learning:GetLoot(key, boss)
    local bucket=itemsFor(key,boss)
    local result={}
    for _, item in pairs(bucket and bucket.items or {}) do
        result[#result+1]={itemID=item.itemID,name=item.name}
    end
    table.sort(result,function(a,b) return a.itemID < b.itemID end)
    return result
end
function Learning:GetEncounters(key)
    local db=getDB()
    local data=db and db[key]
    local list={}
    for id,boss in pairs(data and data.bosses or {}) do
        list[#list+1]={encounterID=tonumber(id),name=boss.name}
    end
    table.sort(list,function(a,b) return a.encounterID < b.encounterID end)
    return list
end
-- A reference item may be shared by multiple bosses. Never assign an
-- observed drop to whichever boss pairs() happens to enumerate first.
-- Prefer a recent successful encounter only when it is a documented source.
local function seededBoss(key,item,atTime)
    local static=FL.Static
    if not static then return end
    local sources={}
    for _,data in ipairs({static.verifiedLoot,static.foreverBetaLoot,static.classicLoot}) do
        for bossID,entries in pairs((data and data[key]) or {}) do
            for _,candidate in ipairs(entries) do
                if tonumber(candidate.itemID)==item then
                    sources[tostring(bossID)]=bossID
                    break
                end
            end
        end
    end
    local only
    local count=0
    for _,bossID in pairs(sources) do count=count+1; only=bossID end
    if count==1 then return only end
    if count>1 and recent and recent.key==key and recent.success
        and atTime-recent.at>=0 and atTime-recent.at<120 then
        return sources[tostring(recent.id)]
    end
    -- Ambiguous shared reference drops remain unknown, not falsely attributed.
end
local function bossName(key,id)
    for _,b in ipairs(FL.Static.bosses[key] or {}) do
        if b.encounterID == id then return b.name end
    end
    if recent and recent.key==key and recent.id==id then return recent.name end
    return id==UNKNOWN_BOSS and "Observed drops (boss unknown)" or ("Boss "..id)
end
local function equipment(itemID)
    local name, link, quality
    if C_Item and type(C_Item.GetItemInfo)=="function" then
        local ok,a,b,c=pcall(C_Item.GetItemInfo,itemID)
        if ok then name,link,quality=a,b,c end
    elseif type(GetItemInfo)=="function" then
        local ok,a,b,c=pcall(GetItemInfo,itemID)
        if ok then name,link,quality=a,b,c end
    end
    local slot
    if C_Item and type(C_Item.GetItemInfoInstant)=="function" then
        local ok, _,_,_, loc=pcall(C_Item.GetItemInfoInstant,itemID)
        if ok then slot=loc end
    end
    if not plain(slot) or slot=="" then return end
    if not plain(quality) or type(quality)~="number" then return "pending" end
    if quality<2 then return end
    return plain(name) and name or ("Item "..itemID)
end
local function record(itemID, key, instanceName, atTime)
    if not getDB() or not key then return end
    local name=equipment(itemID)
    if name=="pending" then
        pending[itemID]={key=key,instanceName=instanceName,atTime=atTime}
        if C_Item and type(C_Item.RequestLoadItemDataByID)=="function" then
            pcall(C_Item.RequestLoadItemDataByID,itemID)
        end
        return
    end
    if not name then return end
    local id=seededBoss(key,itemID,atTime)
    -- A recent kill is useful for unreferenced items, but cannot resolve
    -- a shared reference drop unless that boss is among its known sources.
    if not id and recent and recent.key==key and recent.success and
        atTime-recent.at>=0 and atTime-recent.at<120 then
        local hasReference=false
        for _,data in ipairs({FL.Static.verifiedLoot,FL.Static.foreverBetaLoot,FL.Static.classicLoot}) do
            for _,entries in pairs((data and data[key]) or {}) do
                for _,candidate in ipairs(entries) do
                    if tonumber(candidate.itemID)==itemID then hasReference=true;break end
                end
                if hasReference then break end
            end
            if hasReference then break end
        end
        if not hasReference then id=recent.id end
    end
    id=id or UNKNOWN_BOSS
    local db=getDB()
    local entry=db[key] or {instanceName=instanceName,bosses={}}
    db[key]=entry
    entry.bosses=entry.bosses or {}
    local tag=tostring(id)
    local boss=entry.bosses[tag] or {name=bossName(key,id),items={}}
    entry.bosses[tag]=boss
    boss.items=boss.items or {}
    local saved=boss.items[tostring(itemID)] or {itemID=itemID,name=name,count=0}
    saved.count=saved.count+1
    saved.lastSeen=time()
    saved.name=name
    boss.items[tostring(itemID)]=saved
end
function Learning:Counts()
    local zones,items=0,0
    for _,db in pairs(getDB() or {}) do
        zones=zones+1
        for _,boss in pairs(db.bosses or {}) do
            for _ in pairs(boss.items or {}) do items=items+1 end
        end
    end
    return zones,items
end
f:RegisterEvent("ENCOUNTER_END")
f:RegisterEvent("CHAT_MSG_LOOT")
f:RegisterEvent("GET_ITEM_INFO_RECEIVED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent",function(_,event,...)
    if event=="PLAYER_ENTERING_WORLD" then recent=nil;return end
    if event=="ENCOUNTER_END" then
        local id,name,_,_,success=...
        local key=instance()
        if key and plain(id) and type(id)=="number" and plain(name) and plain(success) then
            recent={id=id,name=name,success=success==1,key=key,at=GetTime()}
        end
        return
    end
    if event=="CHAT_MSG_LOOT" then
        local message=...
        if not isOwnLoot(message) then return end
        local id=tonumber(message:match("|Hitem:(%d+)"))
        if not id then return end
        local key,instanceName=instance()
        if key then record(id,key,instanceName,GetTime()) end
        return
    end
    if event=="GET_ITEM_INFO_RECEIVED" then
        local id=...
        if type(id)=="number" and pending[id] then
            local p=pending[id]
            pending[id]=nil
            record(id,p.key,p.instanceName,p.atTime)
        end
    end
end)
