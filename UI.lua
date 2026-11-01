local ADDON_NAME, FL = ...

local UI = {}
FL.UI = UI

local ROW_H = 24
local LOOT_ROW_H = 38

local function makeBackdrop(frame)
    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 14,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        frame:SetBackdropColor(0.035, 0.035, 0.045, 0.97)
        frame:SetBackdropBorderColor(0.28, 0.28, 0.32, 1)
    end
end

local function createText(parent, size, justify)
    local template = (size and size >= 16) and "GameFontNormalLarge" or "GameFontNormal"
    local fs = parent:CreateFontString(nil, "OVERLAY", template)
    fs:SetJustifyH(justify or "LEFT")
    return fs
end

local function wipeChildren(frame)
    if not frame._rows then frame._rows = {}; return end
    for _, row in ipairs(frame._rows) do row:Hide(); row:SetParent(nil) end
    wipe(frame._rows)
end

local function createScrollColumn(parent, width, leftOffset)
    local outer = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    outer:SetPoint("TOPLEFT", leftOffset, -88)
    outer:SetPoint("BOTTOMLEFT", leftOffset, 34)
    outer:SetWidth(width)
    makeBackdrop(outer)
    outer:SetBackdropColor(0.02, 0.02, 0.025, 0.75)

    local scroll = CreateFrame("ScrollFrame", nil, outer, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 6, -6)
    scroll:SetPoint("BOTTOMRIGHT", -27, 6)

    local child = CreateFrame("Frame", nil, scroll)
    child:SetWidth(math.max(10, width - 38))
    child:SetHeight(1)
    scroll:SetScrollChild(child)
    child._rows = {}
    return outer, scroll, child
end

local function addRowButton(child, index, height)
    local row = CreateFrame("Button", nil, child)
    row:SetHeight(height)
    row:SetPoint("TOPLEFT", 0, -((index - 1) * height))
    row:SetPoint("RIGHT", child, "RIGHT", 0, 0)

    row.highlight = row:CreateTexture(nil, "BACKGROUND")
    row.highlight:SetAllPoints()
    row.highlight:SetColorTexture(1, 1, 1, 0.06)
    row.highlight:Hide()

    row:SetScript("OnEnter", function(self) self.highlight:Show() end)
    row:SetScript("OnLeave", function(self) self.highlight:Hide(); GameTooltip:Hide() end)
    child._rows[#child._rows + 1] = row
    return row
end

function UI:Create()
    if self.frame then return self.frame end

    local frame = CreateFrame("Frame", "ForeverLootFrame", UIParent, "BackdropTemplate")
    frame:SetSize(780, 520)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    makeBackdrop(frame)
    frame:Hide()
    self.frame = frame

    local title = createText(frame, 18, "LEFT")
    title:SetPoint("TOPLEFT", 16, -14)
    title:SetText("|cffd8b45bForever Loot|r")

    local subtitle = createText(frame, 12, "LEFT")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -3)
    subtitle:SetText("Dungeon and raid loot without the AtlasLoot bloat.")
    subtitle:SetTextColor(0.72, 0.72, 0.76)

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)

    local dungeonBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    dungeonBtn:SetSize(86, 24)
    dungeonBtn:SetPoint("TOPLEFT", 16, -56)
    dungeonBtn:SetText("Dungeons")

    local raidBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    raidBtn:SetSize(70, 24)
    raidBtn:SetPoint("LEFT", dungeonBtn, "RIGHT", 6, 0)
    raidBtn:SetText("Raids")

    local allBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    allBtn:SetSize(58, 24)
    allBtn:SetPoint("LEFT", raidBtn, "RIGHT", 6, 0)
    allBtn:SetText("All")

    local rescanBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    rescanBtn:SetSize(74, 24)
    rescanBtn:SetPoint("TOPRIGHT", -16, -56)
    rescanBtn:SetText("Rescan")

    local search = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    search:SetSize(210, 24)
    search:SetPoint("RIGHT", rescanBtn, "LEFT", -10, 0)
    search:SetAutoFocus(false)
    search:SetMaxLetters(60)
    self.search = search

    local searchLabel = createText(frame, 12, "RIGHT")
    searchLabel:SetPoint("RIGHT", search, "LEFT", -7, 0)
    searchLabel:SetText("Filter:")
    searchLabel:SetTextColor(0.75, 0.75, 0.78)

    self.instanceOuter, self.instanceScroll, self.instanceChild = createScrollColumn(frame, 220, 16)
    self.bossOuter, self.bossScroll, self.bossChild = createScrollColumn(frame, 190, 244)
    self.lootOuter, self.lootScroll, self.lootChild = createScrollColumn(frame, 320, 442)

    local instanceHeader = createText(frame, 12, "LEFT")
    instanceHeader:SetPoint("BOTTOMLEFT", self.instanceOuter, "TOPLEFT", 4, 4)
    instanceHeader:SetText("Instances")

    local bossHeader = createText(frame, 12, "LEFT")
    bossHeader:SetPoint("BOTTOMLEFT", self.bossOuter, "TOPLEFT", 4, 4)
    bossHeader:SetText("Bosses")

    local lootHeader = createText(frame, 12, "LEFT")
    lootHeader:SetPoint("BOTTOMLEFT", self.lootOuter, "TOPLEFT", 4, 4)
    lootHeader:SetText("Loot")

    local status = createText(frame, 11, "LEFT")
    status:SetPoint("BOTTOMLEFT", 16, 12)
    status:SetPoint("RIGHT", frame, "RIGHT", -16, 0)
    status:SetTextColor(0.62, 0.62, 0.66)
    status:SetText("Ready.")
    self.status = status

    dungeonBtn:SetScript("OnClick", function()
        UI.filterKind = "dungeon"
        if ForeverLootDB then ForeverLootDB.filterKind = UI.filterKind end
        UI:RefreshInstances()
    end)
    raidBtn:SetScript("OnClick", function()
        UI.filterKind = "raid"
        if ForeverLootDB then ForeverLootDB.filterKind = UI.filterKind end
        UI:RefreshInstances()
    end)
    allBtn:SetScript("OnClick", function()
        UI.filterKind = "all"
        if ForeverLootDB then ForeverLootDB.filterKind = UI.filterKind end
        UI:RefreshInstances()
    end)
    rescanBtn:SetScript("OnClick", function()
        UI.status:SetText("Rescanning Encounter Journal...")
        FL:Rescan()
        UI.selectedInstance = nil
        UI.selectedEncounterID = nil
        UI:RefreshAll()
    end)

    search:SetScript("OnTextChanged", function() UI:RefreshInstances(); UI:RefreshLoot() end)
    search:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    search:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

    self.filterKind = "dungeon"
    return frame
