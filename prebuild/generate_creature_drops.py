#!/usr/bin/env python3
# @load-order 30
"""Generate orb drop rows for all creatures based on rank, boss flags, and map type.

Queries creature_template for all creatures with a loot table that award XP,
reads Map.dbc to identify raid maps, then generates creature_loot_template
rows with layered drops:

  Base pull (30%, every mob with a loot table):
    Rank 0 (Normal)     -> LOOT_FORGE_POOL_COMMON
    Rank 1 (Elite)      -> LOOT_FORGE_POOL_UNCOMMON
    Rank 2,3,4          -> LOOT_FORGE_POOL_RARE

  Bonus pulls (stacking):
    Rank 2+ (Rare Elite, World Boss, Rare)   -> +LOOT_FORGE_POOL_RARE  100% (merged into base)
    Dungeon boss (flags_extra & 0x10000000)  -> +LOOT_FORGE_POOL_RARE  100%
    Boss mob (type_flags & 0x4)              -> +LOOT_FORGE_POOL_EPIC  100%
    Raid map (Map.dbc InstanceType == 2)     -> +LOOT_FORGE_POOL_RARE  30%

When a lootid is shared by creatures of different ranks/flags/maps, the highest
rank and any matching flag determine which bonus pulls apply.

Output: content/orb_creature_drops.sql (regenerated on build)
"""

import argparse
import os
import sys
from collections import OrderedDict
from pathlib import Path

import yaml

# Local DBC utilities (same pattern as other mods)
sys.path.insert(0, str(Path(__file__).resolve().parent))
from dbc_utils import read_dbc, get_uint32, resolve_dbc_dir

SCRIPT_DIR = Path(__file__).resolve().parent
MOD_DIR = SCRIPT_DIR.parent
OUTPUT_PATH = MOD_DIR / 'content' / 'orb_creature_drops.sql'

RANK_TO_POOL = {
    0: 'LOOT_FORGE_POOL_COMMON',
    1: 'LOOT_FORGE_POOL_UNCOMMON',
}
# Ranks 2, 3, 4 all map to rare
RARE_POOL = 'LOOT_FORGE_POOL_RARE'
EPIC_POOL = 'LOOT_FORGE_POOL_EPIC'

CHANCE_BASE = 30
CHANCE_BONUS = 100

# Map.dbc InstanceType values
MAP_TYPE_RAID = 2


def load_raid_maps(dbc_dir):
    """Read Map.dbc and return the set of map IDs that are raids."""
    map_dbc_path = os.path.join(dbc_dir, 'Map.dbc')
    if not os.path.isfile(map_dbc_path):
        print("  WARNING: Map.dbc not found at %s, skipping raid map detection" % map_dbc_path)
        return set()

    header, records, _string_block = read_dbc(map_dbc_path)
    raid_maps = set()
    for record in records:
        map_id = get_uint32(record, 0)          # Field 0: ID
        instance_type = get_uint32(record, 2)    # Field 2: InstanceType
        if instance_type == MAP_TYPE_RAID:
            raid_maps.add(map_id)

    return raid_maps


def query_loot_data(db_config, raid_maps):
    """Query distinct lootids with rank, boss flags, and raid presence."""
    import mysql.connector

    conn = mysql.connector.connect(
        host=db_config['host'], port=db_config['port'],
        user=db_config['user'], password=db_config['password'],
        database=db_config['world_db']
    )
    cursor = conn.cursor()

    # Base query: rank and boss flags per lootid
    cursor.execute("""
        SELECT ct.lootid,
               MAX(ct.`rank`) AS max_rank,
               MAX(CASE WHEN (ct.flags_extra & 0x10000000) != 0 THEN 1 ELSE 0 END) AS has_dungeon_boss,
               MAX(CASE WHEN (ct.type_flags & 0x4) != 0 THEN 1 ELSE 0 END) AS has_boss_mob
        FROM creature_template ct
        WHERE ct.lootid > 0 AND (ct.flags_extra & 64) = 0
        GROUP BY ct.lootid
    """)
    loot_rows = cursor.fetchall()

    # If we have raid maps, find which lootids have spawns on raid maps
    raid_lootids = set()
    if raid_maps:
        # Build a comma-separated list of raid map IDs for the IN clause
        map_list = ','.join(str(m) for m in raid_maps)
        cursor.execute("""
            SELECT DISTINCT ct.lootid
            FROM creature_template ct
            JOIN creature c ON c.id = ct.entry
            WHERE ct.lootid > 0
              AND (ct.flags_extra & 64) = 0
              AND c.map IN (%s)
        """ % map_list)
        raid_lootids = set(row[0] for row in cursor.fetchall())

    conn.close()

    # Merge raid flag into the result tuples
    results = []
    for lootid, max_rank, has_dungeon_boss, has_boss_mob in loot_rows:
        in_raid = 1 if lootid in raid_lootids else 0
        results.append((lootid, max_rank, has_dungeon_boss, has_boss_mob, in_raid))

    return results


