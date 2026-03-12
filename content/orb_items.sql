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
-- Orb of Alteration (Uncommon)
-- Reroll the suffix on an uncommon item.
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
    SPELL_ORB_ALTERATION, 'Orb of Alteration',
    'Reroll an uncommon forge item with a new random suffix modifier.', 1,
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
    SPELL_ORB_ALTERATION_CAST, 'Orb of Alteration',
    'Altering...', 1,
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
    bonding, BuyPrice, SellPrice, Material
) VALUES (
    ITEM_ORB_ALTERATION, 0, 0, -1,
    'Orb of Alteration', DISPLAYINFO_ORB_ALTERATION, 2, 0, 0,
    -1, -1,
    1, 0, 200, 0,
    SPELL_ORB_ALTERATION, 0, -1,
    0, 0, 0,
    0, 0, 0, -1
);

-- *****************************************************************************
-- Orb of Transmutation (Uncommon)
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
    'Upgrade a common forge item to uncommon.', 1,
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
    bonding, BuyPrice, SellPrice, Material
) VALUES (
    ITEM_ORB_TRANSMUTATION, 0, 0, -1,
    'Orb of Transmutation', DISPLAYINFO_ORB_TRANSMUTATION, 1, 0, 0,
    -1, -1,
    1, 0, 200, 0,
    SPELL_ORB_TRANSMUTATION, 0, -1,
    0, 0, 0,
    0, 0, 0, -1
);

-- *****************************************************************************
-- Regal Orb (Rare)
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
    bonding, BuyPrice, SellPrice, Material
) VALUES (
    ITEM_ORB_REGAL, 0, 0, -1,
    'Regal Orb', DISPLAYINFO_ORB_REGAL, 3, 0, 0,
    -1, -1,
    1, 0, 200, 0,
    SPELL_ORB_REGAL, 0, -1,
    0, 0, 0,
    0, 0, 0, -1
);

-- *****************************************************************************
-- Exalted Orb (Epic)
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
    bonding, BuyPrice, SellPrice, Material
) VALUES (
    ITEM_ORB_EXALTED, 0, 0, -1,
    'Exalted Orb', DISPLAYINFO_ORB_EXALTED, 4, 0, 0,
    -1, -1,
    1, 0, 200, 0,
    SPELL_ORB_EXALTED, 0, -1,
    0, 0, 0,
    0, 0, 0, -1
);

-- *****************************************************************************
-- Orb of Alchemy (Rare item, creates Epic result)
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
    bonding, BuyPrice, SellPrice, Material
) VALUES (
    ITEM_ORB_ALCHEMY, 0, 0, -1,
    'Orb of Alchemy', DISPLAYINFO_ORB_ALCHEMY, 3, 0, 0,
    -1, -1,
    1, 0, 200, 0,
    SPELL_ORB_ALCHEMY, 0, -1,
    0, 0, 0,
    0, 0, 0, -1
);

-- *****************************************************************************
-- Orb of Annulment (Rare) -- was "Orb of Scouring", tokens kept
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
    SPELL_ORB_SCOURING, 'Orb of Annulment',
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
    SPELL_ORB_SCOURING_CAST, 'Orb of Annulment',
    'Annulling...', 1,
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
    bonding, BuyPrice, SellPrice, Material
) VALUES (
    ITEM_ORB_SCOURING, 0, 0, -1,
    'Orb of Annulment', DISPLAYINFO_ORB_SCOURING, 3, 0, 0,
    -1, -1,
    1, 0, 200, 0,
    SPELL_ORB_SCOURING, 0, -1,
    0, 0, 0,
    0, 0, 0, -1
);

-- *****************************************************************************
-- Chaos Orb (Uncommon -- was Rare)
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
    SPELL_ORB_CHAOS, 'Chaos Orb',
    'Reroll all prefixes and suffixes on a forge item, shuffling them unpredictably.', 1,
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
    SPELL_ORB_CHAOS_CAST, 'Chaos Orb',
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
    bonding, BuyPrice, SellPrice, Material
) VALUES (
    ITEM_ORB_CHAOS, 0, 0, -1,
    'Chaos Orb', DISPLAYINFO_ORB_CHAOS, 3, 0, 0,
    -1, -1,
    1, 0, 200, 0,
    SPELL_ORB_CHAOS, 0, -1,
    0, 0, 0,
    0, 0, 0, -1
);