end

function UI:GetSearch()
    return FL.NormalizeName(self.search and self.search:GetText() or "")
end

function UI:RefreshInstances()
    self:Create()
    wipeChildren(self.instanceChild)
    local query = self:GetSearch()
    local list = {}

    for _, instance in ipairs(FL:GetInstances()) do
        local kindOkay = self.filterKind == "all"
            or (self.filterKind == "raid" and instance.isRaid)
            or (self.filterKind == "dungeon" and not instance.isRaid)
        local name = FL.NormalizeName(instance.displayName or instance.name)
        local queryOkay = query == "" or name:find(query, 1, true)
        if kindOkay and queryOkay then list[#list + 1] = instance end
    end

    for i, instance in ipairs(list) do
        local row = addRowButton(self.instanceChild, i, ROW_H)
        local text = createText(row, 12, "LEFT")
        text:SetPoint("LEFT", 6, 0)
        text:SetPoint("RIGHT", -6, 0)
        local label = instance.displayName or instance.name or ("Instance " .. tostring(instance.journalInstanceID))
        if instance.isNew then label = "|cff67d7ff" .. label .. "|r"
        elseif instance.isRaid then label = "|cffff9b5c" .. label .. "|r" end
        text:SetText(label)
        row:SetScript("OnClick", function()
            UI.selectedInstance = instance
            UI.selectedEncounterID = nil
            UI:RefreshBosses()
            UI:RefreshLoot()
        end)
    end

    self.instanceChild:SetHeight(math.max(1, #list * ROW_H))
    self.status:SetText(string.format("%d instance%s shown.", #list, #list == 1 and "" or "s"))
end

function UI:RefreshBosses()
    wipeChildren(self.bossChild)
    local instance = self.selectedInstance
    if not instance then self.bossChild:SetHeight(1); return end

    local encounters = FL:GetEncounters(instance)
    local allRow = addRowButton(self.bossChild, 1, ROW_H)
    local allText = createText(allRow, 12, "LEFT")
    allText:SetPoint("LEFT", 6, 0)
    allText:SetText("|cffffffffAll Bosses|r")
    allRow:SetScript("OnClick", function() UI.selectedEncounterID = nil; UI:RefreshLoot() end)

    for i, encounter in ipairs(encounters) do
        local row = addRowButton(self.bossChild, i + 1, ROW_H)
        local text = createText(row, 12, "LEFT")
        text:SetPoint("LEFT", 6, 0)
        text:SetPoint("RIGHT", -6, 0)
        text:SetText(encounter.name or ("Boss " .. i))
        row:SetScript("OnClick", function() UI.selectedEncounterID = encounter.encounterID; UI:RefreshLoot() end)
        row:SetScript("OnEnter", function(self)
            self.highlight:Show()
            if encounter.description and encounter.description ~= "" then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(encounter.name or "Boss")
                GameTooltip:AddLine(encounter.description, 1, 1, 1, true)
                GameTooltip:Show()
            end
        end)
        row:SetScript("OnLeave", function(self) self.highlight:Hide(); GameTooltip:Hide() end)
    end
    self.bossChild:SetHeight(math.max(1, (#encounters + 1) * ROW_H))
end

local function itemMatchesQuery(item, query)
    if query == "" then return true end
    local hay = table.concat({FL.NormalizeName(item.name), FL.NormalizeName(item.slot), FL.NormalizeName(item.armorType), FL.NormalizeName(item.itemType), FL.NormalizeName(item.itemSubType)}, " ")
    return hay:find(query, 1, true) ~= nil
end

function UI:RefreshLoot()
    wipeChildren(self.lootChild)
    local instance = self.selectedInstance
    if not instance then self.lootChild:SetHeight(1); return end

    local loot = FL:GetInstanceLoot(instance, self.selectedEncounterID)
    local query = self:GetSearch()
    local shown = {}
    for _, item in ipairs(loot) do if itemMatchesQuery(item, query) then shown[#shown + 1] = item end end

    for i, item in ipairs(shown) do
        local row = addRowButton(self.lootChild, i, LOOT_ROW_H)
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(30, 30)
        icon:SetPoint("LEFT", 4, 0)
        icon:SetTexture(item.icon or 134400)

        local name = createText(row, 12, "LEFT")
        name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 7, -1)
        name:SetPoint("RIGHT", row, "RIGHT", -4, 0)
        name:SetText(item.name or ("Item " .. tostring(item.itemID)))

        local details = createText(row, 11, "LEFT")
        details:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 7, 1)
        details:SetPoint("RIGHT", row, "RIGHT", -4, 0)
        details:SetTextColor(0.62, 0.62, 0.66)
        local bits = {}
        if item.slot and item.slot ~= "" then bits[#bits + 1] = item.slot end
        if item.armorType and item.armorType ~= "" then bits[#bits + 1] = item.armorType end
        if item.itemLevel and tonumber(item.itemLevel) and tonumber(item.itemLevel) > 0 then bits[#bits + 1] = "ilvl " .. tostring(item.itemLevel) end
        details:SetText(table.concat(bits, " • "))

        row:SetScript("OnEnter", function(self)
            self.highlight:Show()
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if item.link then GameTooltip:SetHyperlink(item.link) else GameTooltip:SetText(item.name or ("Item " .. tostring(item.itemID))) end
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function(self) self.highlight:Hide(); GameTooltip:Hide() end)
        row:SetScript("OnClick", function()
            if IsShiftKeyDown() and item.link and ChatEdit_InsertLink then ChatEdit_InsertLink(item.link)
            elseif item.link and ItemRefTooltip then ItemRefTooltip:SetHyperlink(item.link); ItemRefTooltip:Show() end
        end)
    end

    self.lootChild:SetHeight(math.max(1, #shown * LOOT_ROW_H))
    local bossText = self.selectedEncounterID and "selected boss" or "all bosses"
    self.status:SetText(string.format("%s — %d loot item%s (%s).", instance.displayName or instance.name or "Instance", #shown, #shown == 1 and "" or "s", bossText))
end

function UI:RefreshAll() self:RefreshInstances(); self:RefreshBosses(); self:RefreshLoot() end
function UI:Show() self:Create(); if not FL.instances then FL:Rescan() end; self.frame:Show(); self:RefreshAll() end
function UI:Hide() if self.frame then self.frame:Hide() end end
function UI:Toggle() self:Create(); if self.frame:IsShown() then self:Hide() else self:Show() end end
