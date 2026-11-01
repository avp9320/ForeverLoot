local ADDON_NAME, FL = ...
FL.Journal = FL.Journal or {}

local J = FL.Journal

local function safeCall(fn, ...)
    if type(fn) ~= "function" then
        return nil
    end
    local ok, a, b, c, d, e, f, g, h, i, j, k, l, m = pcall(fn, ...)
    if not ok then
        return nil
    end
    return a, b, c, d, e, f, g, h, i, j, k, l, m
end

function J:EnsureLoaded()
    if type(EJ_GetInstanceByIndex) == "function" then
        return true
    end
    if C_AddOns and type(C_AddOns.LoadAddOn) == "function" then
        safeCall(C_AddOns.LoadAddOn, "Blizzard_EncounterJournal")
    end
    return type(EJ_GetInstanceByIndex) == "function"
end

function J:ResetLootFilters()
    if type(EJ_ResetLootFilter) == "function" then safeCall(EJ_ResetLootFilter) end
    if C_EncounterJournal and type(C_EncounterJournal.ResetSlotFilter) == "function" then
        safeCall(C_EncounterJournal.ResetSlotFilter)
    end
end

function J:GetCandidateTiers()
    local tiers = {}
    if type(EJ_GetNumTiers) ~= "function" then return tiers end
    local count = tonumber(safeCall(EJ_GetNumTiers)) or 0
    if count <= 0 then return tiers end

    local foreverTier = nil
    if type(EJ_GetTierInfo) == "function" then
        for i = 1, count do
            local name = safeCall(EJ_GetTierInfo, i)
            local n = FL.NormalizeName(name)
            if n:find("forever", 1, true) or n:find("camelot", 1, true) then
                foreverTier = i
                break
            end
        end
    end

    if foreverTier then
        tiers[1] = foreverTier
        return tiers
    end

    local current = type(EJ_GetCurrentTier) == "function" and safeCall(EJ_GetCurrentTier) or nil
    current = tonumber(current)
    if current and current >= 1 and current <= count then
        tiers[1] = current
    elseif count == 1 then
        tiers[1] = 1
    else
        tiers[1] = 1
    end
    return tiers
end