-- *****************************************************************************
-- Blessed Orb (Rare -- was "Divine Orb" Epic, tokens kept)
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
    SPELL_ORB_DIVINE, 'Blessed Orb',
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
    SPELL_ORB_DIVINE_CAST, 'Blessed Orb',
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
    bonding, BuyPrice, SellPrice, Material
) VALUES (
    ITEM_ORB_DIVINE, 0, 0, -1,
    'Blessed Orb', DISPLAYINFO_ORB_DIVINE, 4, 0, 0,
    -1, -1,
    1, 0, 200, 0,
    SPELL_ORB_DIVINE, 0, -1,
    0, 0, 0,
    0, 0, 0, -1
);

-- *****************************************************************************
-- NEW: Orb of Scouring (Common)
-- Reset any forge item to common (white) rarity, removing all affixes.
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
    SPELL_ORB_FULLSCOUR, 'Orb of Scouring',
    'Strip all affixes from a forge item, resetting it to common quality.', 1,
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
    SPELL_ORB_FULLSCOUR_CAST, 'Orb of Scouring',
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
    bonding, BuyPrice, SellPrice, Material
) VALUES (
    ITEM_ORB_FULLSCOUR, 0, 0, -1,
    'Orb of Scouring', DISPLAYINFO_ORB_FULLSCOUR, 1, 0, 0,
    -1, -1,
    1, 0, 200, 0,
    SPELL_ORB_FULLSCOUR, 0, -1,
    0, 0, 0,
    0, 0, 0, -1
);

-- *****************************************************************************
-- NEW: Blacksmith's Whetstone (Epic)
-- Increase weapon item level by 1.
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
    SPELL_ORB_WHETSTONE, 'Blacksmith''s Whetstone',
    'Hone a forged weapon, increasing its item level by 1, to a maximum of 20 above its base level.', 1,
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
    SPELL_ORB_WHETSTONE_CAST, 'Blacksmith''s Whetstone',
    'Honing...', 1,
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
    bonding, BuyPrice, SellPrice, Material
) VALUES (
    ITEM_ORB_WHETSTONE, 0, 0, -1,
    'Blacksmith''s Whetstone', DISPLAYINFO_ORB_WHETSTONE, 2, 0, 0,
    -1, -1,
    1, 0, 200, 0,
    SPELL_ORB_WHETSTONE, 0, -1,
    0, 0, 0,
    0, 0, 0, -1
);

-- *****************************************************************************
-- NEW: Armorer's Scrap (Epic)
-- Increase armor item level by 1.
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
    SPELL_ORB_ARMORER, 'Armorer''s Scrap',
    'Reinforce a forged armor piece, increasing its item level by 1, to a maximum of 20 above its base level.', 1,
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
    SPELL_ORB_ARMORER_CAST, 'Armorer''s Scrap',
    'Reinforcing...', 1,
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
    bonding, BuyPrice, SellPrice, Material
) VALUES (
    ITEM_ORB_ARMORER, 0, 0, -1,
    'Armorer''s Scrap', DISPLAYINFO_ORB_ARMORER, 2, 0, 0,
    -1, -1,
    1, 0, 200, 0,
    SPELL_ORB_ARMORER, 0, -1,
    0, 0, 0,
    0, 0, 0, -1
);

-- *****************************************************************************
-- NEW: Mirror of Kalandra (Legendary)
-- Duplicate a forge item into a frozen copy that cannot be modified.
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
    SPELL_ORB_MIRROR, 'Mirror of Kalandra',
    'Create a copy of a forge item. Once frozen the item can no longer be modified.', 1,
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
    SPELL_ORB_MIRROR_CAST, 'Mirror of Kalandra',
    'Reflecting...', 1,
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
    bonding, BuyPrice, SellPrice, Material
) VALUES (
    ITEM_ORB_MIRROR, 0, 0, -1,
    'Mirror of Kalandra', DISPLAYINFO_ORB_MIRROR, 5, 0, 0,
    -1, -1,
    1, 0, 200, 0,
    SPELL_ORB_MIRROR, 0, -1,
    0, 0, 0,
    0, 0, 0, -1
);

-- *****************************************************************************
-- NEW: Ancient Orb (Epic)
-- Reforge a forge item to the caster's current player level.
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
    SPELL_ORB_ANCIENT, 'Ancient Orb',
    'Reforge a forge item, adjusting it to your current level.', 1,
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
    SPELL_ORB_ANCIENT_CAST, 'Ancient Orb',
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
    bonding, BuyPrice, SellPrice, Material
) VALUES (
    ITEM_ORB_ANCIENT, 0, 0, -1,
    'Ancient Orb', DISPLAYINFO_ORB_ANCIENT, 4, 0, 0,
    -1, -1,
    1, 0, 200, 0,
    SPELL_ORB_ANCIENT, 0, -1,
    0, 0, 0,
    0, 0, 0, -1
);

