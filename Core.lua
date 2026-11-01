local ADDON_NAME, FL = ...

local DEFAULTS = {
    filterKind = "dungeon",
}

local function applyDefaults(db, defaults)
    for key, value in pairs(defaults) do
        if db[key] == nil then db[key] = value end
    end
end

local function msg(text)
    print("|cffd8b45bForever Loot:|r " .. tostring(text))
end

local function showHelp()
    msg("/fl — open/close Forever Loot")
    msg("/fl scan — rescan the Encounter Journal")
    msg("/fl status — show detected instance count and API version")
    msg("/fl api — show integration API version")
end

local function slash(input)
    input = tostring(input or "")
    local command = input:match("^%s*(%S*)")
    command = string.lower(command or "")

    if command == "" or command == "open" then
        FL.UI:Toggle()
    elseif command == "scan" or command == "rescan" then
        local instances, err = FL:Rescan()
        if FL.UI and FL.UI.frame and FL.UI.frame:IsShown() then FL.UI:RefreshAll() end
        if err then
            msg(err)
        else
            msg(string.format("Found %d Forever instance%s.", #instances, #instances == 1 and "" or "s"))
        end
    elseif command == "status" then
        local instances = FL:GetInstances()
        msg(string.format("v%s — API v%d — %d detected instance%s.", FL.VERSION, FL.API_VERSION, #instances, #instances == 1 and "" or "s"))
        if FL.scanError then msg(FL.scanError) end
    elseif command == "api" then
        msg("Integration API v" .. tostring(FL.API_VERSION) .. " available at _G.ForeverLoot.")
        msg("ForeverDungeon hook: ForeverLoot:GetLootForMapID(instanceMapID)")
    else
        showHelp()
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
pcall(frame.RegisterEvent, frame, "EJ_LOOT_DATA_RECIEVED")
pcall(frame.RegisterEvent, frame, "GET_ITEM_INFO_RECEIVED")

local refreshQueued = false
local function queueRefresh()
    if refreshQueued then return end
    refreshQueued = true
    C_Timer.After(0.15, function()
        refreshQueued = false
        if FL.UI and FL.UI.frame and FL.UI.frame:IsShown() and FL.UI.selectedInstance then
            FL.UI:RefreshLoot()
        end
    end)
end

frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        ForeverLootDB = ForeverLootDB or {}
        applyDefaults(ForeverLootDB, DEFAULTS)
        FL.UI:Create()
        FL.UI.filterKind = ForeverLootDB.filterKind or "dungeon"
        SLASH_FOREVERLOOT1 = "/fl"
        SLASH_FOREVERLOOT2 = "/foreverloot"
        SlashCmdList.FOREVERLOOT = slash
    elseif event == "PLAYER_LOGIN" then
        local instances, err = FL:Rescan()
        if err then
            msg("v" .. FL.VERSION .. " loaded. " .. err)
            msg("Use /fl scan after launch if the journal is still loading.")
        else
            msg(string.format("v%s loaded — %d Forever instance%s detected. /fl to browse.", FL.VERSION, #instances, #instances == 1 and "" or "s"))
        end
    elseif event == "EJ_LOOT_DATA_RECIEVED" or event == "GET_ITEM_INFO_RECEIVED" then
        queueRefresh()
    end
end)
