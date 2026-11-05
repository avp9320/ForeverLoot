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
    ["excavation site"] = 2998,
    ["city of dalaran"] = 2959,
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
        -- Client beta metadata calls this encounter Infurnus, but current guides
        -- call the boss Magmatus. Keep the existing encounter ID mapping.
        { name = "Magmatus", encounterID = 3495 },
        { name = "Plunder", encounterID = 3494 },
        { name = "Durgen Dirgehammer", encounterID = 3496 },
    },
    ["excavation site"] = {
        -- Synthetic IDs until the live client encounter IDs are confirmed.
        { name = "Saltspine", encounterID = -58001 },
        { name = "Shadetooth", encounterID = -58002 },
        { name = "Highland Horror", encounterID = -58003 },
        { name = "Relic Guardian", encounterID = -58004 },
    },
    ["city of dalaran"] = {
        { name = "Atrexis the Grave Knight", encounterID = -57001 },
        { name = "Lyn the Ignored", encounterID = -57002 },
        { name = "Arcane Anomaly", encounterID = -57003 },
        { name = "Fel Ancient", encounterID = -57004 },
        { name = "Arcanic Enigma / Mana Elemental", encounterID = -57005 },
        { name = "Unstable Sentinel", encounterID = -57006 },
        { name = "Shade of the Archmage", encounterID = -57007 },
        { name = "Mana Devourer", encounterID = -57008 },
        { name = "Mana Wraith", encounterID = -57009 },
    },
    ["ruins of lordaeron"] = {
        { name = "Witherfang", encounterID = 3353 },
        { name = "The Butcher", encounterID = 3355 },
        { name = "The Abandoned", encounterID = 3357 },
        { name = "Bjork", encounterID = 3412 },
        { name = "Viktor the Vile", encounterID = 3411 },
        { name = "Rath'mael", encounterID = 3354 },
        { name = "Lordaeron Captain", encounterID = 3408 },
    },
}

-- Confirmed Forever drops will override these by itemID and encounter ID.
-- The client hides many source/loot-table details until encountered.
Static.verifiedLoot = {}

