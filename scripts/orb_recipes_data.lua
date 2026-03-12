-- Forge - Smithing: constants and data tables
-- @load-order 5

ORB_RECIPES_SKILLLINE_ID = 903
ORB_RECIPES_BASE_SPELL = SPELL_ORB_RECIPES_BASE

-- Recipes unlocked at each skill threshold (sorted by skill ascending)
-- Lua teaches these when skill reaches the threshold.
RECIPE_SKILL_THRESHOLDS = {
    { skill = 1,   spell = SPELL_RECIPE_IDENTIFY_FROM_TRANSMUTE },
    { skill = 3,   spell = SPELL_RECIPE_PORTAL_FROM_TRANSMUTE },
    { skill = 5,   spell = SPELL_RECIPE_ALTER_FROM_TRANSMUTE },
    { skill = 10,  spell = SPELL_RECIPE_SCRAP_FROM_TRANSMUTE },
    { skill = 20,  spell = SPELL_RECIPE_WHETSTONE_FROM_SCRAP },
    { skill = 40,  spell = SPELL_RECIPE_EXALT_FROM_SCOURING },
    { skill = 70,  spell = SPELL_RECIPE_DIVINE_FROM_SCOURING },
    { skill = 100, spell = SPELL_RECIPE_ANCIENT_FROM_JEWELER },
    { skill = 135, spell = SPELL_RECIPE_MIRROR_FROM_SCOURING },
}

-- Build a set of combine recipe spell IDs for fast lookup
RECIPE_SPELL_SET = {}
for _, entry in ipairs(RECIPE_SKILL_THRESHOLDS) do
    RECIPE_SPELL_SET[entry.spell] = true
end
