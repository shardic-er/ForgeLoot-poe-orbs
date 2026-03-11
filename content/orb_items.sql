-- =============================================================================
-- ForgeLoot PoE Orbs: Item and Spell definitions
-- =============================================================================
-- Each orb has:
--   Spell 1 (instant): Item-targeting cursor via Targets=16, Effect1=3 (DUMMY).
--     Triggered by item right-click. Lua validates target, then casts Spell 2.
--   Spell 2 (1.5s cast): Self-target with cast bar. InterruptFlags=31 so
--     movement/damage interrupts it. RegisterSpellEvent fires on completion.
--   Item: Consumable, stackable, references Spell 1 as on-use.
--
-- Pattern copied from transmog_rune.sql (qol-tweaks).
-- =============================================================================

-- *****************************************************************************
-- Orb of Transmutation
-- Common->Uncommon (add suffix), or reroll an existing suffix.
-- *****************************************************************************

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
    EquippedItemClass,
    SpellIconID
) VALUES (
    SPELL_ORB_TRANSMUTATION, 'Orb of Transmutation',
    'Upgrade a common forge item to uncommon, or reroll an existing suffix.', 1,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 16,
    1, 0, 0,
    1, 0, -1, 0,
    0, 0,
    3, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    -1,
    1973
);

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
    SpellIconID
) VALUES (
    SPELL_ORB_TRANSMUTATION_CAST, 'Orb of Transmutation',
    'Transmuting...', 1,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0,
    16, 31, 0, 0,
    1, 0, -1, 0,
    0, 0,
    3, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    1, 0, 0,
    0, 0, 0,
    0, 0, 0,
    -1,
    1973
);

INSERT INTO item_template (
    entry, class, subclass, SoundOverrideSubclass,
    name, displayid, Quality, Flags, InventoryType,
    AllowableClass, AllowableRace,
    ItemLevel, RequiredLevel, stackable, maxcount,
    spellid_1, spelltrigger_1, spellcharges_1,
    spellcooldown_1, spellcategory_1, spellcategorycooldown_1,
    bonding, BuyPrice, SellPrice, Material,
    description
) VALUES (
    ITEM_ORB_TRANSMUTATION, 0, 0, -1,
    'Orb of Transmutation', DISPLAYINFO_ORB_TRANSMUTATION, 2, 0, 0,
    -1, -1,
    1, 0, 20, 0,
    SPELL_ORB_TRANSMUTATION, 0, -1,
    0, 0, 0,
    0, 0, 0, -1,
    'Upgrade a common forge item to uncommon, or reroll an existing suffix.'
);

-- *****************************************************************************
-- Regal Orb
-- Uncommon->Rare (add a prefix).
-- *****************************************************************************

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
    EquippedItemClass,
    SpellIconID
) VALUES (
    SPELL_ORB_REGAL, 'Regal Orb',
    'Upgrade an uncommon forge item to rare, adding a prefix.', 1,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 16,
    1, 0, 0,
    1, 0, -1, 0,
    0, 0,
    3, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    -1,
    1973
);

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
    SpellIconID
) VALUES (
    SPELL_ORB_REGAL_CAST, 'Regal Orb',
    'Augmenting...', 1,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0,
    16, 31, 0, 0,
    1, 0, -1, 0,
    0, 0,
    3, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    1, 0, 0,
    0, 0, 0,
    0, 0, 0,
    -1,
    1973
);

INSERT INTO item_template (
    entry, class, subclass, SoundOverrideSubclass,
    name, displayid, Quality, Flags, InventoryType,
    AllowableClass, AllowableRace,
    ItemLevel, RequiredLevel, stackable, maxcount,
    spellid_1, spelltrigger_1, spellcharges_1,
    spellcooldown_1, spellcategory_1, spellcategorycooldown_1,
    bonding, BuyPrice, SellPrice, Material,
    description
) VALUES (
    ITEM_ORB_REGAL, 0, 0, -1,
    'Regal Orb', DISPLAYINFO_ORB_REGAL, 3, 0, 0,
    -1, -1,
    1, 0, 20, 0,
    SPELL_ORB_REGAL, 0, -1,
    0, 0, 0,
    0, 0, 0, -1,
    'Upgrade an uncommon forge item to rare, adding a prefix.'
);

