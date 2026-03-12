-- =============================================================================
-- Forge - Smithing: Secondary profession for currency conversions
-- =============================================================================

-- SkillLine: "Forge - Smithing" (secondary profession, category 9)
INSERT INTO `skill_line_dbc` (
    `id`, `category_id`, `skill_costs_id`,
    `display_name`, `description`,
    `spell_icon_id`, `alternate_verb`, `can_link`
) VALUES (
    903, 9, 0,
    'Forge - Smithing', 'Convert currency orbs into other orbs.',
    3830, 'Combine', 1
);

-- SkillRaceClassInfo: available to all races/classes
INSERT INTO `skill_race_class_info_dbc` (
    `id`, `skill_id`, `race_mask`, `class_mask`,
    `flags`, `min_level`, `skill_tier_id`, `field_7`
) VALUES (
    1501, 903, 4294967295, 1535,
    160, 0, 41, 0
);

-- =============================================================================
-- Base spell: opens the tradeskill window
-- =============================================================================
INSERT INTO spell_dbc (
    Id, SpellName, Description,
    Attributes, CastingTimeIndex, RangeIndex,
    Effect1, EffectImplicitTargetA1,
    SpellIconID
) VALUES (
    SPELL_ORB_RECIPES_BASE, 'Forge - Smithing',
    'Convert currency orbs into other orbs.',
    16842768, 1, 1,
    47, 1,
    3830
);

-- =============================================================================
-- Combine recipes (EFFECT_CREATE_ITEM, server handles item + skill-ups)
-- Attributes: 0x10020 = 65568, AttributesEx: 0x400 = 1024
-- CastingTimeIndex: 5 (~2s), InterruptFlags: 15
-- Effect1: 24 (SPELL_EFFECT_CREATE_ITEM)
-- EffectDieSides1: 1, EffectBasePoints1: 0 -> creates 1 item
-- =============================================================================

-- 1x Orb of Transmutation -> 1x Scroll of Identification (known at start)
INSERT INTO spell_dbc (
    Id, SpellName, Description,
    Attributes, AttributesEx,
    CastingTimeIndex, RangeIndex,
    Effect1, EffectImplicitTargetA1,
    EffectDieSides1, EffectItemType1,
    Reagent1, ReagentCount1,
    SpellIconID, InterruptFlags
) VALUES (
    SPELL_RECIPE_IDENTIFY_FROM_TRANSMUTE, 'Scroll of Identification',
    'Scroll of Identification',
    65568, 1024,
    5, 1,
    24, 1,
    1, ITEM_ORB_IDENTIFY,
    ITEM_ORB_TRANSMUTATION, 1,
    3830, 15
);

-- 1x Orb of Transmutation -> 1x Portal Scroll
INSERT INTO spell_dbc (
    Id, SpellName, Description,
    Attributes, AttributesEx,
    CastingTimeIndex, RangeIndex,
    Effect1, EffectImplicitTargetA1,
    EffectDieSides1, EffectItemType1,
    Reagent1, ReagentCount1,
    SpellIconID, InterruptFlags
) VALUES (
    SPELL_RECIPE_PORTAL_FROM_TRANSMUTE, 'Portal Scroll',
    'Portal Scroll',
    65568, 1024,
    5, 1,
    24, 1,
    1, ITEM_PORTAL_SCROLL,
    ITEM_ORB_TRANSMUTATION, 1,
    3830, 15
);

-- 4x Orb of Transmutation -> 1x Orb of Alteration
INSERT INTO spell_dbc (
    Id, SpellName, Description,
    Attributes, AttributesEx,
    CastingTimeIndex, RangeIndex,
    Effect1, EffectImplicitTargetA1,
    EffectDieSides1, EffectItemType1,
    Reagent1, ReagentCount1,
    SpellIconID, InterruptFlags
) VALUES (
    SPELL_RECIPE_ALTER_FROM_TRANSMUTE, 'Orb of Alteration',
    'Orb of Alteration',
    65568, 1024,
    5, 1,
    24, 1,
    1, ITEM_ORB_ALTERATION,
    ITEM_ORB_TRANSMUTATION, 4,
    3830, 15
);

