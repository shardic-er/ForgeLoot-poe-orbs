-- =============================================================================
-- Shatter Spell: Destroy forge items to recover crafting orbs
-- =============================================================================
-- Hijacks TrinityCore's SPELL_EFFECT_DISENCHANT (effect 99) for the native
-- loot window experience. Config-driven: removing this mod deletes all rows
-- below, and forge items become non-disenchantable on next server restart.
--
-- Forge-only restriction enforced by the spell_forge_shatter SpellScript
-- (compiled into forge-loot C++ module, activated by spell_script_names row).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Tell forge-loot which DisenchantID to set per quality tier
-- -----------------------------------------------------------------------------
INSERT INTO forge_disenchant_config (quality, disenchant_id) VALUES
    (1, LOOT_SHATTER_COMMON),
    (2, LOOT_SHATTER_UNCOMMON),
    (3, LOOT_SHATTER_RARE),
    (4, LOOT_SHATTER_EPIC);

-- -----------------------------------------------------------------------------
-- 2. Shatter spell definition (spell_dbc)
-- -----------------------------------------------------------------------------
-- Effect 99 = SPELL_EFFECT_DISENCHANT (native item targeting + loot window)
-- CastingTimeIndex 16 = 1.5 seconds (same as vanilla Disenchant)
-- InterruptFlags 15 = movement + damage + interrupt + turning
-- SpellVisualID1 3220 = disenchant cast animation
-- SpellIconID 2490 = INV_Enchant_Disenchant icon
-- Targets 16 = item targeting cursor
-- EquippedItemClass -1 = no equipped item restriction
INSERT INTO spell_dbc (
    Id, SpellName, Description, SchoolMask,
    Attributes, AttributesEx, AttributesEx2, AttributesEx3,
    AttributesEx4, AttributesEx5, AttributesEx6, AttributesEx7,
    Stances, StancesNot, Targets,
    CastingTimeIndex, InterruptFlags, RecoveryTime, CategoryRecoveryTime,
    RangeIndex, DurationIndex, PowerType, ManaCost,
    Mechanic, Dispel,
    Effect1, Effect2, Effect3,
    EffectApplyAuraName1, EffectApplyAuraName2, EffectApplyAuraName3,
    EffectBasePoints1, EffectBasePoints2, EffectBasePoints3,
    EffectDieSides1, EffectDieSides2, EffectDieSides3,
    EffectImplicitTargetA1, EffectImplicitTargetA2, EffectImplicitTargetA3,
    EffectImplicitTargetB1, EffectImplicitTargetB2, EffectImplicitTargetB3,
    EffectMiscValue1, EffectMiscValue2, EffectMiscValue3,
    EquippedItemClass,
    SpellIconID, SpellVisualID1
) VALUES (
    SPELL_SHATTER, 'Shatter',
    'Destroy a forge item to recover crafting orbs.', 1,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 16,
    16, 15, 0, 0,
    1, 0, -1, 0,
    0, 0,
    99, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    -1,
    2490, 3220
);

-- -----------------------------------------------------------------------------
-- 3. Transmutation Shard display info
-- -----------------------------------------------------------------------------
INSERT INTO `item_display_info_dbc` (
    `id`, `model_name_0`, `model_name_1`,
    `model_texture_0`, `model_texture_1`,
    `inventory_icon_0`, `inventory_icon_1`,
    `geoset_group_0`, `geoset_group_1`, `geoset_group_2`,
    `flags`, `spell_visual_id`, `group_sound_index`,
    `helmet_geoset_vis_0`, `helmet_geoset_vis_1`,
    `texture_0`, `texture_1`, `texture_2`, `texture_3`,
    `texture_4`, `texture_5`, `texture_6`, `texture_7`,
    `item_visual`, `particle_color_id`
) VALUES (
    DISPLAYINFO_TRANSMUTATION_SHARD, '', '', '', '',
    'Transmutation_Shard', '',
    0, 0, 0, 0, 0, 0, 0, 0,
    '', '', '', '', '', '', '', '', 0, 0
);

-- -----------------------------------------------------------------------------
-- 4. Transmutation Shard: salvage material from common forge items
-- -----------------------------------------------------------------------------
-- Trade good (class 7), common (quality 1), stacks to 200.
-- On-use: consume 5 shards -> 1 Orb of Transmutation.
-- DisplayID 45306 = vanilla Apexis Shard icon (inv_misc_apexis_shard).

