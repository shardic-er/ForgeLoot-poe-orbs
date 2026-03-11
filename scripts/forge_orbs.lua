-- @load-order 20
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
-- Orb Definitions
-- =============================================================================

local ORB_DEFS = {
    transmutation = {
        entry = ITEM_ORB_TRANSMUTATION,
        spell = SPELL_ORB_TRANSMUTATION,
        castSpell = SPELL_ORB_TRANSMUTATION_CAST,
        name = "Orb of Transmutation",
        canApply = function(state)
            if state.quality == 1 then return true end
            if state.quality >= 2 and state.suffix_name then return true end
            return false
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
            return state.quality == 3
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
    scouring = {
        entry = ITEM_ORB_SCOURING,
        spell = SPELL_ORB_SCOURING,
        castSpell = SPELL_ORB_SCOURING_CAST,
        name = "Orb of Scouring",
        canApply = function(state)
            return state.quality >= 2
        end,
    },
    chaos = {
        entry = ITEM_ORB_CHAOS,
        spell = SPELL_ORB_CHAOS,
        castSpell = SPELL_ORB_CHAOS_CAST,
        name = "Orb of Chaos",
        canApply = function(state)
            return state.quality >= 2
        end,
    },
    divine = {
        entry = ITEM_ORB_DIVINE,
        spell = SPELL_ORB_DIVINE,
        castSpell = SPELL_ORB_DIVINE_CAST,
        name = "Divine Orb",
        canApply = function(state)
            return state.weapon_type ~= nil
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
-- Pending State (MAP-state Lua table, keyed by player GUID)
-- =============================================================================
-- Stores the validated target entry between ON_USE (instant) and ON_CAST (1.5s).

local pendingOrb = {}  -- playerGuid -> { orbType, targetEntry, orbItemEntry, timestamp }

-- =============================================================================
-- Item State Reader
-- =============================================================================

local function readForgeItemState(entry)
    local q = CharDBQuery(string.format(
        "SELECT quality, mob_level, item_level, weapon_type, slot_name, " ..
        "armor_class, suffix_name, prefix1_stat_id, prefix2_stat_id, " ..
        "item_class, item_subclass, inv_type, name, attack_speed, " ..
        "display_info_id, display_source_entry, dmg_min, dmg_max, " ..
        "armor, block, socket_count " ..
        "FROM virtual_item_instance WHERE entry = %d", entry
    ))
    if not q then return nil end

    return {
        entry = entry,
        quality = q:GetUInt32(0),
        mob_level = q:GetUInt32(1),
        item_level = q:GetUInt32(2),
        weapon_type = q:IsNull(3) and nil or q:GetString(3),
        slot_name = q:IsNull(4) and nil or q:GetString(4),
        armor_class = q:IsNull(5) and nil or q:GetString(5),
        suffix_name = q:IsNull(6) and nil or q:GetString(6),
        prefix1_stat_id = q:IsNull(7) and nil or q:GetUInt32(7),
        prefix2_stat_id = q:IsNull(8) and nil or q:GetUInt32(8),
        item_class = q:GetUInt32(9),
        item_subclass = q:GetUInt32(10),
        inv_type = q:GetUInt32(11),
        name = q:GetString(12),
        attack_speed = q:GetUInt32(13),
        display_info_id = q:GetUInt32(14),
        display_source_entry = q:GetUInt32(15),
        dmg_min = q:GetFloat(16),
        dmg_max = q:GetFloat(17),
        armor_value = q:GetUInt32(18),
        block_value = q:GetUInt32(19),
        socket_count = q:GetUInt32(20),
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
-- Destroys the old forge item and creates a new one with recalculated stats.
-- Carries over: display model, socket count, enchantments, socketed gems.

local function recreateItem(player, oldEntry, state)
    local level = state.mob_level
    local quality = state.quality
    local wtype = nil

    if state.weapon_type then
        wtype = FORGE.WEAPON_TYPES[state.weapon_type]
    end

    -- Recalculate item level
    local itemLevel = state.item_level_override or FORGE.computeItemLevel(level, quality)

    -- Get suffix data
    local suffix = state.suffix_name and FORGE.SUFFIXES[state.suffix_name] or nil

    -- Regenerate stats from scratch
    local weaponSize = wtype and getWeaponSize(wtype) or nil
    local stats = FORGE.generateItemStats(
        level, quality, state.slot_name, weaponSize,
        suffix, state.prefix1_stat_id, state.prefix2_stat_id
    )

    -- Recalculate weapon damage
    local dmgMin, dmgMax, speed = 0, 0, 0
    local invType = state.inv_type

    if wtype then
        dmgMin, dmgMax, speed = FORGE.computeWeaponDamage(level, quality, state.weapon_type)

        -- Handle speed override (Divine Orb) or preserve old speed
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
        invType = wtype.invType
        if quality >= 2 and FORGE.isCasterWeapon(state.weapon_type, suffix) then
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

    -- Regenerate name
    local nouns
    if state.weapon_type then
        nouns = FORGE.WEAPON_NOUNS[state.weapon_type] or {"Weapon"}
    else
        nouns = FORGE.getNouns(state.slot_name, state.armor_class)
    end
    local itemName = FORGE.randomName(
        nouns, quality, state.suffix_name,
        state.prefix1_stat_id, state.prefix2_stat_id
    )

    -- Build stat array
    local statArray = {}
    for statType, statValue in pairs(stats) do
        statArray[#statArray + 1] = { type = statType, value = statValue }
    end

    -- Create new forge item
    local newEntry = CreateForgeItem({
        itemClass = state.item_class,
        itemSubClass = state.item_subclass,
        invType = invType,
        name = itemName,
        quality = quality,
        requiredLevel = level,
        itemLevel = itemLevel,
        displayInfoId = state.display_info_id,
        displaySourceEntry = state.display_source_entry,
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
    CharDBExecute(string.format(
        "UPDATE virtual_item_instance SET " ..
        "weapon_type=%s, slot_name=%s, armor_class=%s, " ..
        "suffix_name=%s, prefix1_stat_id=%s, prefix2_stat_id=%s, " ..
        "mob_level=%d " ..
        "WHERE entry=%d",
        state.weapon_type and ("'" .. state.weapon_type .. "'") or "NULL",
        state.slot_name and ("'" .. state.slot_name .. "'") or "NULL",
        state.armor_class and ("'" .. state.armor_class .. "'") or "NULL",
        state.suffix_name and ("'" .. state.suffix_name:gsub("'", "''") .. "'") or "NULL",
        state.prefix1_stat_id and tostring(state.prefix1_stat_id) or "NULL",
        state.prefix2_stat_id and tostring(state.prefix2_stat_id) or "NULL",
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
    player:RemoveItemByEntry(oldEntry, 1)
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

local function applyTransmutation(player, state)
    if state.quality == 1 then
        state.quality = 2
        local suffixName, _ = FORGE.rollSuffix(2, state.slot_name, state.armor_class, state.weapon_type)
        state.suffix_name = suffixName
    else
        local suffixName, _ = FORGE.rollSuffix(
            state.quality, state.slot_name, state.armor_class, state.weapon_type
        )
        state.suffix_name = suffixName
    end
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

local function applyAlchemy(player, state)
    state.quality = 4
    local suffixName, _ = FORGE.rollSuffix(4, state.slot_name, state.armor_class, state.weapon_type)
    state.suffix_name = suffixName
    local p1stat, _ = FORGE.rollPrefix(FORGE.PREFIX1_TABLE)
    state.prefix1_stat_id = p1stat
    local p2stat, _ = FORGE.rollPrefix(FORGE.PREFIX2_TABLE)
    state.prefix2_stat_id = p2stat
    return recreateItem(player, state.entry, state)
end

local function applyScouring(player, state)
    if state.quality == 4 then
        state.quality = 3
        state.prefix2_stat_id = nil
    elseif state.quality == 3 then
        state.quality = 2
        state.prefix1_stat_id = nil
    elseif state.quality == 2 then
        state.quality = 1
        state.suffix_name = nil
    end
    return recreateItem(player, state.entry, state)
end

local function applyChaos(player, state)
    local quality = state.quality
    if quality >= 2 then
        local suffixName, _ = FORGE.rollSuffix(quality, state.slot_name, state.armor_class, state.weapon_type)
        state.suffix_name = suffixName
    end
    if quality >= 3 then
        local p1stat, _ = FORGE.rollPrefix(FORGE.PREFIX1_TABLE)
        state.prefix1_stat_id = p1stat
    end
    if quality >= 4 then
        local p2stat, _ = FORGE.rollPrefix(FORGE.PREFIX2_TABLE)
        state.prefix2_stat_id = p2stat
    end
    return recreateItem(player, state.entry, state)
end

local function applyDivine(player, state)
    if not state.weapon_type then return nil end
    local wtype = FORGE.WEAPON_TYPES[state.weapon_type]
    if not wtype then return nil end
    local speeds = wtype.speeds
    state.new_speed = speeds[math.random(#speeds)]
    return recreateItem(player, state.entry, state)
end

local ORB_APPLY = {
    transmutation = applyTransmutation,
    regal = applyRegal,
    exalted = applyExalted,
    alchemy = applyAlchemy,
    scouring = applyScouring,
    chaos = applyChaos,
    divine = applyDivine,
}

-- =============================================================================
-- Item ON_USE Handler (instant spell, item-targeting cursor)
-- =============================================================================
-- Validates the target forge item, stores pending state, casts the 1.5s spell.
-- Returns false to prevent the item from being consumed by the instant spell.

local function onOrbUse(event, player, item, target)
    local orbEntry = item:GetEntry()
    local orbType = ENTRY_TO_ORB[orbEntry]
    if not orbType then return false end

    local def = ORB_DEFS[orbType]
    if not def then return false end

    -- Validate target item exists
    if not target or not target.GetEntry then
        player:SendBroadcastMessage("No target item selected.")
        return false
    end

    local targetEntry = target:GetEntry()

    -- Validate this is a forge pool item (entries 500000+)
    if targetEntry < 500000 then
        player:SendBroadcastMessage("That is not a forge item.")
        return false
    end

    -- Verify the item is in bags, not equipped
    if target:IsEquipped() then
        player:SendBroadcastMessage("Unequip the item first. Cannot craft equipped items.")
        return false
    end

    -- Read forge item state from DB
    local state = readForgeItemState(targetEntry)
    if not state then
        player:SendBroadcastMessage("Could not read forge item data.")
        return false
    end

    -- Check eligibility
    if not def.canApply(state) then
        player:SendBroadcastMessage(def.name .. " cannot be applied to this item.")
        return false
    end

    -- Store pending state for the cast completion handler
    local playerGuid = player:GetGUIDLow()
    pendingOrb[playerGuid] = {
        orbType = orbType,
        targetEntry = targetEntry,
        orbItemEntry = orbEntry,
        timestamp = os.time(),
    }

    -- Start the 1.5s cast bar (interruptible)
    player:CastSpell(player, def.castSpell, false)

    return false  -- prevent item consumption by the instant spell
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
    local pending = pendingOrb[playerGuid]
    pendingOrb[playerGuid] = nil  -- clear regardless

    if not pending then
        player:SendBroadcastMessage("No pending orb operation.")
        return
    end

    -- Validate not stale (60s timeout)
    if os.time() - pending.timestamp > 60 then
        player:SendBroadcastMessage("Orb operation has expired.")
        return
    end

    -- Verify orb type matches
    if pending.orbType ~= orbType then
        player:SendBroadcastMessage("Orb type mismatch.")
        return
    end

    local def = ORB_DEFS[orbType]

    -- Re-read the forge item state (may have changed during cast)
    local state = readForgeItemState(pending.targetEntry)
    if not state then
        player:SendBroadcastMessage("Target item no longer exists.")
        return
    end

    -- Re-validate eligibility
    if not def.canApply(state) then
        player:SendBroadcastMessage(def.name .. " can no longer be applied to this item.")
        return
    end

    -- Verify player still has the target item
    local targetItem = player:GetItemByEntry(pending.targetEntry)
    if not targetItem then
        player:SendBroadcastMessage("Target item no longer in your bags.")
        return
    end

    -- Apply the orb effect
    local applyFn = ORB_APPLY[orbType]
    if not applyFn then
        player:SendBroadcastMessage("Orb effect not implemented: " .. orbType)
        return
    end

    local newEntry, newName, newStats = applyFn(player, state)
    if not newEntry then
        player:SendBroadcastMessage("Failed to apply " .. def.name .. ".")
        return
    end

    -- Consume one orb from the player's inventory
    player:RemoveItem(pending.orbItemEntry, 1)

    -- Report result
    local QUALITY_COLORS = {
        [1] = "|cffffffff", [2] = "|cff1eff00", [3] = "|cff0070dd", [4] = "|cffa335ee",
    }
    local QUALITY_LABELS = {
        [1] = "Common", [2] = "Uncommon", [3] = "Rare", [4] = "Epic",
    }
    local q = state.quality  -- quality after modification
    local qColor = QUALITY_COLORS[q] or ""
    local qLabel = QUALITY_LABELS[q] or "?"
    player:SendBroadcastMessage(string.format(
        "%s applied: %s%s|r (%s)",
        def.name, qColor, newName or "item", qLabel
    ))
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

-- Clean up pending state on logout
RegisterPlayerEvent(4, function(event, player)
    pendingOrb[player:GetGUIDLow()] = nil
end)

print("[ForgeLoot] PoE Orbs loaded (7 orb types)")
