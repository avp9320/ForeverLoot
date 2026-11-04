local ADDON_NAME, FL = ...

function FL:Rescan()
    local live, err = self.Journal:ScanInstances()
    live = type(live) == "table" and live or {}
    local seen, all = {}, {}
    for _, instance in ipairs(live) do
        all[#all + 1] = instance
        seen[self.NormalizeName(instance.displayName or instance.name)] = true
    end
    -- Never leave the browser empty just because Forever has no Blizzard EJ.
    for _, instance in ipairs(self.Static:GetInstances()) do
        local name = self.NormalizeName(instance.displayName or instance.name)
        if not seen[name] then
            all[#all + 1] = instance
            seen[name] = true
        end
    end
    self.instances = all
    self.journalStatus = err
    self.scanError = #all == 0 and (err or "No instance metadata available.") or nil
    return all, self.scanError
end

function FL:GetInstances()
    if not self.instances then
        self:Rescan()
    end
    return self.instances or {}
end

function FL:GetInstanceByJournalID(journalInstanceID)
    journalInstanceID = tonumber(journalInstanceID)
    if not journalInstanceID then return nil end

    for _, instance in ipairs(self:GetInstances()) do
        if tonumber(instance.journalInstanceID) == journalInstanceID then
            return instance
        end
    end
    return nil
end

function FL:GetInstanceByMapID(mapID)
    mapID = tonumber(mapID)
    if not mapID then return nil end

    for _, instance in ipairs(self:GetInstances()) do
        if tonumber(instance.mapID) == mapID or tonumber(instance.dungeonAreaMapID) == mapID then
            return instance
        end
    end
    return nil
end

function FL:FindInstanceByName(name)
    local needle = self.NormalizeName(name)
    if needle == "" then return nil end

    for _, instance in ipairs(self:GetInstances()) do
        local a = self.NormalizeName(instance.name)
        local b = self.NormalizeName(instance.displayName)
        if a == needle or b == needle or a:find(needle, 1, true) or b:find(needle, 1, true) then
            return instance
        end
    end
    return nil
end

function FL:GetEncounters(instanceOrID)
    local instance = instanceOrID
    if type(instanceOrID) ~= "table" then
        instance = self:GetInstanceByJournalID(instanceOrID)
    end
    if not instance then return {} end
    if instance.isStatic then return self.Static:GetEncounters(instance) end
    local live = self.Journal:GetEncounters(instance)
    if live and #live > 0 then return live end
    return self.Static:GetEncounters(instance)
end

function FL:GetInstanceLoot(instanceOrID, encounterID)
    local instance = instanceOrID
    if type(instanceOrID) ~= "table" then
        instance = self:GetInstanceByJournalID(instanceOrID)
    end
    if not instance then return {} end
    if instance.isStatic then return self.Static:GetLoot(instance, encounterID) end
    local live = self.Journal:GetLoot(instance, encounterID)
    if live and #live > 0 then return live end
    return self.Static:GetLoot(instance, encounterID)
end

function FL:GetLootForMapID(mapID, encounterID)
    local instance = self:GetInstanceByMapID(mapID)
    if not instance then
        return nil, {}
    end
    return instance, self:GetInstanceLoot(instance, encounterID)
end

function FL:GetAPI()
    return {
        version = self.API_VERSION,
        GetInstances = function() return FL:GetInstances() end,
        GetInstanceByMapID = function(mapID) return FL:GetInstanceByMapID(mapID) end,
        GetEncounters = function(instance) return FL:GetEncounters(instance) end,
        GetInstanceLoot = function(instance, encounterID) return FL:GetInstanceLoot(instance, encounterID) end,
        GetLootForMapID = function(mapID, encounterID) return FL:GetLootForMapID(mapID, encounterID) end,
    }
end