INSERT INTO spell_dbc (
    Id, SpellName, Description, SchoolMask,
    Attributes, AttributesEx, AttributesEx2, AttributesEx3,
    AttributesEx4, AttributesEx5, AttributesEx6, AttributesEx7,
    Stances, StancesNot, Targets,
    CastingTimeIndex, RecoveryTime, CategoryRecoveryTime,
    RangeIndex, DurationIndex, PowerType, ManaCost,
    Mechanic, Dispel,
    Effect1, Effect2, Effect3,
    EffectApplyAuraName1, EffectApplyAuraName2, EffectApplyAuraName3,
    EffectBasePoints1, EffectBasePoints2, EffectBasePoints3,
    EffectDieSides1, EffectDieSides2, EffectDieSides3,
    EffectImplicitTargetA1, EffectImplicitTargetA2, EffectImplicitTargetA3,
    EffectImplicitTargetB1, EffectImplicitTargetB2, EffectImplicitTargetB3,
    EffectMiscValue1, EffectMiscValue2, EffectMiscValue3,
    EffectItemType1,
    Reagent1, ReagentCount1,
    EquippedItemClass,
    SpellIconID
) VALUES (
    SPELL_SHARD_COMBINE, 'Combine Shards',
    'Combine 5 Transmutation Shards into an Orb of Transmutation.', 1,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0,
    1, 0, 0,
    1, 0, -1, 0,
    0, 0,
    24, 0, 0,
    0, 0, 0,
    0, 0, 0,
    1, 0, 0,
    1, 0, 0,
    0, 0, 0,
    0, 0, 0,
    ITEM_ORB_TRANSMUTATION,
    ITEM_TRANSMUTATION_SHARD, 5,
    -1,
    2490
);

INSERT INTO item_template (
    entry, class, subclass, SoundOverrideSubclass,
    name, displayid, Quality, Flags, FlagsExtra, BuyCount,
    BuyPrice, SellPrice, InventoryType, AllowableClass, AllowableRace,
    ItemLevel, RequiredLevel, maxcount, stackable,
    Material, bonding, BagFamily,
    spellid_1, spelltrigger_1, spellcharges_1,
    spellcooldown_1, spellcategory_1, spellcategorycooldown_1,
    description
) VALUES (
    ITEM_TRANSMUTATION_SHARD, 7, 0, -1,
    'Transmutation Shard', DISPLAYINFO_TRANSMUTATION_SHARD, 1, 0, 0, 1,
    0, 1, 0, -1, -1,
    1, 0, 0, 200,
    -1, 0, 128,
    SPELL_SHARD_COMBINE, 0, -1,
    -1, 0, -1,
    ''
);

-- -----------------------------------------------------------------------------
-- 4. Disenchant loot tables (tier shift: item quality -> one tier lower pool)
-- -----------------------------------------------------------------------------
-- These use Reference to point at the existing LOOT_FORGE_POOL_* reference
-- templates, keeping loot distribution in one place.
--
-- Common forge items  -> 1 Transmutation Shard (if shatter-skillgems-tweak installed)
--                        or 1 Orb of Transmutation as fallback
-- Uncommon forge items -> common orb pool (mostly Transmutation/Alteration)
-- Rare forge items     -> uncommon orb pool (Jeweler/Regal/Chaos range)
-- Epic forge items     -> rare orb pool (Chaos/Exalted/Blessed range)

INSERT INTO disenchant_loot_template
    (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
VALUES
    (LOOT_SHATTER_COMMON, ITEM_TRANSMUTATION_SHARD, 0, 100, 0, 1, 0, 1, 1, 'Shatter common -> 1 transmutation shard');

INSERT INTO disenchant_loot_template
    (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
VALUES
    (LOOT_SHATTER_UNCOMMON, 0, LOOT_FORGE_POOL_COMMON, 100, 0, 1, 0, 1, 1, 'Shatter uncommon -> common orb pool');

INSERT INTO disenchant_loot_template
    (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
VALUES
    (LOOT_SHATTER_RARE, 0, LOOT_FORGE_POOL_UNCOMMON, 100, 0, 1, 0, 1, 1, 'Shatter rare -> uncommon orb pool');

INSERT INTO disenchant_loot_template
    (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
VALUES
    (LOOT_SHATTER_EPIC, 0, LOOT_FORGE_POOL_RARE, 100, 0, 1, 0, 1, 1, 'Shatter epic -> rare orb pool');

-- -----------------------------------------------------------------------------
-- 4. Activate the forge-only SpellScript (compiled in forge-loot C++ module)
-- -----------------------------------------------------------------------------
-- The spell_forge_shatter script validates that the target item is a forge item.
-- Without this row, the SpellScript is never invoked (safe when mod is removed).
INSERT INTO spell_script_names (spell_id, ScriptName)
VALUES (SPELL_SHATTER, 'spell_forge_shatter');
