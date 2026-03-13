-- =============================================================================
-- Orb Currency Loot Pools (reference_loot_template)
-- =============================================================================
-- GroupId=1: TrinityCore picks exactly ONE item per roll (mutually exclusive).
-- Six tiers, each cutting the lowest rarity orbs from the pool.
-- These pools are NOT attached to any creature -- other mods or manual setup
-- should reference them via creature_loot_template.
-- =============================================================================

-- =============================================================================
-- T1: Common (all 16 orbs, total weight 2289)
-- =============================================================================
INSERT INTO reference_loot_template
    (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
VALUES
    (LOOT_FORGE_POOL_COMMON, ITEM_ORB_ALTERATION,    0, 22.37, 0, 1, 1, 1, 1, 'Orb of Alteration'),
    (LOOT_FORGE_POOL_COMMON, ITEM_ORB_ARMORER,       0, 22.37, 0, 1, 1, 1, 1, 'Armorer''s Scrap'),
    (LOOT_FORGE_POOL_COMMON, ITEM_ORB_TRANSMUTATION, 0, 22.37, 0, 1, 1, 1, 1, 'Orb of Transmutation'),
    (LOOT_FORGE_POOL_COMMON, ITEM_ORB_JEWELER,       0,  5.59, 0, 1, 1, 1, 1, 'Jeweler''s Orb'),
    (LOOT_FORGE_POOL_COMMON, ITEM_ORB_WHETSTONE,     0,  5.59, 0, 1, 1, 1, 1, 'Blacksmith''s Whetstone'),
    (LOOT_FORGE_POOL_COMMON, ITEM_ORB_REGAL,         0,  5.59, 0, 1, 1, 1, 1, 'Regal Orb'),
    (LOOT_FORGE_POOL_COMMON, ITEM_ORB_CHAOS,         0,  2.80, 0, 1, 1, 1, 1, 'Chaos Orb'),
    (LOOT_FORGE_POOL_COMMON, ITEM_ORB_ALCHEMY,       0,  2.80, 0, 1, 1, 1, 1, 'Orb of Alchemy'),
    (LOOT_FORGE_POOL_COMMON, ITEM_ORB_FULLSCOUR,     0,  2.80, 0, 1, 1, 1, 1, 'Orb of Scouring'),
    (LOOT_FORGE_POOL_COMMON, ITEM_ORB_SCOURING,      0,  2.80, 0, 1, 1, 1, 1, 'Orb of Annulment'),
    (LOOT_FORGE_POOL_COMMON, ITEM_ORB_EXALTED,       0,  1.40, 0, 1, 1, 1, 1, 'Exalted Orb'),
    (LOOT_FORGE_POOL_COMMON, ITEM_ORB_DIVINE,        0,  1.40, 0, 1, 1, 1, 1, 'Blessed Orb'),
    (LOOT_FORGE_POOL_COMMON, ITEM_ORB_TRANSMOG,      0,  1.40, 0, 1, 1, 1, 1, 'Divine Orb'),
    (LOOT_FORGE_POOL_COMMON, ITEM_ORB_MIRROR,        0,  0.35, 0, 1, 1, 1, 1, 'Mirror of Kalandra'),
    (LOOT_FORGE_POOL_COMMON, ITEM_ORB_ANCIENT,       0,  0.35, 0, 1, 1, 1, 1, 'Ancient Orb'),
    (LOOT_FORGE_POOL_COMMON, ITEM_ORB_VAAL,           0,  2.80, 0, 1, 1, 1, 1, 'Vaal Orb'),
    (LOOT_FORGE_POOL_COMMON, ITEM_ORB_AWAKENER,      0,  0.04, 0, 1, 1, 1, 1, 'Awakener''s Orb');

-- =============================================================================
-- T2: Uncommon (13 orbs, total weight 753)
-- =============================================================================
INSERT INTO reference_loot_template
    (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
VALUES
    (LOOT_FORGE_POOL_UNCOMMON, ITEM_ORB_JEWELER,       0, 17.00, 0, 1, 1, 1, 1, 'Jeweler''s Orb'),
    (LOOT_FORGE_POOL_UNCOMMON, ITEM_ORB_WHETSTONE,     0, 17.00, 0, 1, 1, 1, 1, 'Blacksmith''s Whetstone'),
    (LOOT_FORGE_POOL_UNCOMMON, ITEM_ORB_REGAL,         0, 17.00, 0, 1, 1, 1, 1, 'Regal Orb'),
    (LOOT_FORGE_POOL_UNCOMMON, ITEM_ORB_CHAOS,         0,  8.50, 0, 1, 1, 1, 1, 'Chaos Orb'),
    (LOOT_FORGE_POOL_UNCOMMON, ITEM_ORB_ALCHEMY,       0,  8.50, 0, 1, 1, 1, 1, 'Orb of Alchemy'),
    (LOOT_FORGE_POOL_UNCOMMON, ITEM_ORB_FULLSCOUR,     0,  8.50, 0, 1, 1, 1, 1, 'Orb of Scouring'),
    (LOOT_FORGE_POOL_UNCOMMON, ITEM_ORB_SCOURING,      0,  8.50, 0, 1, 1, 1, 1, 'Orb of Annulment'),
    (LOOT_FORGE_POOL_UNCOMMON, ITEM_ORB_EXALTED,       0,  4.25, 0, 1, 1, 1, 1, 'Exalted Orb'),
    (LOOT_FORGE_POOL_UNCOMMON, ITEM_ORB_DIVINE,        0,  4.25, 0, 1, 1, 1, 1, 'Blessed Orb'),
    (LOOT_FORGE_POOL_UNCOMMON, ITEM_ORB_TRANSMOG,      0,  4.25, 0, 1, 1, 1, 1, 'Divine Orb'),
    (LOOT_FORGE_POOL_UNCOMMON, ITEM_ORB_MIRROR,        0,  1.06, 0, 1, 1, 1, 1, 'Mirror of Kalandra'),
    (LOOT_FORGE_POOL_UNCOMMON, ITEM_ORB_ANCIENT,       0,  1.06, 0, 1, 1, 1, 1, 'Ancient Orb'),
    (LOOT_FORGE_POOL_UNCOMMON, ITEM_ORB_VAAL,           0,  8.50, 0, 1, 1, 1, 1, 'Vaal Orb'),
    (LOOT_FORGE_POOL_UNCOMMON, ITEM_ORB_AWAKENER,      0,  0.13, 0, 1, 1, 1, 1, 'Awakener''s Orb');

-- =============================================================================
-- T3: Rare (10 orbs, total weight 369)
-- =============================================================================
INSERT INTO reference_loot_template
    (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
VALUES
    (LOOT_FORGE_POOL_RARE, ITEM_ORB_CHAOS,         0, 17.34, 0, 1, 1, 1, 1, 'Chaos Orb'),
    (LOOT_FORGE_POOL_RARE, ITEM_ORB_ALCHEMY,       0, 17.34, 0, 1, 1, 1, 1, 'Orb of Alchemy'),
    (LOOT_FORGE_POOL_RARE, ITEM_ORB_FULLSCOUR,     0, 17.34, 0, 1, 1, 1, 1, 'Orb of Scouring'),
    (LOOT_FORGE_POOL_RARE, ITEM_ORB_SCOURING,      0, 17.34, 0, 1, 1, 1, 1, 'Orb of Annulment'),
    (LOOT_FORGE_POOL_RARE, ITEM_ORB_EXALTED,       0,  8.67, 0, 1, 1, 1, 1, 'Exalted Orb'),
    (LOOT_FORGE_POOL_RARE, ITEM_ORB_DIVINE,        0,  8.67, 0, 1, 1, 1, 1, 'Blessed Orb'),
    (LOOT_FORGE_POOL_RARE, ITEM_ORB_TRANSMOG,      0,  8.67, 0, 1, 1, 1, 1, 'Divine Orb'),
    (LOOT_FORGE_POOL_RARE, ITEM_ORB_MIRROR,        0,  2.17, 0, 1, 1, 1, 1, 'Mirror of Kalandra'),
    (LOOT_FORGE_POOL_RARE, ITEM_ORB_ANCIENT,       0,  2.17, 0, 1, 1, 1, 1, 'Ancient Orb'),
    (LOOT_FORGE_POOL_RARE, ITEM_ORB_VAAL,           0, 17.34, 0, 1, 1, 1, 1, 'Vaal Orb'),
    (LOOT_FORGE_POOL_RARE, ITEM_ORB_AWAKENER,      0,  0.27, 0, 1, 1, 1, 1, 'Awakener''s Orb');

-- =============================================================================
-- T4: Epic (6 orbs, total weight 113)
-- =============================================================================
INSERT INTO reference_loot_template
    (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
VALUES
    (LOOT_FORGE_POOL_EPIC, ITEM_ORB_EXALTED,       0, 28.32, 0, 1, 1, 1, 1, 'Exalted Orb'),
    (LOOT_FORGE_POOL_EPIC, ITEM_ORB_DIVINE,        0, 28.32, 0, 1, 1, 1, 1, 'Blessed Orb'),
    (LOOT_FORGE_POOL_EPIC, ITEM_ORB_TRANSMOG,      0, 28.32, 0, 1, 1, 1, 1, 'Divine Orb'),
    (LOOT_FORGE_POOL_EPIC, ITEM_ORB_MIRROR,        0,  7.08, 0, 1, 1, 1, 1, 'Mirror of Kalandra'),
    (LOOT_FORGE_POOL_EPIC, ITEM_ORB_ANCIENT,       0,  7.08, 0, 1, 1, 1, 1, 'Ancient Orb'),
    (LOOT_FORGE_POOL_EPIC, ITEM_ORB_AWAKENER,      0,  0.88, 0, 1, 1, 1, 1, 'Awakener''s Orb');

-- =============================================================================
-- T5: Legendary (3 orbs, total weight 17)
-- =============================================================================
INSERT INTO reference_loot_template
    (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
VALUES
    (LOOT_FORGE_POOL_LEGENDARY, ITEM_ORB_MIRROR,        0, 47.06, 0, 1, 1, 1, 1, 'Mirror of Kalandra'),
    (LOOT_FORGE_POOL_LEGENDARY, ITEM_ORB_ANCIENT,       0, 47.06, 0, 1, 1, 1, 1, 'Ancient Orb'),
    (LOOT_FORGE_POOL_LEGENDARY, ITEM_ORB_AWAKENER,      0,  5.88, 0, 1, 1, 1, 1, 'Awakener''s Orb');

-- =============================================================================
-- T6: Artifact (1 orb)
-- =============================================================================
INSERT INTO reference_loot_template
    (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)
VALUES
    (LOOT_FORGE_POOL_ARTIFACT, ITEM_ORB_AWAKENER,      0, 100.00, 0, 1, 1, 1, 1, 'Awakener''s Orb');