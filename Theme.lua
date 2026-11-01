-- ForeverLoot visual theme
-- Full browsing windows use Blizzard dialog assets, matching ForeverDungeon and ForeverTalentGuide.

local function ApplyForeverLootTheme()
    local frame = _G.ForeverLootFrame
    if not frame then return false end

    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 24,
            insets = { left = 7, right = 7, top = 7, bottom = 7 },
        })
        frame:SetBackdropColor(1, 1, 1, 1)
        frame:SetBackdropBorderColor(1, 1, 1, 1)
    end

    frame.ForeverStockTheme = true
    return true
end

local themeEvents = CreateFrame("Frame")
themeEvents:RegisterEvent("ADDON_LOADED")
themeEvents:RegisterEvent("PLAYER_LOGIN")
themeEvents:SetScript("OnEvent", function(_, event, addonName)
    if event == "ADDON_LOADED" and addonName ~= "ForeverLoot" then return end

    if C_Timer and C_Timer.After then
        C_Timer.After(0, ApplyForeverLootTheme)
    else
        ApplyForeverLootTheme()
    end
end)