function J:ScanInstances()
    if not self:EnsureLoaded() then
        FL.instances = {}
        FL.scanError = "Encounter Journal API unavailable."
        return FL.instances, FL.scanError
    end

    local oldTier = type(EJ_GetCurrentTier) == "function" and safeCall(EJ_GetCurrentTier) or nil
    local tiers = self:GetCandidateTiers()
    local found, seen = {}, {}

    for _, tier in ipairs(tiers) do
        if type(EJ_SelectTier) == "function" then safeCall(EJ_SelectTier, tier) end
        local tierName = type(EJ_GetTierInfo) == "function" and safeCall(EJ_GetTierInfo, tier) or nil

        for _, isRaid in ipairs({false, true}) do
            for index = 1, 200 do
                local journalInstanceID, name, description, bgImage, buttonImage1, loreImage,
                    buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID,
                    covenantID, returnedIsRaid = safeCall(EJ_GetInstanceByIndex, index, isRaid)

                if not journalInstanceID then break end
                local meta = FL:GetKnownInstanceMeta(name, isRaid)
                if meta then
                    local key = tostring(journalInstanceID) .. ":" .. tostring(isRaid)
                    if not seen[key] then
                        seen[key] = true
                        found[#found + 1] = {
                            journalInstanceID = journalInstanceID,
                            name = name or meta.name,
                            displayName = meta.name or name,
                            description = description,
                            background = bgImage,
                            buttonImage = buttonImage1,
                            loreImage = loreImage,
                            dungeonAreaMapID = dungeonAreaMapID,
                            link = link,
                            mapID = mapID,
                            isRaid = isRaid,
                            tier = tier,
                            tierName = tierName,
                            minLevel = meta.minLevel,
                            maxLevel = meta.maxLevel,
                            isNew = meta.isNew == true,
                            knownMeta = meta,
                        }
                    end
                end
            end
        end
    end

    if oldTier and type(EJ_SelectTier) == "function" then safeCall(EJ_SelectTier, oldTier) end

    table.sort(found, function(a, b)
        if a.isRaid ~= b.isRaid then return not a.isRaid end
        local amin, bmin = a.minLevel or 999, b.minLevel or 999
        if amin ~= bmin then return amin < bmin end
        return tostring(a.displayName or a.name) < tostring(b.displayName or b.name)
    end)

    FL.instances = found
    FL.scanError = (#found == 0) and "No Forever instances were found in the active Encounter Journal tier." or nil
    return found, FL.scanError
end

function J:GetEncounters(instance)
    if not instance or not instance.journalInstanceID then return {} end
    if not self:EnsureLoaded() then return {} end

    safeCall(EJ_SelectInstance, instance.journalInstanceID)
    local encounters = {}
    for index = 1, 100 do
        local name, description, encounterID, rootSectionID, link, journalInstanceID,
            dungeonEncounterID, instanceID = safeCall(EJ_GetEncounterInfoByIndex, index, instance.journalInstanceID)
        if not name or not encounterID then break end
        encounters[#encounters + 1] = {
            index = index, name = name, description = description, encounterID = encounterID,
            rootSectionID = rootSectionID, link = link,
            journalInstanceID = journalInstanceID or instance.journalInstanceID,
            dungeonEncounterID = dungeonEncounterID, instanceID = instanceID,
        }
    end
    return encounters
end

local function enrichItem(info)
    if not info or not info.itemID then return nil end

    local item = {
        itemID = info.itemID, encounterID = info.encounterID, name = info.name,
        itemQuality = info.itemQuality, filterType = info.filterType, icon = info.icon,
        slot = info.slot, armorType = info.armorType, link = info.link,
        handError = info.handError, weaponTypeError = info.weaponTypeError,
    }

    if C_Item and type(C_Item.RequestLoadItemDataByID) == "function" then
        safeCall(C_Item.RequestLoadItemDataByID, item.itemID)
    end

    if C_Item and type(C_Item.GetItemInfo) == "function" then
        local itemName, itemLink, quality, itemLevel, minLevel, itemType, itemSubType,
            stackCount, equipLoc, texture, sellPrice, classID, subclassID, bindType,
            expansionID, setID, isCraftingReagent, itemDescription =
            safeCall(C_Item.GetItemInfo, item.link or item.itemID)

        item.name = itemName or item.name
        item.link = itemLink or item.link
        item.quality = quality
        item.itemLevel = itemLevel
        item.minLevel = minLevel
        item.itemType = itemType
        item.itemSubType = itemSubType
        item.equipLoc = equipLoc
        item.icon = texture or item.icon
        item.classID = classID
        item.subclassID = subclassID
        item.bindType = bindType
        item.description = itemDescription
    end

    if C_Item and type(C_Item.GetDetailedItemLevelInfo) == "function" then
        local detailed = safeCall(C_Item.GetDetailedItemLevelInfo, item.link or item.itemID)
        if detailed then item.itemLevel = detailed end
    end
    return item
end

function J:GetLoot(instance, encounterID)
    if not instance or not instance.journalInstanceID then return {} end
    if not self:EnsureLoaded() then return {} end

    self:ResetLootFilters()
    safeCall(EJ_SelectInstance, instance.journalInstanceID)
    if encounterID and type(EJ_SelectEncounter) == "function" then safeCall(EJ_SelectEncounter, encounterID) end

    local count = tonumber(safeCall(EJ_GetNumLoot)) or 0
    local loot = {}
    for index = 1, count do
        local info = nil
        if C_EncounterJournal and type(C_EncounterJournal.GetLootInfoByIndex) == "function" then
            info = safeCall(C_EncounterJournal.GetLootInfoByIndex, index)
        end
        if info and info.itemID then
            local item = enrichItem(info)
            if item then loot[#loot + 1] = item end
        end
    end

    table.sort(loot, function(a, b)
        local aslot = tostring(a.slot or a.equipLoc or "")
        local bslot = tostring(b.slot or b.equipLoc or "")
        if aslot ~= bslot then return aslot < bslot end
        return tostring(a.name or a.itemID) < tostring(b.name or b.itemID)
    end)
    return loot
end
