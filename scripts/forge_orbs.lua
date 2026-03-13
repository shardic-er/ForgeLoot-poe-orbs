haos orb-- @load-order 20
-- ForgeLoot PoE Orbs: Currency crafting system
-- Depends on: forge_balance.lua, forge_commands.lua, forge_names.lua (from forge-loot)
--
-- Two-spell flow (same pattern as transmog_rune.lua):
-- 1. Player right-clicks orb -> Spell 1 (instant, Targets=16) shows item cursor
-- 2. Player clicks a forge item -> RegisterItemEvent ON_USE validates,
--    stores pending data, calls CastSpell for Spell 2
-- 3. Spell 2 shows 1.5s cast bar (interruptible by movement/damage)
-- 4. Cast completes -> RegisterSpellEvent applies the orb effect
--
-- Design: orbs destroy the old forge item and create a new one with modified
-- affixes. Display model, sockets, and enchantments carry over. Stats are
-- recalculated from scratch based on the new quality/suffix/prefix state.

FORGE = FORGE or {}
FORGE.ORBS = FORGE.ORBS or {}

-- =============================================================================
-- Stat name lookup (for influence labels)
-- =============================================================================

local STAT_NAMES = {
    [3] = "Agility", [4] = "Strength", [5] = "Intellect", [6] = "Spirit",
    [7] = "Stamina", [12] = "Defense", [13] = "Dodge", [14] = "Parry",
    [15] = "Block Rating", [31] = "Hit Rating", [32] = "Crit Rating",
    [36] = "Haste", [37] = "Expertise", [38] = "Attack Power",
    [43] = "MP5", [44] = "Armor Pen", [45] = "Spell Power",
    [48] = "Block Value",
}

-- Stat ID -> enchantment ID for Influenced Exalted Orb tooltip
local INFLUENCE_ENCHANTS = {
    [3]  = ENCHANTMENT_INFLUENCE_AGI,
    [4]  = ENCHANTMENT_INFLUENCE_STR,
    [5]  = ENCHANTMENT_INFLUENCE_INT,
    [6]  = ENCHANTMENT_INFLUENCE_SPI,
    [7]  = ENCHANTMENT_INFLUENCE_STA,
    [12] = ENCHANTMENT_INFLUENCE_DEF,
    [13] = ENCHANTMENT_INFLUENCE_DODGE,
    [14] = ENCHANTMENT_INFLUENCE_PARRY,
    [15] = ENCHANTMENT_INFLUENCE_BLOCK_RTG,
    [31] = ENCHANTMENT_INFLUENCE_HIT,
    [32] = ENCHANTMENT_INFLUENCE_CRIT,
    [36] = ENCHANTMENT_INFLUENCE_HASTE,
    [37] = ENCHANTMENT_INFLUENCE_EXPERTISE,
    [38] = ENCHANTMENT_INFLUENCE_AP,
    [43] = ENCHANTMENT_INFLUENCE_MP5,
    [44] = ENCHANTMENT_INFLUENCE_ARMOR_PEN,
    [45] = ENCHANTMENT_INFLUENCE_SP,
    [48] = ENCHANTMENT_INFLUENCE_BLOCK_VAL,
}

-- Reverse: enchantment ID -> stat ID
local ENCHANT_TO_STAT = {}
for statId, enchId in pairs(INFLUENCE_ENCHANTS) do
    ENCHANT_TO_STAT[enchId] = statId
end

-- Inventory type -> equipment slot mapping for transmog
local INV_TYPE_SLOTS = {
    [1]  = {0},        -- Head
    [2]  = {1},        -- Neck
    [3]  = {2},        -- Shoulder
    [4]  = {4},        -- Shirt
    [5]  = {4},        -- Chest
    [6]  = {5},        -- Waist
    [7]  = {6},        -- Legs
    [8]  = {7},        -- Feet
    [9]  = {8},        -- Wrists
    [10] = {9},        -- Hands
    [11] = {10, 11},   -- Finger (ring1, ring2)
    [12] = {12, 13},   -- Trinket
    [13] = {15, 16},   -- One-Hand (MH or OH)
    [14] = {14},       -- Shield (off-hand)
    [15] = {17},       -- Ranged
    [16] = {15},       -- Cloak (back)
    [17] = {15, 16},   -- Two-Hand
    [20] = {4},        -- Robe (chest)
    [21] = {15},       -- Main Hand
    [22] = {16},       -- Off Hand
    [23] = {16},       -- Holdable
    [25] = {17},       -- Thrown
    [26] = {17},       -- Ranged Right (gun/crossbow)
}

-- =============================================================================
-- Orb Definitions
-- =============================================================================