-- 4x Orb of Transmutation -> 1x Armorer's Scrap
INSERT INTO spell_dbc (
    Id, SpellName, Description,
    Attributes, AttributesEx,
    CastingTimeIndex, RangeIndex,
    Effect1, EffectImplicitTargetA1,
    EffectDieSides1, EffectItemType1,
    Reagent1, ReagentCount1,
    SpellIconID, InterruptFlags
) VALUES (
    SPELL_RECIPE_SCRAP_FROM_TRANSMUTE, 'Armorer''s Scrap',
    'Armorer''s Scrap',
    65568, 1024,
    5, 1,
    24, 1,
    1, ITEM_ORB_ARMORER,
    ITEM_ORB_TRANSMUTATION, 4,
    3830, 15
);

-- 4x Armorer's Scrap -> 1x Blacksmith's Whetstone
INSERT INTO spell_dbc (
    Id, SpellName, Description,
    Attributes, AttributesEx,
    CastingTimeIndex, RangeIndex,
    Effect1, EffectImplicitTargetA1,
    EffectDieSides1, EffectItemType1,
    Reagent1, ReagentCount1,
    SpellIconID, InterruptFlags
) VALUES (
    SPELL_RECIPE_WHETSTONE_FROM_SCRAP, 'Blacksmith''s Whetstone',
    'Blacksmith''s Whetstone',
    65568, 1024,
    5, 1,
    24, 1,
    1, ITEM_ORB_WHETSTONE,
    ITEM_ORB_ARMORER, 4,
    3830, 15
);

-- 8x Orb of Scouring -> 1x Exalted Orb
INSERT INTO spell_dbc (
    Id, SpellName, Description,
    Attributes, AttributesEx,
    CastingTimeIndex, RangeIndex,
    Effect1, EffectImplicitTargetA1,
    EffectDieSides1, EffectItemType1,
    Reagent1, ReagentCount1,
    SpellIconID, InterruptFlags
) VALUES (
    SPELL_RECIPE_EXALT_FROM_SCOURING, 'Exalted Orb',
    'Exalted Orb',
    65568, 1024,
    5, 1,
    24, 1,
    1, ITEM_ORB_EXALTED,
    ITEM_ORB_FULLSCOUR, 8,
    3830, 15
);

-- 10x Orb of Scouring -> 1x Divine Orb
INSERT INTO spell_dbc (
    Id, SpellName, Description,
    Attributes, AttributesEx,
    CastingTimeIndex, RangeIndex,
    Effect1, EffectImplicitTargetA1,
    EffectDieSides1, EffectItemType1,
    Reagent1, ReagentCount1,
    SpellIconID, InterruptFlags
) VALUES (
    SPELL_RECIPE_DIVINE_FROM_SCOURING, 'Divine Orb',
    'Divine Orb',
    65568, 1024,
    5, 1,
    24, 1,
    1, ITEM_ORB_TRANSMOG,
    ITEM_ORB_FULLSCOUR, 10,
    3830, 15
);

-- 20x Jeweler's Orb -> 1x Ancient Orb
INSERT INTO spell_dbc (
    Id, SpellName, Description,
    Attributes, AttributesEx,
    CastingTimeIndex, RangeIndex,
    Effect1, EffectImplicitTargetA1,
    EffectDieSides1, EffectItemType1,
    Reagent1, ReagentCount1,
    SpellIconID, InterruptFlags
) VALUES (
    SPELL_RECIPE_ANCIENT_FROM_JEWELER, 'Ancient Orb',
    'Ancient Orb',
    65568, 1024,
    5, 1,
    24, 1,
    1, ITEM_ORB_ANCIENT,
    ITEM_ORB_JEWELER, 20,
    3830, 15
);

