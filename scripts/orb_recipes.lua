-- Forge - Smithing: auto-learn profession on login, teach recipes by skill
-- @load-order 10
-- Requires: scripts/orb_recipes_data.lua (@load-order 5)

local SKILL_STEP = 6       -- Grand Master
local SKILL_MAX  = 150
local SKILL_TABLE = "forge_smithing_skill"

-- Ensure character DB table exists (deploy only handles world DB)
CharDBExecute(
    "CREATE TABLE IF NOT EXISTS `" .. SKILL_TABLE .. "` ("
    .. "`player_guid` INT UNSIGNED NOT NULL, "
    .. "`skill_value` SMALLINT UNSIGNED NOT NULL DEFAULT 1, "
    .. "PRIMARY KEY (`player_guid`)"
    .. ") ENGINE=InnoDB"
)

-- Teach all recipes the player qualifies for at their current skill level
local function TeachQualifyingRecipes(player)
    local skill = player:GetSkillValue(ORB_RECIPES_SKILLLINE_ID)
    for _, entry in ipairs(RECIPE_SKILL_THRESHOLDS) do
        if skill >= entry.skill and not player:HasSpell(entry.spell) then
            player:LearnSpell(entry.spell)
        end
    end
end

local function OnLogin(event, player)
    local guid = player:GetGUIDLow()

    -- Teach base spell (opens tradeskill window)
    if not player:HasSpell(ORB_RECIPES_BASE_SPELL) then
        player:LearnSpell(ORB_RECIPES_BASE_SPELL)
    end

    -- Teach Shatter (disenchant forge items into orbs)
    if not player:HasSpell(SPELL_SHATTER) then
        player:LearnSpell(SPELL_SHATTER)
    end

    -- Restore skill: custom skilllines get clamped on load, so re-set max.
    local q = CharDBQuery(
        "SELECT skill_value FROM " .. SKILL_TABLE
        .. " WHERE player_guid = " .. guid
    )
    if q then
        local current = q:GetUInt32(0)
        if current < 1 then current = 1 end
        if current > SKILL_MAX then current = SKILL_MAX end
        player:SetSkill(ORB_RECIPES_SKILLLINE_ID, SKILL_STEP, current, SKILL_MAX)
    else
        -- First time: start at skill 1
        player:SetSkill(ORB_RECIPES_SKILLLINE_ID, SKILL_STEP, 1, SKILL_MAX)
        CharDBExecute(
            "REPLACE INTO " .. SKILL_TABLE
            .. " (player_guid, skill_value) VALUES ("
            .. guid .. ", 1)"
        )
    end

    -- Teach all recipes the player qualifies for
    TeachQualifyingRecipes(player)
end

-- After casting a combine recipe, check if the player unlocked new recipes
local function OnSpellCast(event, player, spell, skipCheck)
    local spellId = spell:GetEntry()
    if RECIPE_SPELL_SET[spellId] then
        -- Persist current skill value (skill-ups happen during cast)
        local guid = player:GetGUIDLow()
        local current = player:GetSkillValue(ORB_RECIPES_SKILLLINE_ID)
        if current > 0 then
            CharDBExecute(
                "REPLACE INTO " .. SKILL_TABLE
                .. " (player_guid, skill_value) VALUES ("
                .. guid .. ", " .. current .. ")"
            )
        end
        -- Teach any newly unlocked recipes
        TeachQualifyingRecipes(player)
    end
end

RegisterPlayerEvent(3, OnLogin)
RegisterPlayerEvent(5, OnSpellCast)
