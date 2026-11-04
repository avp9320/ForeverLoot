-- Offline fallback for WoW: Forever, which has no built-in Encounter Journal
-- at launch. Classic drops are provisional, NOT verified Forever drops.
-- Where the release client supplies trustworthy newer data it takes priority.
-- Sources:
--  * Classic Ragefire loot: https://warcraft.wiki.gg/wiki/Ragefire_Chasm_(Classic)
--  * Classic Deadmines loot: https://classic.warcraftdb.com/data/instance/1/loot
--  * Forever instance/boss IDs: https://wow-forever.gg/dungeons/
-- As new Forever drops are verified, populate verifiedLoot below. Do not
-- infer that missing items never drop; this starter catalog is intentionally
-- incomplete and must never yield an authoritative "no upgrades" conclusion.

local _, FL = ...
local Static = {}
FL.Static = Static

local mapIDs = {
    ["ragefire chasm"] = 389,
    ["the deadmines"] = 36,
    ["the hall of thanes"] = 3065,
    ["ruins of lordaeron"] = 2999,
}

Static.bosses = {
    ["ragefire chasm"] = {
        { name = "Oggleflint", encounterID = -55001 },
        { name = "Taragaman the Hungerer", encounterID = -55002 },
        { name = "Jergosh the Invoker", encounterID = -55003 },
        { name = "Bazzalan", encounterID = -55004 },
    },
    ["the deadmines"] = {
        { name = "Rhahk'Zor", encounterID = 2741 },
        { name = "Sneed", encounterID = 2742 },
        { name = "Miner Johnson", encounterID = 3676 },
        { name = "Gilnid", encounterID = 2743 },
        { name = "Captain Greenskin", encounterID = 2744 },
        { name = "Mr. Smite", encounterID = 2745 },
        { name = "Cookie", encounterID = 2746 },
        { name = "Edwin VanCleef", encounterID = 2747 },
    },
    ["the hall of thanes"] = {
        { name = "Faldrim Anvilmar", encounterID = 3493 },
        { name = "Plunder", encounterID = 3494 },
        { name = "Infurnus", encounterID = 3495 },
        { name = "Durgen Dirgehammer", encounterID = 3496 },
    },
}

-- Confirmed Forever drops will override these by itemID and encounter ID.
-- The client hides many source/loot-table details until encountered.
Static.verifiedLoot = {}

-- Small sourced launch seed; the suite watch expands this as information
-- arrives. These item/source pairings are CLASSIC, not guaranteed in Forever.
Static.classicLoot = {
    ["ragefire chasm"] = {
        [-55002] = {
            { itemID = 14145, name = "Cursed Felblade" },
            { itemID = 14148, name = "Crystalline Cuffs" },
            { itemID = 14149, name = "Subterranean Cape" },
        },
        [-55003] = {
            { itemID = 14147, name = "Cavedweller Bracers" },
            { itemID = 14150, name = "Robe of Evocation" },
            { itemID = 14151, name = "Chanting Blade" },
        },
    },
    ["the deadmines"] = {
        [2744] = { { itemID = 5201, name = "Emberstone Staff" } },
        [2747] = { { itemID = 5191, name = "Cruel Barb" } },
    },
}

function Static:InstanceKey(instance)
    return FL.NormalizeName(instance and (instance.displayName or instance.name))
end

function Static:GetInstances()
    local list = {}
    for index, meta in ipairs(FL.KNOWN_INSTANCES or {}) do
        local key = FL.NormalizeName(meta.name)
        list[#list + 1] = {
            journalInstanceID = -10000 - index,
            displayName = meta.name,
            name = meta.name,
            isRaid = meta.kind == "raid",
            isNew = meta.isNew == true,
            minLevel = meta.minLevel,
            maxLevel = meta.maxLevel,
            mapID = mapIDs[key],
            isStatic = true,
            dataSource = "classic-fallback",
            lootCoverage = "partial",
        }
    end
    return list
end

function Static:GetEncounters(instance)
    local list = self.bosses[self:InstanceKey(instance)] or {}
    return list
end

function Static:GetLoot(instance, encounterID)
    local key = self:InstanceKey(instance)
    local classic = self.classicLoot[key] or {}
    local verified = self.verifiedLoot[key] or {}
    local loot, seen = {}, {}
    local function append(entries, source)
        for _, item in ipairs(entries or {}) do
            if item.itemID and not seen[item.itemID] then
                seen[item.itemID] = true
                local copy = {}
                for k, v in pairs(item) do copy[k] = v end
                copy.source = source
                copy.link = "item:" .. tostring(item.itemID)
                if C_Item and type(C_Item.GetItemInfo) == "function" then
                    local ok, name, link, _, itemLevel, _, itemType, itemSubType,
                        _, equipLoc, icon = pcall(C_Item.GetItemInfo, copy.link)
                    if ok then
                        copy.name = name or copy.name
                        copy.link = link or copy.link
                        copy.itemLevel = itemLevel
                        copy.itemType = itemType
                        copy.itemSubType = itemSubType
                        copy.slot = equipLoc
                        copy.icon = icon
                    end
                end
                loot[#loot + 1] = copy
            end
        end
    end
    local function forBoss(id)
        -- Verified Forever entries override the provisional Classic record
        -- when the same item ID appears in both.
        append(verified[id], "forever-verified")
        append(classic[id], "classic-baseline")
    end
    if encounterID then
        forBoss(encounterID)
    else
        for _, boss in ipairs(self:GetEncounters(instance)) do forBoss(boss.encounterID) end
    end
    return loot
end