-- 20x Orb of Scouring -> 1x Mirror of Kalandra
INSERT INTO spell_dbc (
    Id, SpellName, Description,
    Attributes, AttributesEx,
    CastingTimeIndex, RangeIndex,
    Effect1, EffectImplicitTargetA1,
    EffectDieSides1, EffectItemType1,
    Reagent1, ReagentCount1,
    SpellIconID, InterruptFlags
) VALUES (
    SPELL_RECIPE_MIRROR_FROM_SCOURING, 'Mirror of Kalandra',
    'Mirror of Kalandra',
    65568, 1024,
    5, 1,
    24, 1,
    1, ITEM_ORB_MIRROR,
    ITEM_ORB_FULLSCOUR, 20,
    3830, 15
);

-- =============================================================================
-- SkillLineAbility: register all spells under Forge - Smithing (903)
-- trivial_skill_line_rank_high/low: controls skill-up behavior
--   Combine recipes: high=200 (always give skill-ups up to 150)
-- =============================================================================

INSERT INTO `skill_line_ability_dbc` (
    `id`, `skill_line`, `spell`, `race_mask`, `class_mask`,
    `exclude_race`, `exclude_class`, `min_skill_line_rank`,
    `superceded_by_spell`, `acquire_method`,
    `trivial_skill_line_rank_high`, `trivial_skill_line_rank_low`,
    `character_points1`, `character_points2`
) VALUES
    -- Base spell (opens tradeskill window)
    (SLA_ORB_RECIPES_BASE, 903, SPELL_ORB_RECIPES_BASE, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    -- Combine recipes (give skill-ups, trivial_high=200 so they never go grey)
    (SLA_RECIPE_IDENTIFY_FROM_TRANSMUTE, 903, SPELL_RECIPE_IDENTIFY_FROM_TRANSMUTE, 0, 0, 0, 0, 0, 0, 0, 200, 150, 0, 0),
    (SLA_RECIPE_PORTAL_FROM_TRANSMUTE, 903, SPELL_RECIPE_PORTAL_FROM_TRANSMUTE, 0, 0, 0, 0, 0, 0, 0, 200, 150, 0, 0),
    (SLA_RECIPE_ALTER_FROM_TRANSMUTE, 903, SPELL_RECIPE_ALTER_FROM_TRANSMUTE, 0, 0, 0, 0, 0, 0, 0, 200, 150, 0, 0),
    (SLA_RECIPE_SCRAP_FROM_TRANSMUTE, 903, SPELL_RECIPE_SCRAP_FROM_TRANSMUTE, 0, 0, 0, 0, 0, 0, 0, 200, 150, 0, 0),
    (SLA_RECIPE_WHETSTONE_FROM_SCRAP, 903, SPELL_RECIPE_WHETSTONE_FROM_SCRAP, 0, 0, 0, 0, 0, 0, 0, 200, 150, 0, 0),
    (SLA_RECIPE_EXALT_FROM_SCOURING, 903, SPELL_RECIPE_EXALT_FROM_SCOURING, 0, 0, 0, 0, 0, 0, 0, 200, 150, 0, 0),
    (SLA_RECIPE_DIVINE_FROM_SCOURING, 903, SPELL_RECIPE_DIVINE_FROM_SCOURING, 0, 0, 0, 0, 0, 0, 0, 200, 150, 0, 0),
    (SLA_RECIPE_ANCIENT_FROM_JEWELER, 903, SPELL_RECIPE_ANCIENT_FROM_JEWELER, 0, 0, 0, 0, 0, 0, 0, 200, 150, 0, 0),
    (SLA_RECIPE_MIRROR_FROM_SCOURING, 903, SPELL_RECIPE_MIRROR_FROM_SCOURING, 0, 0, 0, 0, 0, 0, 0, 200, 150, 0, 0);