local ORB_DEFS = {
    alteration = {
        entry = ITEM_ORB_ALTERATION,
        spell = SPELL_ORB_ALTERATION,
        castSpell = SPELL_ORB_ALTERATION_CAST,
        name = "Orb of Alteration",
        canApply = function(state)
            return state.quality == 2 and state.suffix1_name ~= nil
        end,
    },
    transmutation = {
        entry = ITEM_ORB_TRANSMUTATION,
        spell = SPELL_ORB_TRANSMUTATION,
        castSpell = SPELL_ORB_TRANSMUTATION_CAST,
        name = "Orb of Transmutation",
        canApply = function(state)
            return state.quality == 1
        end,
    },
    regal = {
        entry = ITEM_ORB_REGAL,
        spell = SPELL_ORB_REGAL,
        castSpell = SPELL_ORB_REGAL_CAST,
        name = "Regal Orb",
        canApply = function(state)
            return state.quality == 2
        end,
    },
    exalted = {
        entry = ITEM_ORB_EXALTED,
        spell = SPELL_ORB_EXALTED,
        castSpell = SPELL_ORB_EXALTED_CAST,
        name = "Exalted Orb",
        canApply = function(state)
            return state.prefix1_stat_id ~= nil and state.prefix2_stat_id == nil
        end,
    },
    alchemy = {
        entry = ITEM_ORB_ALCHEMY,
        spell = SPELL_ORB_ALCHEMY,
        castSpell = SPELL_ORB_ALCHEMY_CAST,
        name = "Orb of Alchemy",
        canApply = function(state)
            return state.quality == 1
        end,
    },
    -- Renamed from "Orb of Scouring" -> "Orb of Annulment" (tokens kept)
    annulment = {
        entry = ITEM_ORB_SCOURING,
        spell = SPELL_ORB_SCOURING,
        castSpell = SPELL_ORB_SCOURING_CAST,
        name = "Orb of Annulment",
        canApply = function(state)
            return state.quality >= 2
        end,
    },
    chaos = {
        entry = ITEM_ORB_CHAOS,
        spell = SPELL_ORB_CHAOS,
        castSpell = SPELL_ORB_CHAOS_CAST,
        name = "Chaos Orb",
        canApply = function(state)
            return state.quality >= 2
        end,
    },
    -- Renamed from "Divine Orb" -> "Blessed Orb" (tokens kept)
    blessed = {
        entry = ITEM_ORB_DIVINE,
        spell = SPELL_ORB_DIVINE,
        castSpell = SPELL_ORB_DIVINE_CAST,
        name = "Blessed Orb",
        canApply = function(state)
            return state.weapon_type ~= nil
        end,
    },
    -- =========================================================================
    -- NEW ORBS
    -- =========================================================================
    fullscour = {
        entry = ITEM_ORB_FULLSCOUR,
        spell = SPELL_ORB_FULLSCOUR,
        castSpell = SPELL_ORB_FULLSCOUR_CAST,
        name = "Orb of Scouring",
        canApply = function(state)
            return state.quality >= 2
        end,
    },
    whetstone = {
        entry = ITEM_ORB_WHETSTONE,
        spell = SPELL_ORB_WHETSTONE,
        castSpell = SPELL_ORB_WHETSTONE_CAST,
        name = "Blacksmith's Whetstone",
        canApply = function(state)
            if state.weapon_type == nil then return false end
            if (state.item_level_override or 0) >= 20 then return false, "This item cannot be improved any further." end
            return true
        end,
    },
    armorer = {
        entry = ITEM_ORB_ARMORER,
        spell = SPELL_ORB_ARMORER,
        castSpell = SPELL_ORB_ARMORER_CAST,
        name = "Armorer's Scrap",
        canApply = function(state)
            if state.weapon_type ~= nil then return false end
            if (state.item_level_override or 0) >= 20 then return false, "This item cannot be improved any further." end
            return true
        end,
    },
    mirror = {
        entry = ITEM_ORB_MIRROR,
        spell = SPELL_ORB_MIRROR,
        castSpell = SPELL_ORB_MIRROR_CAST,
        name = "Mirror of Kalandra",
        canApply = function(state)
            return state.prefix3_word == nil  -- cannot mirror an already-locked item
        end,
    },
    ancient = {
        entry = ITEM_ORB_ANCIENT,
        spell = SPELL_ORB_ANCIENT,
        castSpell = SPELL_ORB_ANCIENT_CAST,
        name = "Ancient Orb",
        canApply = function(state)
            return true  -- any forge item
        end,
    },
    transmog = {
        entry = ITEM_ORB_TRANSMOG,
        spell = SPELL_ORB_TRANSMOG,
        castSpell = SPELL_ORB_TRANSMOG_CAST,
        name = "Divine Orb",
        usesTransmogConfirm = true,  -- confirmation popup, destroys source item
        canApply = function(state)
            return true  -- validated in custom logic
        end,
    },
    identify = {
        entry = ITEM_ORB_IDENTIFY,
        spell = SPELL_ORB_IDENTIFY,
        castSpell = SPELL_ORB_IDENTIFY_CAST,
        name = "Scroll of Identification",
        usesAddonInput = true,  -- handled via addon popup, not standard flow
        canApply = function(state)
            return true  -- any forge item
        end,
    },
    portal = {
        entry = ITEM_PORTAL_SCROLL,
        spell = SPELL_PORTAL_SCROLL,
        castSpell = SPELL_PORTAL_SCROLL_CAST,
        name = "Portal Scroll",
        noTarget = true,  -- self-use, no item target needed
        canApply = function(state)
            return true
        end,
    },
    awakener = {
        entry = ITEM_ORB_AWAKENER,
        spell = SPELL_ORB_AWAKENER,
        castSpell = SPELL_ORB_AWAKENER_CAST,
        name = "Awakener's Orb",
        canApply = function(state)
            return state.quality == 3
                and state.prefix1_stat_id ~= nil
                and state.prefix2_stat_id == nil
        end,
    },
    influenced = {
        entry = ITEM_ORB_INFLUENCED,
        spell = SPELL_ORB_INFLUENCED,
        castSpell = SPELL_ORB_INFLUENCED_CAST,
        name = "Influenced Exalted Orb",
        needsInfluence = true,  -- reads influence from orb enchantment
        canApply = function(state)
            return state.prefix1_stat_id ~= nil and state.prefix2_stat_id == nil
        end,
    },
    jeweler = {
        entry = ITEM_ORB_JEWELER,
        spell = SPELL_ORB_JEWELER,
        castSpell = SPELL_ORB_JEWELER_CAST,
        name = "Jeweler's Orb",
        canApply = function(state)
            if state.socket_count >= 3 then
                return false, "This item already has the maximum number of sockets."
            end
            return true
        end,
    },
    vaal = {
        entry = ITEM_ORB_VAAL,
        spell = SPELL_ORB_VAAL,
        castSpell = SPELL_ORB_VAAL_CAST,
        name = "Vaal Orb",
        canApply = function(state)
            return state.quality >= 1
        end,
    },
}

FORGE.ORBS.DEFS = ORB_DEFS

-- Reverse lookups
local ENTRY_TO_ORB = {}      -- item entry -> orb type name
local CAST_SPELL_TO_ORB = {} -- cast spell ID -> orb type name
for name, def in pairs(ORB_DEFS) do
    ENTRY_TO_ORB[def.entry] = name
    CAST_SPELL_TO_ORB[def.castSpell] = name
end

-- =============================================================================
-- Vaal Aura Sync ("No Vaals" buff -- present while player has Vaal Orbs)
-- =============================================================================

local function syncVaalAura(player)
    local count = player:GetItemCount(ITEM_ORB_VAAL)
    local hasSuccess = player:HasAura(SPELL_VAAL_SUCCESS_AURA)
    local hasFail = player:HasAura(SPELL_VAAL_FAIL_AURA)

    -- "No Vaals" is suppressed while Big Vaals or Poof is active
    if count > 0 and not hasSuccess and not hasFail then
        if not player:HasAura(SPELL_VAAL_AURA) then
            player:AddAura(SPELL_VAAL_AURA, player)
        end
    else
        if player:HasAura(SPELL_VAAL_AURA) then
            player:RemoveAura(SPELL_VAAL_AURA)
        end
    end
end

-- =============================================================================
-- Pending State (MAP-state Lua table, keyed by player GUID)
-- =============================================================================

local pendingOrb = {}       -- playerGuid -> { orbType, targetEntry, orbItemEntry, timestamp, extra }
-- NOTE: pendingRename/pendingTransmog removed. These flows cross MAP/WORLD state
-- boundaries (addon messages run in WORLD, item/spell events in MAP). Data is now
-- persisted via the orb_pending DB table instead of local Lua tables.

local IDENTIFY_PREFIX = "FORB"  -- addon message prefix for Scroll of Identification

-- Mirror prefix words: randomly selected when mirroring an item
local MIRROR_PREFIXES = { "Reflected", "Pristine", "Faithful", "Perfect", "Immaculate" }

-- =============================================================================
-- Item State Reader
-- =============================================================================

-- Eluna's IsNull() is unreliable for NULL columns. Also check for 0/"" fallback.
local function nullStr(q, idx)
    local v = q:GetString(idx)
    if v == "" then return nil end
    return v
end

local function nullUInt(q, idx)
    local v = q:GetUInt32(idx)
    if v == 0 then return nil end
    return v
end

local function readForgeItemState(entry)
    local q = WorldDBQuery(string.format(
        "SELECT quality, mob_level, item_level, weapon_type, slot_name, " ..
        "armor_class, suffix1_name, suffix2_name, " ..
        "prefix1_stat_id, prefix2_stat_id, prefix3_stat_id, prefix3_word, " ..
        "item_class, item_subclass, inv_type, name, attack_speed, " ..
        "display_info_id, display_source_entry, dmg_min, dmg_max, " ..
        "armor, block, socket_count, item_level_override, " ..
        "name_override " ..
        "FROM virtual_item_instance WHERE entry = %d", entry
    ))
    if not q then return nil end

    return {
        entry = entry,
        quality = q:GetUInt32(0),
        mob_level = q:GetUInt32(1),
        item_level = q:GetUInt32(2),
        weapon_type = nullStr(q, 3),
        slot_name = nullStr(q, 4),
        armor_class = nullStr(q, 5),
        suffix1_name = nullStr(q, 6),
        suffix2_name = nullStr(q, 7),
        prefix1_stat_id = nullUInt(q, 8),
        prefix2_stat_id = nullUInt(q, 9),
        prefix3_stat_id = nullUInt(q, 10),
        prefix3_word = nullStr(q, 11),
        item_class = q:GetUInt32(12),
        item_subclass = q:GetUInt32(13),
        inv_type = q:GetUInt32(14),
        name = q:GetString(15),
        attack_speed = q:GetUInt32(16),
        display_info_id = q:GetUInt32(17),
        display_source_entry = q:GetUInt32(18),
        dmg_min = q:GetFloat(19),
        dmg_max = q:GetFloat(20),
        armor_value = q:GetUInt32(21),
        block_value = q:GetUInt32(22),
        socket_count = q:GetUInt32(23),
        item_level_override = nullUInt(q, 24),
        name_override = nullStr(q, 25),
    }
end