def generate_sql(loot_data):
    """Generate INSERT...VALUES SQL with symbolic token references."""
    # Build all rows: (lootid, pool_token, chance, comment)
    all_rows = []

    for lootid, max_rank, has_dungeon_boss, has_boss_mob, in_raid in loot_data:
        # Base pull: every mob gets 30% at their rank-appropriate pool
        # For rank 2+, merge the bonus rare into the base (100% instead of 30%)
        if max_rank >= 2:
            base_pool = RARE_POOL
            base_chance = CHANCE_BONUS
        else:
            base_pool = RANK_TO_POOL.get(max_rank, RARE_POOL)
            base_chance = CHANCE_BASE
        all_rows.append((lootid, base_pool, base_chance, 'Forge Orb'))

        # Bonus rare pull for dungeon bosses (only if base isn't already rare)
        has_rare_bonus = False
        if has_dungeon_boss and max_rank < 2:
            all_rows.append((lootid, RARE_POOL, CHANCE_BONUS, 'Forge Orb Boss'))
            has_rare_bonus = True

        # Bonus epic pull for boss_mob type flag
        if has_boss_mob:
            all_rows.append((lootid, EPIC_POOL, CHANCE_BONUS, 'Forge Orb Elite'))

        # Bonus rare pull for raid mobs (30% chance)
        # Skip if base is already 100% rare (rank 2+) or already has a rare
        # bonus from dungeon_boss (same Item reference = PK conflict)
        if in_raid and max_rank < 2 and not has_rare_bonus:
            all_rows.append((lootid, RARE_POOL, CHANCE_BASE, 'Forge Orb Raid'))

    # Group rows by (pool, chance, comment) for organized SQL output
    groups = OrderedDict()
    for lootid, pool, chance, comment in all_rows:
        key = (pool, chance, comment)
        groups.setdefault(key, []).append(lootid)

    lines = []
    lines.append("-- Generated by prebuild/generate_creature_drops.py -- DO NOT EDIT")
    lines.append("-- Orb drops: base 30%% pull + bonus pulls for bosses and raids.")
    lines.append("-- %d total rows across %d groups." % (len(all_rows), len(groups)))
    lines.append("")

    # Clean up any previous orb drop rows before inserting.
    lines.append("-- Cleanup: remove all previous orb drop rows")
    lines.append("DELETE FROM creature_loot_template WHERE Comment LIKE 'Forge Orb%%';")
    lines.append("")

    # Output sections in a predictable order
    section_order = [
        ('LOOT_FORGE_POOL_COMMON', CHANCE_BASE, 'Forge Orb',
         'Normal mobs (rank 0) -- 30%% base'),
        ('LOOT_FORGE_POOL_UNCOMMON', CHANCE_BASE, 'Forge Orb',
         'Elite mobs (rank 1) -- 30%% base'),
        ('LOOT_FORGE_POOL_RARE', CHANCE_BONUS, 'Forge Orb',
         'Rare+ mobs (rank 2-4) -- 100%% base'),
        ('LOOT_FORGE_POOL_RARE', CHANCE_BONUS, 'Forge Orb Boss',
         'Dungeon bosses (flags_extra dungeon_boss) -- 100%% bonus rare'),
        ('LOOT_FORGE_POOL_RARE', CHANCE_BASE, 'Forge Orb Raid',
         'Raid mobs (Map.dbc InstanceType=2) -- 30%% bonus rare'),
        ('LOOT_FORGE_POOL_EPIC', CHANCE_BONUS, 'Forge Orb Elite',
         'Boss mobs (type_flags boss_mob) -- 100%% bonus epic'),
    ]

    for pool_token, chance, comment, description in section_order:
        key = (pool_token, chance, comment)
        lootids = groups.get(key)
        if not lootids:
            continue

        lootids.sort()
        lines.append("-- %s (%d loot tables)" % (description, len(lootids)))
        lines.append("INSERT INTO creature_loot_template")
        lines.append("    (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment)")
        lines.append("VALUES")

        value_lines = []
        for lid in lootids:
            value_lines.append(
                "    (%d, %s, %s, %d, 0, 1, 0, 1, 1, '%s')"
                % (lid, pool_token, pool_token, chance, comment)
            )

        lines.append(",\n".join(value_lines) + ";")
        lines.append("")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description='Generate creature orb drop SQL')
    parser.add_argument('--config', required=True, help='Path to project.yaml')
    parser.add_argument('--id-assignments', required=False, help='(unused)')
    args = parser.parse_args()

    print("[PoeOrbs] Generating creature orb drop SQL...")

    with open(args.config) as f:
        config = yaml.safe_load(f)

    db_config = config.get('database')
    if not db_config:
        print("  ERROR: No 'database' section in project.yaml")
        sys.exit(1)

    # Load raid map IDs from Map.dbc
    dbc_dir = resolve_dbc_dir(config)
    print("  Reading Map.dbc from %s..." % dbc_dir)
    raid_maps = load_raid_maps(dbc_dir)
    print("  Found %d raid maps" % len(raid_maps))

    print("  Querying creature_template for loot tables, boss flags, and raid spawns...")
    loot_data = query_loot_data(db_config, raid_maps)
    print("  Found %d distinct loot tables" % len(loot_data))

    sql = generate_sql(loot_data)

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_PATH, 'w', newline='\n') as f:
        f.write(sql)

    print("  Wrote %s" % OUTPUT_PATH)
    print("[PoeOrbs] Creature drops done.")


if __name__ == '__main__':
    main()