-- *****************************************************************************
-- Exalted Orb
-- Rare->Epic (add a second prefix).
-- *****************************************************************************

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
    EquippedItemClass,
    SpellIconID
) VALUES (
    SPELL_ORB_EXALTED, 'Exalted Orb',
    'Upgrade a rare forge item to epic, adding a second prefix.', 1,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 16,
    1, 0, 0,
    1, 0, -1, 0,
    0, 0,
    3, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    -1,
    1973
);

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
    SpellIconID
) VALUES (
    SPELL_ORB_EXALTED_CAST, 'Exalted Orb',
    'Exalting...', 1,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0,
    16, 31, 0, 0,
    1, 0, -1, 0,
    0, 0,
    3, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    1, 0, 0,
    0, 0, 0,
    0, 0, 0,
    -1,
    1973
);

INSERT INTO item_template (
    entry, class, subclass, SoundOverrideSubclass,
    name, displayid, Quality, Flags, InventoryType,
    AllowableClass, AllowableRace,
    ItemLevel, RequiredLevel, stackable, maxcount,
    spellid_1, spelltrigger_1, spellcharges_1,
    spellcooldown_1, spellcategory_1, spellcategorycooldown_1,
    bonding, BuyPrice, SellPrice, Material,
    description
) VALUES (
    ITEM_ORB_EXALTED, 0, 0, -1,
    'Exalted Orb', DISPLAYINFO_ORB_EXALTED, 4, 0, 0,
    -1, -1,
    1, 0, 20, 0,
    SPELL_ORB_EXALTED, 0, -1,
    0, 0, 0,
    0, 0, 0, -1,
    'Upgrade a rare forge item to epic, adding a second prefix.'
);

-- *****************************************************************************
-- Orb of Alchemy
-- Common->Epic (add suffix + both prefixes).
-- *****************************************************************************

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
    EquippedItemClass,
    SpellIconID
) VALUES (
    SPELL_ORB_ALCHEMY, 'Orb of Alchemy',
    'Transform a common forge item into a fully-crafted epic.', 1,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 16,
    1, 0, 0,
    1, 0, -1, 0,
    0, 0,
    3, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    -1,
    1973
);

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
    SpellIconID
) VALUES (
    SPELL_ORB_ALCHEMY_CAST, 'Orb of Alchemy',
    'Transmuting...', 1,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0,
    16, 31, 0, 0,
    1, 0, -1, 0,
    0, 0,
    3, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    1, 0, 0,
    0, 0, 0,
    0, 0, 0,
    -1,
    1973
);

INSERT INTO item_template (
    entry, class, subclass, SoundOverrideSubclass,
    name, displayid, Quality, Flags, InventoryType,
    AllowableClass, AllowableRace,
    ItemLevel, RequiredLevel, stackable, maxcount,
    spellid_1, spelltrigger_1, spellcharges_1,
    spellcooldown_1, spellcategory_1, spellcategorycooldown_1,
    bonding, BuyPrice, SellPrice, Material,
    description
) VALUES (
    ITEM_ORB_ALCHEMY, 0, 0, -1,
    'Orb of Alchemy', DISPLAYINFO_ORB_ALCHEMY, 4, 0, 0,
    -1, -1,
    1, 0, 20, 0,
    SPELL_ORB_ALCHEMY, 0, -1,
    0, 0, 0,
    0, 0, 0, -1,
    'Transform a common forge item into a fully-crafted epic.'
);

-- *****************************************************************************
-- Orb of Scouring
-- Reduce rarity by 1, remove the most recent affix.
-- *****************************************************************************

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
    EquippedItemClass,
    SpellIconID
) VALUES (
    SPELL_ORB_SCOURING, 'Orb of Scouring',
    'Reduce a forge item rarity by one tier, removing the most recent affix.', 1,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 16,
    1, 0, 0,
    1, 0, -1, 0,
    0, 0,
    3, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    -1,
    1973
);

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
    SpellIconID
) VALUES (
    SPELL_ORB_SCOURING_CAST, 'Orb of Scouring',
    'Scouring...', 1,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0,
    16, 31, 0, 0,
    1, 0, -1, 0,
    0, 0,
    3, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    1, 0, 0,
    0, 0, 0,
    0, 0, 0,
    -1,
    1973
);

