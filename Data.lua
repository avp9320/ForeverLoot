local ADDON_NAME, FL = ...

_G.ForeverLoot = FL
FL.VERSION = "0.2.3"
FL.API_VERSION = 1

local function norm(text)
    text = tostring(text or "")
    text = text:gsub("’", "'")
    text = text:gsub("‘", "'")
    text = text:gsub("`", "'")
    text = text:lower()
    text = text:gsub("&", " and ")
    text = text:gsub("[^%w%s]", " ")
    text = text:gsub("%s+", " ")
    text = text:gsub("^%s+", "")
    text = text:gsub("%s+$", "")
    return text
end

FL.NormalizeName = norm

FL.KNOWN_INSTANCES = {
    { kind="dungeon", name="The Hall of Thanes", minLevel=13, maxLevel=18, isNew=true, aliases={"The Hall of Thanes", "Hall of Thanes"} },
    { kind="dungeon", name="Ruins of Lordaeron", minLevel=15, maxLevel=20, isNew=true, aliases={"Ruins of Lordaeron"} },
    { kind="dungeon", name="Excavation Site", minLevel=24, maxLevel=29, isNew=true, aliases={"Excavation Site", "Excavation Site: Wetlands", "Excavation Site Wetlands"} },
    { kind="dungeon", name="City of Dalaran", minLevel=28, maxLevel=33, isNew=true, aliases={"City of Dalaran"} },
    { kind="dungeon", name="The Drowned City", minLevel=35, maxLevel=40, isNew=true, aliases={"The Drowned City", "Drowned City"} },
    { kind="dungeon", name="Krol'dok Stronghold", minLevel=40, maxLevel=45, isNew=true, aliases={"Krol'dok Stronghold", "Krol’dok Stronghold", "Kroldok Stronghold"} },
    { kind="dungeon", name="Alcaz Prison", minLevel=48, maxLevel=53, isNew=true, aliases={"Alcaz Prison"} },
    { kind="dungeon", name="Blackmaw Hold", minLevel=55, maxLevel=60, isNew=true, aliases={"Blackmaw Hold"} },
    { kind="dungeon", name="Shaper's Terrace", minLevel=58, maxLevel=60, isNew=true, aliases={"Shaper's Terrace", "Shaper’s Terrace", "Shapers Terrace"} },

    { kind="dungeon", name="Ragefire Chasm", aliases={"Ragefire Chasm"} },
    { kind="dungeon", name="Wailing Caverns", aliases={"Wailing Caverns"} },
    { kind="dungeon", name="The Deadmines", aliases={"The Deadmines", "Deadmines"} },
    { kind="dungeon", name="Shadowfang Keep", aliases={"Shadowfang Keep"} },
    { kind="dungeon", name="Blackfathom Deeps", aliases={"Blackfathom Deeps"} },
    { kind="dungeon", name="The Stockade", aliases={"The Stockade", "Stormwind Stockade", "The Stockades"} },
    { kind="dungeon", name="Gnomeregan", aliases={"Gnomeregan"} },
    { kind="dungeon", name="Razorfen Kraul", aliases={"Razorfen Kraul"} },
    { kind="dungeon", name="Scarlet Monastery: Graveyard", aliases={"Scarlet Monastery Graveyard", "Scarlet Monastery: Graveyard", "SM Graveyard"} },
    { kind="dungeon", name="Scarlet Monastery: Library", aliases={"Scarlet Monastery Library", "Scarlet Monastery: Library", "SM Library"} },
    { kind="dungeon", name="Scarlet Monastery: Armory", aliases={"Scarlet Monastery Armory", "Scarlet Monastery: Armory", "SM Armory"} },
    { kind="dungeon", name="Scarlet Monastery: Cathedral", aliases={"Scarlet Monastery Cathedral", "Scarlet Monastery: Cathedral", "SM Cathedral"} },
    { kind="dungeon", name="Razorfen Downs", aliases={"Razorfen Downs"} },
    { kind="dungeon", name="Uldaman", aliases={"Uldaman"} },
    { kind="dungeon", name="Zul'Farrak", aliases={"Zul'Farrak", "Zul’Farrak", "Zul Farrak"} },
    { kind="dungeon", name="Maraudon", aliases={"Maraudon", "Maraudon: Wicked Grotto", "Maraudon Wicked Grotto", "Maraudon: Earth Song Falls", "Maraudon Earth Song Falls", "Maraudon: Foulspore Cavern", "Maraudon Foulspore Cavern"} },
    { kind="dungeon", name="The Temple of Atal'Hakkar", aliases={"The Temple of Atal'Hakkar", "Temple of Atal'Hakkar", "Sunken Temple", "Temple of Atal Hakkar"} },
    { kind="dungeon", name="Blackrock Depths", aliases={"Blackrock Depths"} },
    { kind="dungeon", name="Dire Maul: East", aliases={"Dire Maul East", "Dire Maul: East"} },
    { kind="dungeon", name="Lower Blackrock Spire", aliases={"Lower Blackrock Spire", "Blackrock Spire: Lower", "Blackrock Spire Lower"} },
    { kind="dungeon", name="Dire Maul: North", aliases={"Dire Maul North", "Dire Maul: North"} },
    { kind="dungeon", name="Dire Maul: West", aliases={"Dire Maul West", "Dire Maul: West"} },
    { kind="dungeon", name="Scholomance", aliases={"Scholomance"} },
    { kind="dungeon", name="Stratholme: Main Gate", aliases={"Stratholme Main Gate", "Stratholme: Main Gate", "Stratholme Live"} },
    { kind="dungeon", name="Stratholme: Service Entrance", aliases={"Stratholme Service Entrance", "Stratholme: Service Entrance", "Stratholme Service Gate", "Stratholme Undead"} },
    { kind="dungeon", name="Upper Blackrock Spire", aliases={"Upper Blackrock Spire", "Blackrock Spire: Upper", "Blackrock Spire Upper"} },

    { kind="raid", name="The Barrow Deeps", minLevel=60, maxLevel=60, aliases={"The Barrow Deeps", "Barrow Deeps"} },
    { kind="raid", name="Hyjal Summit", minLevel=60, maxLevel=60, aliases={"Hyjal Summit"} },
    { kind="raid", name="Onyxia's Lair", minLevel=60, maxLevel=60, aliases={"Onyxia's Lair", "Onyxia’s Lair", "Onyxias Lair"} },
}

FL._knownByAlias = {}
for _, meta in ipairs(FL.KNOWN_INSTANCES) do
    for _, alias in ipairs(meta.aliases or {}) do
        FL._knownByAlias[norm(alias)] = meta
    end
end

function FL:GetKnownInstanceMeta(name, isRaid)
    local normalized = norm(name)
    if normalized == "" then return nil end

    local direct = self._knownByAlias[normalized]
    if direct and ((isRaid and direct.kind == "raid") or (not isRaid and direct.kind == "dungeon")) then
        return direct
    end

    for alias, meta in pairs(self._knownByAlias) do
        if ((isRaid and meta.kind == "raid") or (not isRaid and meta.kind == "dungeon")) then
            if #alias >= 8 and (normalized:find(alias, 1, true) or alias:find(normalized, 1, true)) then
                return meta
            end
        end
    end

    return nil
end