-- =============================================================================
-- Weapon Size Helper
-- =============================================================================

local function getWeaponSize(wtype)
    if not wtype then return nil end
    if wtype.is2h then return "2h" end
    if wtype.dpsCategory == "ranged" or wtype.dpsCategory == "wand" then return "ranged" end
    return "1h"
end

-- =============================================================================
-- Create New Item From Modified State
-- =============================================================================

local function recreateItem(player, oldEntry, state)
    local level = state.mob_level
    local quality = state.quality
    local displayQuality = state.display_quality or quality
    local wtype = nil

    if state.weapon_type then
        wtype = FORGE.WEAPON_TYPES[state.weapon_type]
    end

    -- Recalculate item level (item_level_override is a bonus from whetstone/armorer)
    local ilvlBonus = state.item_level_override or 0
    local itemLevel = FORGE.computeItemLevel(level, quality) + ilvlBonus
    local persistedIlvlOverride = state.item_level_override

    -- Get suffix data
    local suffix1 = state.suffix1_name and FORGE.SUFFIXES[state.suffix1_name] or nil
    local suffix2 = state.suffix2_name and FORGE.SUFFIXES[state.suffix2_name] or nil

    -- Regenerate stats from scratch (pass computed ilvl including whetstone/armorer bonus)
    local weaponSize = wtype and getWeaponSize(wtype) or nil
    local stats = FORGE.generateItemStats(
        level, quality, state.slot_name, weaponSize,
        suffix1, state.prefix1_stat_id, state.prefix2_stat_id,
        ilvlBonus > 0 and itemLevel or nil, suffix2
    )

    -- Recalculate weapon damage
    local dmgMin, dmgMax, speed = 0, 0, 0
    local invType = state.inv_type

    if wtype then
        dmgMin, dmgMax, speed = FORGE.computeWeaponDamage(level, quality, state.weapon_type)

        -- Handle speed override (Blessed Orb) or preserve old speed
        if state.new_speed then
            speed = state.new_speed
        elseif state.attack_speed and state.attack_speed > 0 then
            speed = state.attack_speed
        end

        -- Recalculate damage for actual speed
        local dpsCat = wtype.dpsCategory
        local dpsTable = FORGE.ILVL_DPS[dpsCat]
        local idx = math.max(1, math.min(300, itemLevel))
        local blueDps = dpsTable[idx] or 1.0
        local qualityMult = FORGE.QUALITY_DPS_MULT[quality] or 1.0
        local dps = blueDps * qualityMult
        local avgDmg = dps * speed / 1000.0
        local spread = FORGE.DAMAGE_SPREAD[dpsCat] or FORGE.DAMAGE_SPREAD["1h"]
        dmgMin = math.floor(avgDmg * spread.min + 0.5)
        dmgMax = math.floor(avgDmg * spread.max + 0.5)
        if dmgMin < 1 then dmgMin = 1 end
        if dmgMax < dmgMin then dmgMax = dmgMin end

        -- Caster weapon affix
        if quality >= 2 and FORGE.isCasterWeapon(state.weapon_type, suffix1) then
            local actualDps = (dmgMin + dmgMax) / 2.0 / (speed / 1000.0)
            local sacrificedDps = actualDps / 3.0
            dmgMin = math.floor(dmgMin * 2 / 3)
            dmgMax = math.floor(dmgMax * 2 / 3)
            if dmgMin < 1 then dmgMin = 1 end
            if dmgMax < dmgMin then dmgMax = dmgMin end
            local bonusSP = math.floor(sacrificedDps * FORGE.CASTER_SP_PER_DPS)
            stats[45] = (stats[45] or 0) + bonusSP
            if invType == 13 then invType = 21 end
        end
    end

    -- Recalculate armor
    local armorValue = 0
    if state.slot_name then
        armorValue = FORGE.computeArmor(level, state.slot_name, state.armor_class)
    end
    local blockValue = FORGE.computeBlockValue(itemLevel, state.slot_name)

    -- Generate name (or use custom name from Scroll of Identification)
    local itemName
    if state.name_override then
        itemName = state.name_override
    else
        local nouns
        if state.weapon_type then
            nouns = FORGE.WEAPON_NOUNS[state.weapon_type] or {"Weapon"}
        else
            nouns = FORGE.getNouns(state.slot_name, state.armor_class)
        end
        itemName = FORGE.randomName(
            nouns, quality, state.suffix1_name,
            state.prefix1_stat_id, state.prefix2_stat_id,
            state.suffix2_name
        )
    end

    -- Prepend mirror/corruption prefix if present
    if state.prefix3_word then
        itemName = state.prefix3_word .. " " .. itemName
    end

    -- Build stat array
    local statArray = {}
    for statType, statValue in pairs(stats) do
        statArray[#statArray + 1] = { type = statType, value = statValue }
    end

    local displayInfoId = state.display_info_id
    local displaySourceEntry = state.display_source_entry

    -- Create new forge item
    local newEntry = CreateForgeItem({
        itemClass = state.item_class,
        itemSubClass = state.item_subclass,
        invType = invType,
        name = itemName,
        quality = displayQuality,
        requiredLevel = level,
        itemLevel = itemLevel,
        displayInfoId = displayInfoId,
        displaySourceEntry = displaySourceEntry,
        dmgMin = dmgMin,
        dmgMax = dmgMax,
        dmgType = 0,
        attackSpeed = speed,
        armor = armorValue,
        block = blockValue,
        socketCount = state.socket_count,
        stats = statArray,
    })

    if newEntry == 0 then
        player:SendBroadcastMessage("Error: Failed to create new forge item (pool exhausted?).")
        return nil
    end

    -- Update affix tracking on the new entry
    WorldDBExecute(string.format(
        "UPDATE virtual_item_instance SET " ..
        "weapon_type=%s, slot_name=%s, armor_class=%s, " ..
        "suffix1_name=%s, suffix2_name=%s, " ..
        "prefix1_stat_id=%s, prefix2_stat_id=%s, " ..
        "prefix3_stat_id=%s, prefix3_word=%s, " ..
        "item_level_override=%s, name_override=%s, mob_level=%d " ..
        "WHERE entry=%d",
        state.weapon_type and ("'" .. state.weapon_type .. "'") or "NULL",
        state.slot_name and ("'" .. state.slot_name .. "'") or "NULL",
        state.armor_class and ("'" .. state.armor_class .. "'") or "NULL",
        state.suffix1_name and ("'" .. state.suffix1_name:gsub("'", "''") .. "'") or "NULL",
        state.suffix2_name and ("'" .. state.suffix2_name:gsub("'", "''") .. "'") or "NULL",
        state.prefix1_stat_id and tostring(state.prefix1_stat_id) or "NULL",
        state.prefix2_stat_id and tostring(state.prefix2_stat_id) or "NULL",
        state.prefix3_stat_id and tostring(state.prefix3_stat_id) or "NULL",
        state.prefix3_word and ("'" .. state.prefix3_word:gsub("'", "''") .. "'") or "NULL",
        persistedIlvlOverride and tostring(persistedIlvlOverride) or "NULL",
        state.name_override and ("'" .. state.name_override:gsub("'", "''") .. "'") or "NULL",
        level,
        newEntry
    ))

    -- Read enchantments and gems from the OLD item before destroying it
    local oldItem = player:GetItemByEntry(oldEntry)
    local oldEnchantId = 0
    local oldGems = {}
    if oldItem then
        oldEnchantId = oldItem:GetEnchantmentId(0) or 0
        for i = 0, 2 do
            local gemEnch = oldItem:GetEnchantmentId(i + 2) or 0
            if gemEnch > 0 then
                oldGems[i] = gemEnch
            end
        end
    end

    -- Remove old item, destroy old template
    player:RemoveItem(oldEntry, 1)
    DestroyForgeItem(oldEntry)

    -- Add new item
    local item = player:AddItem(newEntry, 1)
    if not item then
        player:SendBroadcastMessage("Error: Inventory full! New item lost.")
        DestroyForgeItem(newEntry)
        return nil
    end

    -- Restore enchantments
    if oldEnchantId > 0 then
        item:SetEnchantment(oldEnchantId, 0)
    end
    for i, gemEnch in pairs(oldGems) do
        item:SetEnchantment(gemEnch, i + 2)
    end

    -- Refresh client cache
    SendForgeItemQuery(player, newEntry)

    return newEntry, itemName, stats
end

-- =============================================================================
-- Orb Apply Functions
-- =============================================================================

local function applyAlteration(player, state)
    local suffixName, _ = FORGE.rollSuffix(2, state.slot_name, state.armor_class, state.weapon_type)
    state.suffix1_name = suffixName
    return recreateItem(player, state.entry, state)
end

local function applyTransmutation(player, state)
    state.quality = 2
    local suffixName, _ = FORGE.rollSuffix(2, state.slot_name, state.armor_class, state.weapon_type)
    state.suffix1_name = suffixName
    return recreateItem(player, state.entry, state)
end

local function applyRegal(player, state)
    state.quality = 3
    local p1stat, _ = FORGE.rollPrefix(FORGE.PREFIX1_TABLE)
    state.prefix1_stat_id = p1stat
    return recreateItem(player, state.entry, state)
end

local function applyExalted(player, state)
    state.quality = 4
    local p2stat, _ = FORGE.rollPrefix(FORGE.PREFIX2_TABLE)
    state.prefix2_stat_id = p2stat
    return recreateItem(player, state.entry, state)
end

-- Alchemy: common->epic (add suffix + both prefixes)
local function applyAlchemy(player, state)
    state.quality = 4
    local suffixName, _ = FORGE.rollSuffix(4, state.slot_name, state.armor_class, state.weapon_type)
    state.suffix1_name = suffixName
    state.suffix2_name = nil
    local p1stat, _ = FORGE.rollPrefix(FORGE.PREFIX1_TABLE)
    state.prefix1_stat_id = p1stat
    local p2stat, _ = FORGE.rollPrefix(FORGE.PREFIX2_TABLE)
    state.prefix2_stat_id = p2stat
    return recreateItem(player, state.entry, state)
end

-- Annulment (was Scouring): strip one affix by priority: prefix2 > prefix1 > suffix2 > suffix1
-- Quality is derived from core affixes (suffix1, prefix1, prefix2). suffix2 is a bonus
-- that does not contribute to quality tier, so stripping it leaves quality unchanged.
local function computeQualityFromAffixes(state)
    local q = 1
    if state.suffix1_name then q = q + 1 end
    if state.prefix1_stat_id then q = q + 1 end
    if state.prefix2_stat_id then q = q + 1 end
    return q
end

local function applyAnnulment(player, state)
    if state.prefix2_stat_id then
        state.prefix2_stat_id = nil
    elseif state.prefix1_stat_id then
        state.prefix1_stat_id = nil
    elseif state.suffix2_name then
        state.suffix2_name = nil
    elseif state.suffix1_name then
        state.suffix1_name = nil
    end
    state.quality = computeQualityFromAffixes(state)
    return recreateItem(player, state.entry, state)
end

local function applyChaos(player, state)
    local quality = state.quality
    if quality >= 2 then
        local suffixName, _ = FORGE.rollSuffix(quality, state.slot_name, state.armor_class, state.weapon_type)
        state.suffix1_name = suffixName
    end
    if quality >= 3 then
        local p1stat, _ = FORGE.rollPrefix(FORGE.PREFIX1_TABLE)
        state.prefix1_stat_id = p1stat
    end
    if quality >= 4 then
        local p2stat, _ = FORGE.rollPrefix(FORGE.PREFIX2_TABLE)
        state.prefix2_stat_id = p2stat
    end
    -- Double suffix: 20% for epic, 10% for rare
    -- Dual suffix trades the highest prefix for a second suffix:
    --   Epic: loses prefix2, keeps prefix1 -> 1p/2s epic (exaltable)
    --   Rare: loses prefix1 -> 0p/2s uncommon (regal -> exalt path)
    local dualChance = (quality >= 4 and 20) or (quality >= 3 and 10) or 0
    if dualChance > 0 and math.random(100) <= dualChance then
        local s2, _ = FORGE.rollSuffix(quality, state.slot_name, state.armor_class, state.weapon_type)
        state.suffix2_name = s2
        if quality >= 4 then
            state.prefix2_stat_id = nil
        else
            state.prefix1_stat_id = nil
            state.quality = 2
        end
    else
        state.suffix2_name = nil
    end
    return recreateItem(player, state.entry, state)
end

-- Blessed (was Divine): reroll weapon speed
local function applyBlessed(player, state)
    if not state.weapon_type then return nil end
    local wtype = FORGE.WEAPON_TYPES[state.weapon_type]
    if not wtype then return nil end
    local speeds = wtype.speeds
    state.new_speed = speeds[math.random(#speeds)]
    return recreateItem(player, state.entry, state)
end

-- Full Scouring: reset to common
local function applyFullScour(player, state)
    state.quality = 1
    state.suffix1_name = nil
    state.suffix2_name = nil
    state.prefix1_stat_id = nil
    state.prefix2_stat_id = nil
    return recreateItem(player, state.entry, state)
end

-- Whetstone: increase weapon item level bonus by 1
local function applyWhetstone(player, state)
    state.item_level_override = (state.item_level_override or 0) + 1
    return recreateItem(player, state.entry, state)
end

-- Armorer: increase armor item level bonus by 1
local function applyArmorer(player, state)
    state.item_level_override = (state.item_level_override or 0) + 1
    return recreateItem(player, state.entry, state)
end

-- Mirror: duplicate the item as a legendary copy. Once frozen the item can no longer be modified.
local function applyMirror(player, state)
    local invType = state.inv_type
    local wtype = nil
    if state.weapon_type then
        wtype = FORGE.WEAPON_TYPES[state.weapon_type]
        if wtype then invType = wtype.invType end
    end

    -- Pick a random mirror prefix
    local mirrorPrefix = MIRROR_PREFIXES[math.random(#MIRROR_PREFIXES)]

    -- Build mirrored name: keep custom name as-is, otherwise prepend prefix
    local mirrorName
    if state.name_override then
        mirrorName = state.name_override
    else
        mirrorName = mirrorPrefix .. " " .. state.name
    end

    -- Read actual stats from DB (not recalculated)
    local statsQ = WorldDBQuery(string.format(
        "SELECT stat_type, stat_value FROM virtual_item_stats WHERE entry = %d ORDER BY stat_index",
        state.entry
    ))
    local statArray = {}
    if statsQ then
        repeat
            statArray[#statArray + 1] = {
                type = statsQ:GetUInt32(0),
                value = statsQ:GetInt32(1)
            }
        until not statsQ:NextRow()
    end

    local newEntry = CreateForgeItem({
        itemClass = state.item_class,
        itemSubClass = state.item_subclass,
        invType = invType,
        name = mirrorName,
        quality = 5,  -- Legendary
        requiredLevel = state.mob_level,
        itemLevel = state.item_level,
        displayInfoId = state.display_info_id,
        displaySourceEntry = state.display_source_entry,
        dmgMin = state.dmg_min,
        dmgMax = state.dmg_max,
        dmgType = 0,
        attackSpeed = state.attack_speed,
        armor = state.armor_value,
        block = state.block_value,
        socketCount = state.socket_count,
        stats = statArray,
    })

    if newEntry == 0 then
        player:SendBroadcastMessage("Error: Failed to duplicate item (pool exhausted?).")
        return nil
    end

    -- Copy affix tracking + set prefix3_word (marks item as locked)
    WorldDBExecute(string.format(
        "UPDATE virtual_item_instance SET " ..
        "weapon_type=%s, slot_name=%s, armor_class=%s, " ..
        "suffix1_name=%s, suffix2_name=%s, " ..
        "prefix1_stat_id=%s, prefix2_stat_id=%s, " ..
        "prefix3_stat_id=%s, prefix3_word='%s', " ..
        "item_level_override=%s, name_override=%s, mob_level=%d " ..
        "WHERE entry=%d",
        state.weapon_type and ("'" .. state.weapon_type .. "'") or "NULL",
        state.slot_name and ("'" .. state.slot_name .. "'") or "NULL",
        state.armor_class and ("'" .. state.armor_class .. "'") or "NULL",
        state.suffix1_name and ("'" .. state.suffix1_name:gsub("'", "''") .. "'") or "NULL",
        state.suffix2_name and ("'" .. state.suffix2_name:gsub("'", "''") .. "'") or "NULL",
        state.prefix1_stat_id and tostring(state.prefix1_stat_id) or "NULL",
        state.prefix2_stat_id and tostring(state.prefix2_stat_id) or "NULL",
        state.prefix3_stat_id and tostring(state.prefix3_stat_id) or "NULL",
        mirrorPrefix:gsub("'", "''"),
        state.item_level_override and tostring(state.item_level_override) or "NULL",
        state.name_override and ("'" .. state.name_override:gsub("'", "''") .. "'") or "NULL",
        state.mob_level,
        newEntry
    ))

    -- Copy enchantments from original
    local srcItem = player:GetItemByEntry(state.entry)
    local item = player:AddItem(newEntry, 1)
    if not item then
        player:SendBroadcastMessage("Error: Inventory full! Mirrored item lost.")
        DestroyForgeItem(newEntry)
        return nil
    end

    if srcItem then
        local enchId = srcItem:GetEnchantmentId(0) or 0
        if enchId > 0 then item:SetEnchantment(enchId, 0) end
        for i = 0, 2 do
            local gemEnch = srcItem:GetEnchantmentId(i + 2) or 0
            if gemEnch > 0 then item:SetEnchantment(gemEnch, i + 2) end
        end
    end

    SendForgeItemQuery(player, newEntry)
    return newEntry, mirrorName, {}
end

-- Ancient: adjust item to player's current level
local function applyAncient(player, state)
    state.mob_level = player:GetLevel()
    return recreateItem(player, state.entry, state)
end

-- Transmog: destroy source bag item, apply its appearance to equipped forge item
local function applyTransmog(player, state, pending)
    local equippedEntry = pending.extra.equippedEntry
    local sourceDisplayId = pending.extra.displayId
    local sourceDisplayEntry = pending.extra.displayEntry
    local sourceEntry = pending.extra.sourceEntry

    -- Re-validate equipped item still exists
    local eqState = readForgeItemState(equippedEntry)
    if not eqState then
        player:SendBroadcastMessage("Equipped forge item no longer exists.")
        return nil
    end

    -- Apply source's appearance: change item class/subclass/invType so pool
    -- allocation uses the correct block (matching the source's display in DBC).
    -- weapon_type/slot_name/armor_class are NOT changed -- stats stay the same.
    eqState.item_class = pending.extra.sourceItemClass or eqState.item_class
    eqState.item_subclass = pending.extra.sourceItemSubclass or eqState.item_subclass
    eqState.inv_type = pending.extra.sourceInvType or eqState.inv_type
    eqState.display_info_id = sourceDisplayId
    eqState.display_source_entry = sourceDisplayEntry

    local newEntry, newName, newStats = recreateItem(player, equippedEntry, eqState)
    if not newEntry then
        return nil
    end

    -- Destroy the source bag item AFTER recreate succeeds (safe)
    player:RemoveItem(sourceEntry, 1)
    if sourceEntry >= 500000 then
        DestroyForgeItem(sourceEntry)
    end

    return newEntry, newName, newStats
end

-- Identify: apply the name stored during addon input flow
local function applyIdentify(player, state, pending)
    if not pending.extra or not pending.extra.newName then
        player:SendBroadcastMessage("No name provided.")
        return nil
    end
    state.name_override = pending.extra.newName
    return recreateItem(player, state.entry, state)
end

-- Portal: teleport to bind point
local function applyPortal(player, state, pending)
    local q = CharDBQuery(string.format(
        "SELECT posX, posY, posZ, mapId FROM character_homebind WHERE guid = %d",
        player:GetGUIDLow()
    ))
    if q then
        local x = q:GetFloat(0)
        local y = q:GetFloat(1)
        local z = q:GetFloat(2)
        local mapId = q:GetUInt32(3)
        player:Teleport(mapId, x, y, z, 0)
    else
        player:SendBroadcastMessage("No bind point found.")
        return nil
    end
    return 1, "Portal", {}
end

-- Awakener: destroy rare item, give Influenced Exalted Orb with enchantment
local function applyAwakener(player, state)
    local prefixStat = state.prefix1_stat_id
    local prefixLabel = STAT_NAMES[prefixStat] or ("Stat " .. tostring(prefixStat))
    local enchantId = INFLUENCE_ENCHANTS[prefixStat]
    if not enchantId then
        player:SendBroadcastMessage("Error: No influence enchantment for stat " .. tostring(prefixStat))
        return nil
    end

    -- Give Influenced Exalted Orb BEFORE destroying target (fail safe)
    local orb = player:AddItem(ITEM_ORB_INFLUENCED, 1)
    if not orb then
        player:SendBroadcastMessage("Error: Inventory full! Cannot create Influenced Exalted Orb.")
        return nil
    end

    -- Apply the influence enchantment to the orb (green tooltip text)
    orb:SetEnchantment(enchantId, 0)

    -- Now destroy the target item (safe -- orb was created successfully)
    player:RemoveItem(state.entry, 1)
    DestroyForgeItem(state.entry)

    player:SendBroadcastMessage(string.format(
        "Item destroyed. Received Influenced Exalted Orb (Influence: %s)", prefixLabel
    ))
    return 1, "Awakener", {}
end

-- Influenced: upgrade rare->epic with guaranteed prefix from orb enchantment
local function applyInfluenced(player, state, pending)
    -- Read influence stat from the pending data (set in onOrbUse from enchantment)
    local influenceStat = pending and pending.extra and pending.extra.influenceStat
    if not influenceStat then
        player:SendBroadcastMessage("No influence data found on orb.")
        return nil
    end
    local influenceLabel = STAT_NAMES[influenceStat] or ("Stat " .. tostring(influenceStat))

    -- Upgrade to epic with the guaranteed prefix
    state.quality = 4
    state.prefix2_stat_id = influenceStat

    local newEntry, newName, newStats = recreateItem(player, state.entry, state)
    if newEntry then
        player:SendBroadcastMessage(string.format(
            "Influence applied: %s (guaranteed prefix: %s)", newName or "item", influenceLabel
        ))
    end
    return newEntry, newName, newStats
end

-- Jeweler: reroll socket count based on probability table
local JEWELER_PROBS = {
    [0] = { [0] = 0.00, [1] = 0.70, [2] = 0.23, [3] = 0.07 },
    [1] = { [0] = 0.76, [1] = 0.00, [2] = 0.17, [3] = 0.07 },
    [2] = { [0] = 0.56, [1] = 0.39, [2] = 0.00, [3] = 0.05 },
}

local function applyJeweler(player, state)
    local current = state.socket_count
    local probs = JEWELER_PROBS[current]
    if not probs then
        player:SendBroadcastMessage("Jeweler's Orb cannot be applied to this item.")
        return nil
    end

    local roll = math.random()
    local cumulative = 0
    local newCount = current
    for sockets = 0, 3 do
        cumulative = cumulative + probs[sockets]
        if roll <= cumulative then
            newCount = sockets
            break
        end
    end

    state.socket_count = newCount
    return recreateItem(player, state.entry, state)
end

-- Vaal corruption prefixes (randomly selected, like Mirror prefixes)
local VAAL_PREFIXES = { "Corrupted", "Vaal", "Nightmarish" }

-- Vaal: corrupt an item with three independent 33% rolls:
--   1) Poof: item is destroyed
--   2) Chaos: reroll affixes (same as Chaos Orb)
--   3) +20 ilevels: adds 20 to item_level_override (no cap, stacks)
-- After rolls, item is locked (prefix3_word) and set to Legendary quality.
-- Poof aura: if poof triggered (item gone).
-- Big Vaals aura: +20 hit AND item already had >=20 ilevel override AND no poof.
local function applyVaal(player, state)
    -- Three independent 33% rolls
    local rollPoof = math.random(100) <= 33
    local rollChaos = math.random(100) <= 33
    local rollIlevel = math.random(100) <= 33

    -- Remove "No Vaals" before applying outcome aura
    if player:HasAura(SPELL_VAAL_AURA) then
        player:RemoveAura(SPELL_VAAL_AURA)
    end

    -- Apply chaos reroll (same logic as Chaos Orb)
    if rollChaos then
        local quality = state.quality
        if quality >= 2 then
            local suffixName, _ = FORGE.rollSuffix(quality, state.slot_name, state.armor_class, state.weapon_type)
            state.suffix1_name = suffixName
        end
        if quality >= 3 then
            local p1stat, _ = FORGE.rollPrefix(FORGE.PREFIX1_TABLE)
            state.prefix1_stat_id = p1stat
        end
        if quality >= 4 then
            local p2stat, _ = FORGE.rollPrefix(FORGE.PREFIX2_TABLE)
            state.prefix2_stat_id = p2stat
        end
    end

    -- Apply +20 ilevel bonus
    if rollIlevel then
        state.item_level_override = (state.item_level_override or 0) + 20
    end

    -- Lock the item: set corruption prefix and Legendary display quality
    state.prefix3_word = VAAL_PREFIXES[math.random(#VAAL_PREFIXES)]
    state.display_quality = 5

    -- Poof: skip recreation (recreateItem destroys the old item, so skipping = item gone)
    if rollPoof then
        player:RemoveItem(state.entry, 1)
        DestroyForgeItem(state.entry)
        player:SendBroadcastMessage("|cffff0000Poof!|r")
        if player:HasAura(SPELL_VAAL_SUCCESS_AURA) then
            player:RemoveAura(SPELL_VAAL_SUCCESS_AURA)
        end
        player:AddAura(SPELL_VAAL_FAIL_AURA, player)
        return 1, nil, nil
    end

    local newEntry, newName, newStats = recreateItem(player, state.entry, state)
    if not newEntry then return nil end

    -- Build outcome message
    local parts = {}
    if rollChaos then parts[#parts + 1] = "affixes rerolled" end
    if rollIlevel then parts[#parts + 1] = "+20 item levels" end
    if #parts == 0 then parts[#parts + 1] = "locked" end
    local outcomeStr = table.concat(parts, ", ")
    player:SendBroadcastMessage(string.format(
        "|cffff8000Vaal Orb|r: %s (%s)", newName or "item", outcomeStr
    ))

    -- Big Vaals: applied when +20 ilevel roll hits (and no poof)
    if rollIlevel then
        if player:HasAura(SPELL_VAAL_FAIL_AURA) then
            player:RemoveAura(SPELL_VAAL_FAIL_AURA)
        end
        player:AddAura(SPELL_VAAL_SUCCESS_AURA, player)
    end

    return newEntry, newName, newStats
end

local ORB_APPLY = {
    alteration = applyAlteration,
    transmutation = applyTransmutation,
    regal = applyRegal,
    exalted = applyExalted,
    alchemy = applyAlchemy,
    annulment = applyAnnulment,
    chaos = applyChaos,
    blessed = applyBlessed,
    fullscour = applyFullScour,
    whetstone = applyWhetstone,
    armorer = applyArmorer,
    mirror = applyMirror,
    ancient = applyAncient,
    transmog = applyTransmog,
    identify = applyIdentify,
    portal = applyPortal,
    awakener = applyAwakener,
    influenced = applyInfluenced,
    jeweler = applyJeweler,
    vaal = applyVaal,
}

-- =============================================================================
-- Item ON_USE Handler (instant spell, item-targeting cursor)
-- =============================================================================

local function onOrbUse(event, player, item, target)
    -- Block use while already casting (prevents interrupting a pending orb cast)
    if player:IsCasting() then return false end

    local orbEntry = item:GetEntry()
    local orbType = ENTRY_TO_ORB[orbEntry]
    if not orbType then return false end

    local def = ORB_DEFS[orbType]
    if not def then return false end

    -- Portal scroll: no target needed, just cast
    if def.noTarget then
        local playerGuid = player:GetGUIDLow()
        pendingOrb[playerGuid] = {
            orbType = orbType,
            targetEntry = 0,
            orbItemEntry = orbEntry,
            timestamp = os.time(),
        }
        player:CastSpell(player, def.castSpell, false)
        return false
    end

    -- Validate target item exists
    if not target or not target.GetEntry then
        player:SendBroadcastMessage("No target item selected.")
        return false
    end

    local targetEntry = target:GetEntry()

    -- Divine Orb (transmog): target a bag item to copy its appearance to equipped forge item
    if def.usesTransmogConfirm then
        if target:IsEquipped() then
            player:SendBroadcastMessage("Target the bag item you want to copy the appearance FROM.")
            return false
        end

        -- Read target's display info and item class/subclass
        local sourceInvType = 0
        local sourceDisplayId = 0
        local sourceDisplayEntry = targetEntry
        local sourceItemClass = 0
        local sourceItemSubclass = 0

        if targetEntry >= 500000 then
            local tq = WorldDBQuery(string.format(
                "SELECT inv_type, display_info_id, item_class, item_subclass FROM virtual_item_instance WHERE entry = %d", targetEntry
            ))
            if tq then
                sourceInvType = tq:GetUInt32(0)
                sourceDisplayId = tq:GetUInt32(1)
                sourceItemClass = tq:GetUInt32(2)
                sourceItemSubclass = tq:GetUInt32(3)
            end
        else
            local tq = WorldDBQuery(string.format(
                "SELECT InventoryType, displayid, class, subclass FROM item_template WHERE entry = %d", targetEntry
            ))
            if tq then
                sourceInvType = tq:GetUInt32(0)
                sourceDisplayId = tq:GetUInt32(1)
                sourceItemClass = tq:GetUInt32(2)
                sourceItemSubclass = tq:GetUInt32(3)
            end
        end

        if sourceInvType == 0 or sourceDisplayId == 0 then
            player:SendBroadcastMessage("Cannot read item display data.")
            return false
        end

        -- Find the equipped forge item in the matching slot
        local slots = INV_TYPE_SLOTS[sourceInvType]
        if not slots then
            player:SendBroadcastMessage("Cannot determine equip slot for this item type.")
            return false
        end

        local equippedEntry = 0
        local equippedName = "equipped item"
        for _, slotId in ipairs(slots) do
            local eqItem = player:GetItemByPos(255, slotId)
            if eqItem then
                local eEntry = eqItem:GetEntry()
                if eEntry >= 500000 and IsForgeItem(eEntry) then
                    equippedEntry = eEntry
                    equippedName = eqItem:GetName()
                    break
                end
            end
        end

        if equippedEntry == 0 then
            player:SendBroadcastMessage("No forge item equipped in that slot.")
            return false
        end

        -- Store pending and send confirmation to addon
        local playerGuid = player:GetGUIDLow()
        local sourceName = target:GetName()
        local sourceQuality = target:GetQuality()

        -- Map inv_type to slot name for the popup
        local INVTYPE_SLOT_NAMES = {
            [1] = "Head", [2] = "Neck", [3] = "Shoulder", [4] = "Chest",
            [5] = "Chest", [6] = "Waist", [7] = "Legs", [8] = "Feet",
            [9] = "Wrist", [10] = "Hands", [11] = "Finger", [12] = "Trinket",
            [13] = "Main Hand", [14] = "Off Hand", [15] = "Ranged",
            [16] = "Back", [17] = "Main Hand", [20] = "Chest",
            [21] = "Main Hand", [22] = "Off Hand", [23] = "Off Hand",
            [25] = "Ranged", [26] = "Ranged",
        }
        local slotName = INVTYPE_SLOT_NAMES[sourceInvType] or "equipment"

        -- Store in DB (orb_pending) because addon messages run in WORLD state, not MAP state.
        WorldDBExecute(string.format(
            "REPLACE INTO orb_pending (player_guid, orb_type, target_entry, orb_item_entry, timestamp, " ..
            "equipped_entry, source_entry, display_id, display_entry, source_item_class, source_item_subclass, source_inv_type) " ..
            "VALUES (%d, 'transmog', 0, %d, %d, %d, %d, %d, %d, %d, %d, %d)",
            playerGuid, orbEntry, os.time(),
            equippedEntry, targetEntry, sourceDisplayId, sourceDisplayEntry,
            sourceItemClass, sourceItemSubclass, sourceInvType
        ))

        -- "DV:<quality>|<slotName>|<sourceName>" -> addon shows confirmation popup
        player:SendAddonMessage(IDENTIFY_PREFIX, "DV:" .. sourceQuality .. "|" .. slotName .. "|" .. sourceName, 7, player)
        return false
    end

    -- Standard forge item targeting
    if targetEntry < 500000 then
        player:SendBroadcastMessage("That is not a forge item.")
        return false
    end

    if target:IsEquipped() then
        player:SendBroadcastMessage("Unequip the item first. Cannot craft equipped items.")
        return false
    end

    local state = readForgeItemState(targetEntry)
    if not state then
        player:SendBroadcastMessage("Could not read forge item data.")
        return false
    end

    local canApply, rejectMsg = def.canApply(state)
    if not canApply then
        player:SendBroadcastMessage(rejectMsg or (def.name .. " cannot be applied to this item."))
        return false
    end

    -- Locked items (mirrored/corrupted) cannot be modified except by transmog and identify
    if state.prefix3_word then
        player:SendBroadcastMessage("This item is locked and cannot be modified.")
        return false
    end

    -- Scroll of Identification: send addon msg to show editbox popup, wait for response
    -- Uses DB (orb_pending) because addon messages run in WORLD state, not MAP state.
    if def.usesAddonInput then
        local playerGuid = player:GetGUIDLow()
        WorldDBExecute(string.format(
            "REPLACE INTO orb_pending (player_guid, orb_type, target_entry, orb_item_entry, timestamp) " ..
            "VALUES (%d, 'identify', %d, %d, %d)",
            playerGuid, targetEntry, orbEntry, os.time()
        ))
        player:SendAddonMessage(IDENTIFY_PREFIX, "ID:" .. (state.name or "item"), 7, player)
        return false
    end

    -- Influenced Exalted Orb: read influence from the orb's enchantment
    local orbExtra = nil
    if def.needsInfluence then
        local enchId = item:GetEnchantmentId(0) or 0
        local influenceStat = ENCHANT_TO_STAT[enchId]
        if not influenceStat then
            player:SendBroadcastMessage("This orb has no influence. Use an Awakener's Orb to create one.")
            return false
        end
        local infLabel = STAT_NAMES[influenceStat] or ("Stat " .. tostring(influenceStat))
        player:SendBroadcastMessage(string.format(
            "Applying influence: |cff00ff00%s|r (guaranteed prefix)", infLabel
        ))
        orbExtra = { influenceStat = influenceStat }
    end

    local playerGuid = player:GetGUIDLow()
    pendingOrb[playerGuid] = {
        orbType = orbType,
        targetEntry = targetEntry,
        orbItemEntry = orbEntry,
        timestamp = os.time(),
        extra = orbExtra,
    }

    player:CastSpell(player, def.castSpell, false)
    return false
end

-- =============================================================================
-- Cast Completion Handler (1.5s cast bar finished)
-- =============================================================================

local function onOrbCastComplete(event, spell)
    local player = spell:GetCaster()
    if not player then return end

    local spellId = spell:GetEntry()
    local orbType = CAST_SPELL_TO_ORB[spellId]
    if not orbType then return end

    local playerGuid = player:GetGUIDLow()
    local def = ORB_DEFS[orbType]

    -- Addon-based orbs (identify, transmog): read pending from DB, not local table.
    -- CastSpell was called from WORLD state, but this fires in MAP state.
    if def.usesAddonInput or def.usesTransmogConfirm then
        local dbq = WorldDBQuery(string.format(
            "SELECT orb_type, target_entry, orb_item_entry, timestamp, " ..
            "new_name, equipped_entry, source_entry, display_id, display_entry, " ..
            "source_item_class, source_item_subclass, source_inv_type " ..
            "FROM orb_pending WHERE player_guid = %d",
            playerGuid
        ))
        if not dbq then
            player:SendBroadcastMessage("No pending orb operation.")
            return
        end

        local dbOrbType = dbq:GetString(0)
        local dbTimestamp = dbq:GetUInt32(3)
        local dbOrbItemEntry = dbq:GetUInt32(2)

        -- Clean up DB row
        WorldDBExecute(string.format(
            "DELETE FROM orb_pending WHERE player_guid = %d", playerGuid
        ))

        if os.time() - dbTimestamp > 60 then
            player:SendBroadcastMessage("Orb operation has expired.")
            return
        end

        if dbOrbType ~= orbType then
            player:SendBroadcastMessage("Orb type mismatch.")
            return
        end

        -- Build pending table from DB
        local pending = {
            orbType = dbOrbType,
            targetEntry = dbq:GetUInt32(1),
            orbItemEntry = dbOrbItemEntry,
            timestamp = dbTimestamp,
            extra = {},
        }

        if orbType == "identify" then
            local nm = dbq:GetString(4)
            pending.extra.newName = (nm ~= "") and nm or nil
        elseif orbType == "transmog" then
            pending.extra.equippedEntry = dbq:GetUInt32(5)
            pending.extra.sourceEntry = dbq:GetUInt32(6)
            pending.extra.displayId = dbq:GetUInt32(7)
            pending.extra.displayEntry = dbq:GetUInt32(8)
            pending.extra.sourceItemClass = dbq:GetUInt32(9)
            pending.extra.sourceItemSubclass = dbq:GetUInt32(10)
            pending.extra.sourceInvType = dbq:GetUInt32(11)
        end

        -- Apply the orb effect
        local applyFn = ORB_APPLY[orbType]
        if not applyFn then return end

        if orbType == "transmog" then
            local newEntry, newName = applyFn(player, nil, pending)
            if newEntry and newEntry > 0 then
                player:RemoveItem(dbOrbItemEntry, 1)
                syncVaalAura(player)
                local q = 0
                if newEntry > 1 then
                    local st = readForgeItemState(newEntry)
                    if st then q = st.quality end
                end
                local QUALITY_COLORS = {
                    [1] = "|cffffffff", [2] = "|cff1eff00", [3] = "|cff0070dd", [4] = "|cffa335ee", [5] = "|cffff8000",
                }
                local qColor = QUALITY_COLORS[q] or ""
                player:SendBroadcastMessage(string.format(
                    "%s applied: %s%s|r", def.name, qColor, newName or "item"
                ))
            end
        else
            -- Identify: standard apply + report
            local state = readForgeItemState(pending.targetEntry)
            if not state then
                player:SendBroadcastMessage("Target item no longer exists.")
                return
            end
            local newEntry, newName = applyFn(player, state, pending)
            if newEntry then
                player:RemoveItem(dbOrbItemEntry, 1)
                syncVaalAura(player)
                local QUALITY_COLORS = {
                    [1] = "|cffffffff", [2] = "|cff1eff00", [3] = "|cff0070dd", [4] = "|cffa335ee", [5] = "|cffff8000",
                }
                local qColor = QUALITY_COLORS[state.quality] or ""
                player:SendBroadcastMessage(string.format(
                    "%s applied: %s%s|r", def.name, qColor, newName or "item"
                ))
            end
        end
        return
    end

    -- Standard orbs: read from local pendingOrb (same MAP state)
    local pending = pendingOrb[playerGuid]
    pendingOrb[playerGuid] = nil

    if not pending then
        player:SendBroadcastMessage("No pending orb operation.")
        return
    end

    if os.time() - pending.timestamp > 60 then
        player:SendBroadcastMessage("Orb operation has expired.")
        return
    end

    if pending.orbType ~= orbType then
        player:SendBroadcastMessage("Orb type mismatch.")
        return
    end

    -- Portal scroll: no target to validate
    if def.noTarget then
        local applyFn = ORB_APPLY[orbType]
        if not applyFn then return end
        local result = applyFn(player, nil, pending)
        if result then
            player:RemoveItem(pending.orbItemEntry, 1)
            syncVaalAura(player)
        end
        return
    end

    -- Standard forge item flow
    local state = readForgeItemState(pending.targetEntry)
    if not state then
        player:SendBroadcastMessage("Target item no longer exists.")
        return
    end

    local canApply2, rejectMsg2 = def.canApply(state)
    if not canApply2 then
        player:SendBroadcastMessage(rejectMsg2 or (def.name .. " can no longer be applied to this item."))
        return
    end

    -- Re-check locked status at cast completion (transmog/identify handled separately)
    if state.prefix3_word then
        player:SendBroadcastMessage("This item is locked and cannot be modified.")
        return
    end

    local targetItem = player:GetItemByEntry(pending.targetEntry)
    if not targetItem then
        player:SendBroadcastMessage("Target item no longer in your bags.")
        return
    end

    local applyFn = ORB_APPLY[orbType]
    if not applyFn then
        player:SendBroadcastMessage("Orb effect not implemented: " .. orbType)
        return
    end

    local newEntry, newName, newStats = applyFn(player, state, pending)
    if not newEntry then
        player:SendBroadcastMessage("Failed to apply " .. def.name .. ".")
        return
    end

    -- Consume one orb from the player's inventory
    player:RemoveItem(pending.orbItemEntry, 1)
    syncVaalAura(player)

    -- Report result (skip for portal, awakener, influenced, vaal which handle their own messages)
    if orbType ~= "portal" and orbType ~= "awakener" and orbType ~= "influenced" and orbType ~= "vaal" then
        local QUALITY_COLORS = {
            [1] = "|cffffffff", [2] = "|cff1eff00", [3] = "|cff0070dd", [4] = "|cffa335ee", [5] = "|cffff8000",
        }
        local QUALITY_LABELS = {
            [1] = "Common", [2] = "Uncommon", [3] = "Rare", [4] = "Epic", [5] = "Legendary",
        }
        -- Read quality from the new item if possible (mirror changes quality)
        local q = state.quality
        if newEntry and newEntry > 1 then
            local newState = readForgeItemState(newEntry)
            if newState then q = newState.quality end
        end
        local qColor = QUALITY_COLORS[q] or ""
        local qLabel = QUALITY_LABELS[q] or "?"
        player:SendBroadcastMessage(string.format(
            "%s applied: %s%s|r (%s)",
            def.name, qColor, newName or "item", qLabel
        ))
    end
end

-- =============================================================================
-- Addon Message Handler (WORLD state -- uses DB for cross-state data)
-- =============================================================================
-- Runs in WORLD state. Item ON_USE and cast completion run in MAP state.
-- All shared data goes through orb_pending DB table.

local function onAddonMessage(event, sender, msgType, prefix, msg, target)
    if prefix ~= IDENTIFY_PREFIX then return end
    if not sender then return end
    if not msg or #msg < 2 then return end

    local playerGuid = sender:GetGUIDLow()

    -- Divine Orb confirmation: "D:OK" or "D:NO"
    if msg == "D:OK" or msg == "D:NO" then
        local q = WorldDBQuery(string.format(
            "SELECT orb_item_entry, timestamp FROM orb_pending " ..
            "WHERE player_guid = %d AND orb_type = 'transmog'",
            playerGuid
        ))
        if not q then return end

        if msg == "D:NO" then
            WorldDBExecute(string.format(
                "DELETE FROM orb_pending WHERE player_guid = %d", playerGuid
            ))
            return
        end

        -- D:OK -- verify not expired
        local timestamp = q:GetUInt32(1)
        if os.time() - timestamp > 60 then
            WorldDBExecute(string.format(
                "DELETE FROM orb_pending WHERE player_guid = %d", playerGuid
            ))
            sender:SendBroadcastMessage("Transmog request has expired.")
            return
        end

        -- Start the cast (spell event fires in MAP state, reads orb_pending there)
        local def = ORB_DEFS["transmog"]
        sender:CastSpell(sender, def.castSpell, false)
        return
    end

    -- Scroll of Identification: "N:<newName>"
    if msg:sub(1, 2) ~= "N:" then return end

    local newName = msg:sub(3)

    local q = WorldDBQuery(string.format(
        "SELECT target_entry, orb_item_entry, timestamp FROM orb_pending " ..
        "WHERE player_guid = %d AND orb_type = 'identify'",
        playerGuid
    ))
    if not q then return end

    -- Expire after 60 seconds
    local timestamp = q:GetUInt32(2)
    if os.time() - timestamp > 60 then
        WorldDBExecute(string.format(
            "DELETE FROM orb_pending WHERE player_guid = %d", playerGuid
        ))
        sender:SendBroadcastMessage("Rename timed out.")
        return
    end

    -- Validate name: 3-32 chars, alphanumeric + spaces + apostrophes + hyphens
    newName = newName:match("^%s*(.-)%s*$")  -- trim
    if not newName or #newName < 3 or #newName > 32 then
        sender:SendBroadcastMessage("Name must be 3-32 characters.")
        return
    end
    if newName:find("[^%w%s'%-]") then
        sender:SendBroadcastMessage("Name can only contain letters, numbers, spaces, apostrophes, and hyphens.")
        return
    end

    -- Store the validated name in DB and start the cast
    WorldDBExecute(string.format(
        "UPDATE orb_pending SET new_name = '%s' WHERE player_guid = %d",
        newName:gsub("'", "''"), playerGuid
    ))

    local def = ORB_DEFS["identify"]
    sender:CastSpell(sender, def.castSpell, false)
end

-- =============================================================================
-- Register Events
-- =============================================================================

-- Register ON_USE (event 2) for each orb item
for name, def in pairs(ORB_DEFS) do
    if def.entry and def.entry > 0 then
        RegisterItemEvent(def.entry, 2, onOrbUse)
    end
end

-- Register ON_CAST (event 1) for each cast spell
for name, def in pairs(ORB_DEFS) do
    if def.castSpell and def.castSpell > 0 then
        RegisterSpellEvent(def.castSpell, 1, onOrbCastComplete)
    end
end

-- Addon message handler for Scroll of Identification + Divine Orb confirmation (event 30 = ADDON_MESSAGE)
RegisterServerEvent(30, onAddonMessage)

-- Sync "No Vaals" aura on login (event 3 = PLAYER_EVENT_ON_LOGIN)
RegisterPlayerEvent(3, function(event, player)
    syncVaalAura(player)
end)

-- Clean up pending state on logout
RegisterPlayerEvent(4, function(event, player)
    local guid = player:GetGUIDLow()
    pendingOrb[guid] = nil
    WorldDBExecute(string.format(
        "DELETE FROM orb_pending WHERE player_guid = %d", guid
    ))
end)

-- Sync "No Vaals" aura when looting a Vaal Orb (event 29 = PLAYER_EVENT_ON_LOOT_ITEM)
RegisterPlayerEvent(29, function(event, player, item, count)
    if item and item:GetEntry() == ITEM_ORB_VAAL then
        syncVaalAura(player)
    end
end)

local orbCount = 0
for _ in pairs(ORB_DEFS) do orbCount = orbCount + 1 end
print("[ForgeLoot] PoE Orbs loaded (" .. orbCount .. " orb types)")