-- *****************************************************************************
-- NEW: Divine Orb (Epic)
-- Transmog: apply appearance of a bag item to the equipped item in same slot.
-- Also randomizes the name.
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
    SPELL_ORB_TRANSMOG, 'Divine Orb',
    'Reforge an equipped item with the cosmetic appearance of a bag item.', 1,
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
    SPELL_ORB_TRANSMOG_CAST, 'Divine Orb',
    'Transmogrifying...', 1,
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
    bonding, BuyPrice, SellPrice, Material
) VALUES (
    ITEM_ORB_TRANSMOG, 0, 0, -1,
    'Divine Orb', DISPLAYINFO_ORB_TRANSMOG, 4, 0, 0,
    -1, -1,
    1, 0, 200, 0,
    SPELL_ORB_TRANSMOG, 0, -1,
    0, 0, 0,
    0, 0, 0, -1
);

-- *****************************************************************************
-- NEW: Scroll of Identification (Common)
-- Rename a forge item. Player types new name in chat after use.
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
    SPELL_ORB_IDENTIFY, 'Scroll of Identification',
    'Rename a forge item.', 1,
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
    SPELL_ORB_IDENTIFY_CAST, 'Scroll of Identification',
    'Identifying...', 1,
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
    bonding, BuyPrice, SellPrice, Material
) VALUES (
    ITEM_ORB_IDENTIFY, 0, 0, -1,
    'Scroll of Identification', DISPLAYINFO_ORB_IDENTIFY, 1, 0, 0,
    -1, -1,
    1, 0, 200, 0,
    SPELL_ORB_IDENTIFY, 0, -1,
    0, 0, 0,
    0, 0, 0, -1
);

-- *****************************************************************************
-- NEW: Portal Scroll (Common)
-- Consumable hearthstone with no cooldown.
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
    SPELL_PORTAL_SCROLL, 'Portal Scroll',
    'Returns you to your bind point.', 1,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0,
    1, 0, 0,
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
    SPELL_PORTAL_SCROLL_CAST, 'Portal Scroll',
    'Returning home...', 1,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0,
    8, 31, 0, 0,
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
    bonding, BuyPrice, SellPrice, Material
) VALUES (
    ITEM_PORTAL_SCROLL, 0, 0, -1,
    'Portal Scroll', DISPLAYINFO_PORTAL_SCROLL, 1, 0, 0,
    -1, -1,
    1, 0, 200, 0,
    SPELL_PORTAL_SCROLL, 0, -1,
    0, 0, 0,
    0, 0, 0, -1
);

-- *****************************************************************************
-- NEW: Awakener's Orb (Epic)
-- Destroy a rare item with a single prefix, store its influence.
-- Creates an Influenced Exalted Orb for the player.
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
    SPELL_ORB_AWAKENER, 'Awakener''s Orb',
    'Destroy a rare item with a single prefix, extracting its influence.', 1,
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
    SPELL_ORB_AWAKENER_CAST, 'Awakener''s Orb',
    'Awakening...', 1,
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
    bonding, BuyPrice, SellPrice, Material
) VALUES (
    ITEM_ORB_AWAKENER, 0, 0, -1,
    'Awakener''s Orb', DISPLAYINFO_ORB_AWAKENER, 4, 0, 0,
    -1, -1,
    1, 0, 200, 0,
    SPELL_ORB_AWAKENER, 0, -1,
    0, 0, 0,
    0, 0, 0, -1
);

-- *****************************************************************************
-- NEW: Influenced Exalted Orb (Epic)
-- Upgrade a rare item to epic with a guaranteed prefix from the influence.
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
    SPELL_ORB_INFLUENCED, 'Influenced Exalted Orb',
    'Upgrade a rare item to epic with a guaranteed influenced prefix.', 1,
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
    SPELL_ORB_INFLUENCED_CAST, 'Influenced Exalted Orb',
    'Influencing...', 1,
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
    bonding, BuyPrice, SellPrice, Material
) VALUES (
    ITEM_ORB_INFLUENCED, 0, 0, -1,
    'Influenced Exalted Orb', DISPLAYINFO_ORB_INFLUENCED, 4, 0, 0,
    -1, -1,
    1, 0, 1, 0,
    SPELL_ORB_INFLUENCED, 0, -1,
    0, 0, 0,
    0, 0, 0, -1
);