-- Reference-sourced Forever loot from the 2026 client item table + published
-- boss attribution. This is useful but NOT the same as a live confirmed drop.
-- Source IDs: https://daybreakforever.com/discoveries
-- Boss attributions: wowhead.com/forever/dungeon-journal/
-- and method.gg/wow-forever/dungeons/. More sources may be discovered in game.
Static.foreverBetaLoot = {
    -- Boss/item attribution: https://www.icy-veins.com/wow-forever/
    -- Client item IDs: https://lvren.fun/en-gb/dungeons/dalaran and
    -- https://ladderly.gg/forever/loot/excavation-site-wetlands
    ["excavation site"] = {
        [-58001] = {
            {itemID=273022,name="Supple Bellyskin Leggings"},
            {itemID=273023,name="Saltscale Girdle"},
            {itemID=273024,name="Glinteye Slippers"},
        },
        [-58002] = {
            {itemID=273025,name="Raptorclaw Greaves"},
            {itemID=273026,name="Garb of Florid Feathers"},
            {itemID=273027,name="Raptor's Gaze"},
        },
        [-58004] = {
            {itemID=273028,name="Reliquary Mantle"},
            -- Golemsight Long Gun 273029 appears in published boss guides;
            -- verify its client record during a live run.
            {itemID=273029,name="Golemsight Long Gun"},
            {itemID=273030,name="Ring of Power Regulation"},
        },
    },
    ["city of dalaran"] = {
        [-57001] = {
            {itemID=273036,name="Graveweave Bindings"},
            {itemID=273032,name="Bonebinder's Signet"},
            {itemID=273033,name="Gravespike Repeater"},
        },
        [-57002] = {
            {itemID=273054,name="Cartilage Shapers"},
            {itemID=273053,name="Tendonscraper Dagger"},
            {itemID=273055,name="Bonepile Gaze"},
        },
        [-57003] = {
            {itemID=273031,name="Runemender's Seal"},
            {itemID=273034,name="Ephemeral Grips"},
            {itemID=273035,name="Mana-Warped Chain Shirt"},
        },
        [-57004] = {
            {itemID=273039,name="Blightleaf Rope"},
            {itemID=273038,name="Garb of Fallen Felbark"},
            {itemID=273037,name="Felbough Arm"},
        },
        [-57005] = {
            {itemID=273045,name="Drape of Shifting Energy"},
            {itemID=273044,name="Violet Sorcerer's Robes"},
            {itemID=273043,name="Wand of Mana Concentration"},
        },
        [-57006] = {
            {itemID=273046,name="Guardian's Dualblade"},
            {itemID=273048,name="Refractory Scaleguards"},
            {itemID=273047,name="Unstable Crystalline Shoulderpads"},
        },
        [-57007] = {
            {itemID=273052,name="Ponderous Orb"},
            {itemID=273049,name="Archmagister's Faceted Pendant"},
            {itemID=273051,name="Violet Sorcerer's Mantle"},
        },
        [-57008] = {
            {itemID=273040,name="Spine of the Devourer"},
            {itemID=273042,name="Manascale Treads"},
            {itemID=273041,name="Slitherwrap Girdle"},
        },
    },
    ["the hall of thanes"] = {
        [3493] = {
            {itemID=270227, name="Ephemeral Choker"},
            {itemID=271096, name="Aetherwisp Bracers"},
            {itemID=271097, name="Spiritwraith Drape"},
        },
        [3495] = {
            {itemID=270230, name="Kindlegem Girdle"},
            {itemID=270231, name="Flamefist Grips"},
            {itemID=271095, name="Fang of Magmatus"},
        },
        [3494] = {
            {itemID=270228, name="Golemheart Stave"},
            {itemID=270229, name="Treads of the Protector Golem"},
            {itemID=271098, name="Golemguard Chest"},
        },
        [3496] = {
            {itemID=270256, name="Durgen's Crescent Axe"},
            {itemID=270260, name="Direhammer Leggings"},
            {itemID=270261, name="Robes of the Disgraced Thane"},
        },
    },
    ["ruins of lordaeron"] = {
        [3353] = {
            {itemID=271201, name="Atrophic Girdle"},
            {itemID=271202, name="Witherbite Bracers"},
            {itemID=271203, name="Segmented Spider Leg"},
        },
        [3355] = {
            {itemID=271204, name="Meathook Slicer"},
            {itemID=271205, name="Abomination Bones"},
            {itemID=271206, name="Leftover Abomination Skin"},
        },
        [3357] = {
            {itemID=271207, name="Rotmender's Leggings"},
            {itemID=271208, name="Grip of Fear"},
            {itemID=271216, name="Scepter of the Abandoned"},
        },
        [3412] = {
            {itemID=271209, name="Bonerust Leggings"},
            {itemID=271210, name="Tuskwrap Belt"},
            {itemID=271217, name="Corpse Chopper"},
        },
        [3411] = {
            {itemID=271211, name="Vilewalkers"},
            {itemID=271212, name="Bloodied Chestwraps"},
            {itemID=271218, name="Vileblood Scimitar"},
        },
        [3354] = {
            {itemID=271213, name="Mirror of Rath'mael"},
            {itemID=271214, name="Rotmender's Treads"},
            {itemID=271215, name="Coldspire Staff"},
        },
    },
}

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
            dataSource = self.foreverBetaLoot[key] and "forever-beta" or "classic-fallback",
            lootCoverage = "partial",
        }
    end
    return list
end

function Static:GetEncounters(instance)
    local key=self:InstanceKey(instance)
    local list,seen={},{}
    for _, boss in ipairs(self.bosses[key] or {}) do
        list[#list+1]=boss
        seen[boss.encounterID]=true
    end
    if FL.Learning then
        for _,boss in ipairs(FL.Learning:GetEncounters(key)) do
            if not seen[boss.encounterID] then
                list[#list+1]=boss
                seen[boss.encounterID]=true
            end
        end
    end
    return list
end

function Static:GetLoot(instance, encounterID)
    local key = self:InstanceKey(instance)
    local classic = self.classicLoot[key] or {}
    local verified = self.verifiedLoot[key] or {}
    local foreverBeta = self.foreverBetaLoot[key] or {}
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
        if FL.Learning then append(FL.Learning:GetLoot(key,id), "observed-in-game") end
        append(verified[id], "forever-verified")
        append(foreverBeta[id], "forever-reference")
        append(classic[id], "classic-baseline")
    end
    if encounterID then
        forBoss(encounterID)
    else
        for _, boss in ipairs(self:GetEncounters(instance)) do forBoss(boss.encounterID) end
    end
    return loot
end