INSERT INTO item_template (
    entry, class, subclass, SoundOverrideSubclass,
    name, displayid, Quality, Flags, InventoryType,
    AllowableClass, AllowableRace,
    ItemLevel, RequiredLevel, stackable, maxcount,
    spellid_1, spelltrigger_1, spellcharges_1,
    spellcooldown_1, spellcategory_1, spellcategorycooldown_1,
    bonding, BuyPrice, SellPrice, Material,
    description
) VALUES (
    ITEM_ORB_SCOURING, 0, 0, -1,
    'Orb of Scouring', DISPLAYINFO_ORB_SCOURING, 2, 0, 0,
    -1, -1,
    1, 0, 20, 0,
    SPELL_ORB_SCOURING, 0, -1,
    0, 0, 0,
    0, 0, 0, -1,
    'Reduce a forge item rarity by one tier, removing the most recent affix.'
);

-- *****************************************************************************
-- Orb of Chaos
-- Reroll all affixes, keep quality.
-- *****************************************************************************

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
    EquippedItemClass,
    SpellIconID
) VALUES (
    SPELL_ORB_CHAOS, 'Orb of Chaos',
    'Reroll all affixes on a forge item, keeping its quality.', 1,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 16,
    1, 0, 0,
    1, 0, -1, 0,
    0, 0,
    3, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    -1,
    1973
);

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
    SpellIconID
) VALUES (
    SPELL_ORB_CHAOS_CAST, 'Orb of Chaos',
    'Rerolling...', 1,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0,
    16, 31, 0, 0,
    1, 0, -1, 0,
    0, 0,
    3, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    1, 0, 0,
    0, 0, 0,
    0, 0, 0,
    -1,
    1973
);

INSERT INTO item_template (
    entry, class, subclass, SoundOverrideSubclass,
    name, displayid, Quality, Flags, InventoryType,
    AllowableClass, AllowableRace,
    ItemLevel, RequiredLevel, stackable, maxcount,
    spellid_1, spelltrigger_1, spellcharges_1,
    spellcooldown_1, spellcategory_1, spellcategorycooldown_1,
    bonding, BuyPrice, SellPrice, Material,
    description
) VALUES (
    ITEM_ORB_CHAOS, 0, 0, -1,
    'Orb of Chaos', DISPLAYINFO_ORB_CHAOS, 3, 0, 0,
    -1, -1,
    1, 0, 20, 0,
    SPELL_ORB_CHAOS, 0, -1,
    0, 0, 0,
    0, 0, 0, -1,
    'Reroll all affixes on a forge item, keeping its quality.'
);

-- *****************************************************************************
-- Divine Orb
-- Reroll weapon attack speed.
-- *****************************************************************************

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
    EquippedItemClass,
    SpellIconID
) VALUES (
    SPELL_ORB_DIVINE, 'Divine Orb',
    'Reroll the attack speed of a forge weapon.', 1,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 16,
    1, 0, 0,
    1, 0, -1, 0,
    0, 0,
    3, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    -1,
    1973
);

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
    SpellIconID
) VALUES (
    SPELL_ORB_DIVINE_CAST, 'Divine Orb',
    'Reforging...', 1,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0,
    16, 31, 0, 0,
    1, 0, -1, 0,
    0, 0,
    3, 0, 0,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
    1, 0, 0,
    0, 0, 0,
    0, 0, 0,
    -1,
    1973
);

INSERT INTO item_template (
    entry, class, subclass, SoundOverrideSubclass,
    name, displayid, Quality, Flags, InventoryType,
    AllowableClass, AllowableRace,
    ItemLevel, RequiredLevel, stackable, maxcount,
    spellid_1, spelltrigger_1, spellcharges_1,
    spellcooldown_1, spellcategory_1, spellcategorycooldown_1,
    bonding, BuyPrice, SellPrice, Material,
    description
) VALUES (
    ITEM_ORB_DIVINE, 0, 0, -1,
    'Divine Orb', DISPLAYINFO_ORB_DIVINE, 3, 0, 0,
    -1, -1,
    1, 0, 20, 0,
    SPELL_ORB_DIVINE, 0, -1,
    0, 0, 0,
    0, 0, 0, -1,
    'Reroll the attack speed of a forge weapon.'
);