-- *****************************************************************************
-- NEW: Jeweler's Orb (Uncommon)
-- Reroll the number of gem sockets on a forge item.
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
    SPELL_ORB_JEWELER, 'Jeweler''s Orb',
    'Reroll the number of gem sockets on a forge item.', 1,
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
    SPELL_ORB_JEWELER_CAST, 'Jeweler''s Orb',
    'Socketing...', 1,
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
    bonding, BuyPrice, SellPrice, Material
) VALUES (
    ITEM_ORB_JEWELER, 0, 0, -1,
    'Jeweler''s Orb', DISPLAYINFO_ORB_JEWELER, 2, 0, 0,
    -1, -1,
    1, 0, 200, 0,
    SPELL_ORB_JEWELER, 0, -1,
    0, 0, 0,
    0, 0, 0, -1
);

-- *****************************************************************************
-- Influence Enchantments (cosmetic tooltip text for Influenced Exalted Orb)
-- No stat effects -- just a name displayed as green text on mouseover.
-- *****************************************************************************

INSERT INTO spellitemenchantment (
    ID, Charges, Effect1, Effect2, Effect3,
    EffectPointsMin1, EffectPointsMin2, EffectPointsMin3,
    EffectPointsMax1, EffectPointsMax2, EffectPointsMax3,
    EffectArg1, EffectArg2, EffectArg3,
    Name, ItemVisual, Flags, Src_ItemID,
    Condition_Id, RequiredSkillID, RequiredSkillRank, MinLevel
) VALUES
(ENCHANTMENT_INFLUENCE_AGI, 0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,
 'Influence: Agility', 0, 0, 0, 0, 0, 0, 0),
(ENCHANTMENT_INFLUENCE_STR, 0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,
 'Influence: Strength', 0, 0, 0, 0, 0, 0, 0),
(ENCHANTMENT_INFLUENCE_INT, 0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,
 'Influence: Intellect', 0, 0, 0, 0, 0, 0, 0),
(ENCHANTMENT_INFLUENCE_SPI, 0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,
 'Influence: Spirit', 0, 0, 0, 0, 0, 0, 0),
(ENCHANTMENT_INFLUENCE_STA, 0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,
 'Influence: Stamina', 0, 0, 0, 0, 0, 0, 0),
(ENCHANTMENT_INFLUENCE_DEF, 0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,
 'Influence: Defense', 0, 0, 0, 0, 0, 0, 0),
(ENCHANTMENT_INFLUENCE_DODGE, 0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,
 'Influence: Dodge', 0, 0, 0, 0, 0, 0, 0),
(ENCHANTMENT_INFLUENCE_PARRY, 0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,
 'Influence: Parry', 0, 0, 0, 0, 0, 0, 0),
(ENCHANTMENT_INFLUENCE_BLOCK_RTG, 0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,
 'Influence: Block Rating', 0, 0, 0, 0, 0, 0, 0),
(ENCHANTMENT_INFLUENCE_HIT, 0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,
 'Influence: Hit Rating', 0, 0, 0, 0, 0, 0, 0),
(ENCHANTMENT_INFLUENCE_CRIT, 0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,
 'Influence: Crit Rating', 0, 0, 0, 0, 0, 0, 0),
(ENCHANTMENT_INFLUENCE_HASTE, 0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,
 'Influence: Haste', 0, 0, 0, 0, 0, 0, 0),
(ENCHANTMENT_INFLUENCE_EXPERTISE, 0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,
 'Influence: Expertise', 0, 0, 0, 0, 0, 0, 0),
(ENCHANTMENT_INFLUENCE_AP, 0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,
 'Influence: Attack Power', 0, 0, 0, 0, 0, 0, 0),
(ENCHANTMENT_INFLUENCE_MP5, 0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,
 'Influence: MP5', 0, 0, 0, 0, 0, 0, 0),
(ENCHANTMENT_INFLUENCE_ARMOR_PEN, 0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,
 'Influence: Armor Pen', 0, 0, 0, 0, 0, 0, 0),
(ENCHANTMENT_INFLUENCE_SP, 0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,
 'Influence: Spell Power', 0, 0, 0, 0, 0, 0, 0),
(ENCHANTMENT_INFLUENCE_BLOCK_VAL, 0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,
 'Influence: Block Value', 0, 0, 0, 0, 0, 0, 0);
