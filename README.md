# Forge Loot: PoE Orbs

Currency items inspired by Path of Exile for use with the Forge Loot system. Each orb modifies forged items in different ways.

**Version**: 0.2.0
**Dependencies**: forge-loot, qol-tweaks

## Table of Contents

- [Orb Reference](#orb-reference)
- [Drop Rates](#drop-rates)
- [Crafting Recipes](#crafting-recipes)
- [System Architecture](#system-architecture)
- [Two-Spell Flow](#two-spell-flow)
- [Database Tables](#database-tables)
- [Orb Effects Detail](#orb-effects-detail)
- [Transmog (Divine Orb)](#transmog-divine-orb)
- [Identify (Scroll of Identification)](#identify-scroll-of-identification)
- [Influence System (Awakener + Influenced Exalted)](#influence-system)
- [recreateItem Internals](#recreateitem-internals)
- [Addon Communication Protocol](#addon-communication-protocol)
- [Enchantment Preservation](#enchantment-preservation)
- [Recipe System](#recipe-system)
- [File Structure](#file-structure)
- [Design Philosophy](#design-philosophy)

## Orb Reference

| Item | Quality | Description |
|---|---|---|
| Orb of Transmutation | Common | Upgrade a common forge item to uncommon |
| Orb of Scouring | Common | Strip all affixes, reset to common quality |
| Scroll of Identification | Common | Rename a forge item |
| Portal Scroll | Common | Returns you to your bind point |
| Orb of Alteration | Uncommon | Reroll an uncommon item's random suffix |
| Armorer's Scrap | Uncommon | +1 armor item level (max 20 above base) |
| Blacksmith's Whetstone | Uncommon | +1 weapon item level (max 20 above base) |
| Jeweler's Orb | Uncommon | Reroll gem socket count |
| Regal Orb | Rare | Upgrade uncommon to rare, adding a prefix |
| Orb of Alchemy | Rare | Transform a common item into a full epic |
| Orb of Annulment | Rare | Reduce rarity by one tier, removing most recent affix |
| Chaos Orb | Rare | Reroll all prefixes and suffixes |
| Exalted Orb | Epic | Upgrade rare to epic, adding a second prefix |
| Blessed Orb | Epic | Reroll weapon attack speed |
| Ancient Orb | Epic | Reforge item, adjusting to your current level |
| Divine Orb | Epic | Transmogrify equipped item with a bag item's appearance |
| Awakener's Orb | Legendary | Destroy a rare item to extract its influence |
| Influenced Exalted Orb | Epic | Upgrade rare to epic with guaranteed influenced prefix |
| Mirror of Kalandra | Legendary | Copy a forge item (frozen, no further modification) |

## Drop Rates

Relative drop weights. Higher number = more common.

| Item | Quality | Weight | Notes |
|---|---|---|---|
| Orb of Transmutation | Common | 256 | Feeds Scrap crafting, use on bases before vendoring |
| Armorer's Scrap | Uncommon | 256 | Also craftable from 4x Transmutation |
| Orb of Alteration | Uncommon | 256 | Suffix fishing, rains freely |
| Jeweler's Orb | Uncommon | 128 | Socket rolling (7% for 3 sockets) |
| Blacksmith's Whetstone | Uncommon | 128 | Also craftable from 4x Scrap |
| Regal Orb | Rare | 128 | Slam freely while leveling, stockpile for endgame |
| Chaos Orb | Rare | 64 | Leveling lottery ticket |
| Orb of Alchemy | Rare | 64 | Leveling lottery ticket |
| Orb of Scouring | Common | 64 | Budget Annulment (costs ~20 Alts to re-fish suffix) |
| Orb of Annulment | Rare | 64 | Regal/Annul loop bottleneck from consumption, not scarcity |
| Exalted Orb | Epic | 32 | Slam and hope -- cringe when you miss, live with it |
| Blessed Orb | Epic | 32 | Scarce, low demand (melee weapons only) |
| Divine Orb | Epic | 32 | Cosmetic transmog, enjoy looking at your character |
| Mirror of Kalandra | Legendary | 8 | Insurance: snapshot an item before risky upgrades |
| Ancient Orb | Epic | 8 | Rescue god-rolls at wrong level, twink downscaling |
| Awakener's Orb | Legendary | 1 | Chase item. Also craftable from Exalt + Raid Emblems |
| Influenced Exalted Orb | Epic | -- | Crafted only (Awakener + sacrifice a rare item) |
| Portal Scroll | Common | -- | Vendor (1x Transmutation = 1x Portal Scroll) |
| Scroll of Identification | Common | -- | Vendor (1x Transmutation = 1x Scroll of ID) |

## Crafting Recipes

Conversion paths to sink surplus currency:

| Recipe | Result | Purpose |
|---|---|---|
| 4x Orb of Transmutation | 1x Armorer's Scrap | Sink excess Transmutes |
| 4x Armorer's Scrap | 1x Blacksmith's Whetstone | Sink excess Scraps |
| 1x Orb of Transmutation | 1x Portal Scroll | Vendor exchange |
| 1x Orb of Transmutation | 1x Scroll of Identification | Vendor exchange |
| 8x Orb of Scouring | 1x Exalted Orb | Scourings as generic rare currency |
| 10x Orb of Scouring | 1x Divine Orb | Scourings as generic rare currency |
| 20x Orb of Scouring | 1x Mirror of Kalandra | Scourings as generic rare currency |
| 20x Jeweler's Orb | 1x Ancient Orb | Sink excess Jewelers |
| 1x Exalted Orb + Raid Emblems | 1x Awakener's Orb | Endgame crafting path |

---

## System Architecture

### Overview

Every forge item is a unique template entry allocated from a pre-populated Item.dbc pool. The pool is divided into blocks by `(item_class, item_subclass, inv_type)`, and each block contains sub-pools keyed by `displayInfoId` so that each entry's DBC display matches the runtime template's display exactly. This is critical because the WoW client uses DBC display IDs (not query response data) for bag icons and drag cursors.

Orbs modify forge items by destroying the old template entry (freeing it back to the pool) and creating a new one with recalculated stats. The `recreateItem` function handles this destroy-and-recreate cycle, preserving enchantments and gems across the transition.

### State Tracking

Each forge item's crafting state is tracked in the `virtual_item_instance` table:

- `weapon_type` / `slot_name` / `armor_class` -- item archetype (never changed by orbs)
- `suffix_name` -- random suffix modifier (set by Transmutation/Alteration/Chaos)
- `prefix1_stat_id` / `prefix2_stat_id` -- prefix stat types (set by Regal/Exalted/Chaos)
- `prefix3_label` -- special marker ("Mirrored" or corruption tags)
- `item_level_override` -- bonus item levels from Scrap/Whetstone
- `name_override` -- custom name from Scroll of Identification
- `display_info_id` / `display_source_entry` -- current visual appearance
- `item_class` / `item_subclass` / `inv_type` -- pool allocation keys (changed by transmog)

Stats are **never stored or carried forward**. They are regenerated from scratch on every `recreateItem` call based on the item's quality, level, affixes, and slot.

## Two-Spell Flow

All orbs (except Portal Scroll) use a two-spell mechanism:

### Spell 1: Instant (On-Use)

- Triggered by right-clicking the orb item
- Uses item-targeting cursor (Targets=16, Effect=DUMMY)
- The `onOrbUse` handler validates the target:
  - Must be a forge item (entry >= 500000)
  - Must pass the orb's `canApply()` validator (quality checks, slot checks, etc.)
- If valid, the cast spell (Spell 2) is triggered on the player
- For addon-based orbs (Identify, Transmog), pending data is written to `orb_pending` and an addon message is sent to the client

### Spell 2: Cast (1.5 seconds)

- Self-targeted with a visible cast bar
- Interruptible by movement or damage (InterruptFlags=31)
- The `onOrbCastComplete` handler fires on successful cast:
  - Looks up the orb definition and calls the appropriate `apply*` function
  - Consumes one orb item from inventory
  - Calls `recreateItem` to destroy the old item and create a modified replacement

### Why Two Spells?

A single spell cannot both target an item (for selection) and have a cast bar (for interruptibility). The instant spell handles targeting and validation; the cast spell provides the visible cast bar and interruptible window. The target item entry is passed between spells via a per-player Lua table (`pendingOrbCasts`).

### Special Cases

- **Portal Scroll**: Single self-cast spell, no item target
- **Scroll of Identification**: Spell 1 stores pending data, sends addon message for rename popup. The cast spell fires after the player submits a name via the addon UI
- **Divine Orb**: Spell 1 stores pending data (source item info), sends addon message for confirmation popup. The cast spell fires after the player confirms via the addon UI

## Database Tables

### `awakener_pending`

Tracks which prefix was consumed by Awakener's Orb so the Influenced Exalted Orb can apply it as a guaranteed prefix.

```sql
CREATE TABLE IF NOT EXISTS awakener_pending (
    player_guid   INT UNSIGNED NOT NULL,
    prefix_stat_id TINYINT UNSIGNED NOT NULL,
    prefix_label  VARCHAR(64) NOT NULL DEFAULT '',
    PRIMARY KEY (player_guid)
);
```

- One pending influence per player at a time
- Written when Awakener's Orb destroys a rare item (extracts its prefix)
- Read and deleted when Influenced Exalted Orb is applied

### `orb_pending`

Ephemeral cross-state bridge for addon-message-based orbs. Item events (ON_USE) run in MAP state, addon messages run in WORLD state, and cast completion runs in MAP state. Since Lua tables are not shared across states, this DB table bridges all three.

```sql
CREATE TABLE orb_pending (
    player_guid      INT UNSIGNED NOT NULL,
    orb_type         VARCHAR(16) NOT NULL,         -- 'identify' or 'transmog'
    target_entry     INT UNSIGNED NOT NULL DEFAULT 0,
    orb_item_entry   INT UNSIGNED NOT NULL DEFAULT 0,
    timestamp        INT UNSIGNED NOT NULL,         -- 60-second expiry
    new_name         VARCHAR(64) NULL,              -- identify: player's chosen name
    equipped_entry   INT UNSIGNED NULL,             -- transmog: equipped item entry
    source_entry     INT UNSIGNED NULL,             -- transmog: bag item entry
    display_id       INT UNSIGNED NULL,             -- transmog: source display info ID
    display_entry    INT UNSIGNED NULL,             -- transmog: source item entry
    source_item_class    TINYINT UNSIGNED NULL,     -- transmog: source item class
    source_item_subclass TINYINT UNSIGNED NULL,     -- transmog: source item subclass
    source_inv_type      TINYINT UNSIGNED NULL,     -- transmog: source inventory type
    PRIMARY KEY (player_guid)
);
```

This table is **ephemeral** -- it only holds in-flight data and is safe to DROP and recreate on schema changes. The `DROP TABLE IF EXISTS` + `CREATE TABLE` pattern is used instead of `CREATE TABLE IF NOT EXISTS` to ensure schema migrations apply cleanly.

## Orb Effects Detail

### Rarity Upgrade Path

```
Common (white) --[Transmutation]--> Uncommon (green) --[Regal]--> Rare (blue) --[Exalted]--> Epic (purple)
                                                                                  or
Common (white) --[Alchemy]-------> Epic (purple, all affixes at once)
```

### Quality Modifiers

| Orb | Input Quality | Output Quality | Affix Changes |
|---|---|---|---|
| Transmutation | Common | Uncommon | Adds random suffix |
| Regal | Uncommon | Rare | Adds random prefix |
| Exalted | Rare | Epic | Adds second random prefix |
| Influenced Exalted | Rare | Epic | Adds guaranteed prefix (from Awakener) |
| Alchemy | Common | Epic | Adds suffix + both prefixes |
| Annulment | Uncommon+ | One tier lower | Removes most recent affix |
| Scouring | Any | Common | Removes all affixes |

### Reroll Orbs

| Orb | What It Rerolls | Quality Requirement |
|---|---|---|
| Alteration | Suffix only | Uncommon |
| Chaos | All affixes (suffix + prefixes) | Uncommon+ |
| Blessed | Attack speed | Uncommon+ weapon |
| Jeweler's | Socket count (0-3, weighted) | Any forge item |

### Level Modifiers

| Orb | Effect | Cap |
|---|---|---|
| Armorer's Scrap | +1 item level (armor) | +20 above base |
| Blacksmith's Whetstone | +1 item level (weapon) | +20 above base |
| Ancient Orb | Set item level to player's current level | No cap |

### Special Orbs

| Orb | Effect |
|---|---|
| Mirror of Kalandra | Duplicates item as Legendary quality, marked "Mirrored" (frozen, no further modification) |
| Divine Orb | Applies appearance of a bag item to an equipped forge item (see Transmog section) |
| Awakener's Orb | Destroys a rare+ item, extracts its first prefix, gives Influenced Exalted Orb with that stat |
| Scroll of Identification | Opens rename popup, applies custom name (see Identify section) |
| Portal Scroll | Teleports player to bind point |

## Transmog (Divine Orb)

The Divine Orb copies the appearance of an unequipped bag item onto an equipped forge item, destroying the source item in the process.

### Flow

1. Player right-clicks Divine Orb, targets an **unequipped** bag item (the appearance source)
2. Server reads source item's display info, item_class, item_subclass, and inv_type
3. Server finds the forge item currently equipped in the matching slot
4. Pending data (all source type info) is written to `orb_pending`
5. Addon message `"DV:<quality>|<slotName>|<sourceName>"` is sent to trigger confirmation popup
6. Player confirms or cancels via the popup
7. On confirm: Spell 2 fires, `applyTransmog` is called

### How It Works

The equipped item's `item_class`, `item_subclass`, and `inv_type` are changed to match the source item. This causes `CreateForgeItem` to allocate a pool entry from the source's block, where the DBC display already matches. The item's `weapon_type`, `slot_name`, and `armor_class` remain unchanged, so stats and damage calculations are unaffected.

This approach solves the cross-pool display problem: a 2H sword transmogged to look like a dagger will use the dagger pool block (with correct DBC displays for dagger icons), while retaining 2H sword damage and stat budgets.

### Safety

The source bag item is only destroyed **after** `recreateItem` succeeds. If pool allocation fails (e.g., pool exhausted), the source item is preserved and the player sees an error message.

### Chain Transmog

Multiple transmogs can be chained on the same item. Each transmog changes the item's type to match the new source. The old pool entry is freed to its positional sub-pool (based on the entry's position in the block, not the template's current display), so pool entries are never leaked.

## Identify (Scroll of Identification)

### Flow

1. Player right-clicks Scroll of Identification, targets a forge item
2. Server writes pending data to `orb_pending` with `orb_type = 'identify'`
3. Addon message `"ID:<currentItemName>"` is sent to show rename popup
4. Player types a new name (3-32 characters) and presses Enter or OK
5. Client sends `"N:<newName>"` addon message back to server
6. Server validates name format: alphanumeric, spaces, apostrophes, hyphens only
7. Name is stored in `orb_pending.new_name`
8. Spell 2 fires, `applyIdentify` sets `name_override` on the item state
9. `recreateItem` creates the new item with the custom name

### Validation Rules

- Length: 3 to 32 characters
- Allowed characters: letters, numbers, spaces, apostrophes, hyphens
- Pattern: `[%w%s'%-]`

## Influence System

The Awakener's Orb + Influenced Exalted Orb provide a two-step path to a guaranteed prefix.

### Step 1: Awakener's Orb

1. Player uses Awakener's Orb on a rare+ forge item
2. The item's first prefix (`prefix1_stat_id`) is extracted
3. The item is destroyed
4. The prefix stat ID and label are stored in `awakener_pending`
5. An Influenced Exalted Orb is created in the player's inventory with an enchantment tooltip showing the captured stat (e.g., "Infused with Agility")

### Step 2: Influenced Exalted Orb

1. Player uses Influenced Exalted Orb on a rare forge item
2. The guaranteed prefix from `awakener_pending` is applied as `prefix1_stat_id`
3. A random second prefix is rolled for `prefix2_stat_id`
4. Item is upgraded to epic quality
5. `awakener_pending` row is deleted

### Influence Enchantments

Each stat type maps to a unique enchantment token for tooltip display:

| Stat | Enchantment |
|---|---|
| Agility (3) | ENCHANTMENT_INFLUENCE_AGI |
| Strength (4) | ENCHANTMENT_INFLUENCE_STR |
| Intellect (5) | ENCHANTMENT_INFLUENCE_INT |
| Spirit (6) | ENCHANTMENT_INFLUENCE_SPI |
| Stamina (7) | ENCHANTMENT_INFLUENCE_STA |
| Defense (12) | ENCHANTMENT_INFLUENCE_DEF |
| Dodge (13) | ENCHANTMENT_INFLUENCE_DODGE |
| Parry (14) | ENCHANTMENT_INFLUENCE_PARRY |
| Block Rating (15) | ENCHANTMENT_INFLUENCE_BLOCK |
| Hit (31) | ENCHANTMENT_INFLUENCE_HIT |
| Crit (32) | ENCHANTMENT_INFLUENCE_CRIT |
| Haste (36) | ENCHANTMENT_INFLUENCE_HASTE |
| Expertise (37) | ENCHANTMENT_INFLUENCE_EXP |
| Attack Power (38) | ENCHANTMENT_INFLUENCE_AP |
| MP5 (43) | ENCHANTMENT_INFLUENCE_MP5 |
| Armor Pen (44) | ENCHANTMENT_INFLUENCE_ARPEN |
| Spell Power (45) | ENCHANTMENT_INFLUENCE_SP |
| Block Value (48) | ENCHANTMENT_INFLUENCE_BV |

## recreateItem Internals

`recreateItem(player, oldEntry, state)` is the core function that all orbs funnel through. It destroys the old forge item and creates a replacement with recalculated stats.

### Process

1. **Calculate item level**: Base level + `item_level_override` (from Scrap/Whetstone)
2. **Regenerate stats from scratch**: Calls `FORGE.generateItemStats()` using quality, level, slot, weapon size, suffix, and prefix stat IDs. Stats are never carried forward from the old item.
3. **Recalculate weapon damage**: Look up base DPS from `FORGE.ILVL_DPS[dpsCategory][itemLevel]`, apply quality multiplier, derive min/max from DPS and attack speed. Caster weapons sacrifice 1/3 DPS for spell power.
4. **Recalculate armor and block**: From `FORGE.computeArmor()` and `FORGE.computeBlockValue()`
5. **Generate item name**: Combine prefix labels + base name + suffix label, or use `name_override` from Scroll of Identification. Prepend `prefix3_label` if present (e.g., "Mirrored").
6. **Call CreateForgeItem()**: C++ allocates a pool entry matching `(item_class, item_subclass, inv_type, displayInfoId)` and inserts a new ItemTemplate into `sObjectMgr`
7. **Update virtual_item_instance**: Write all affix tracking columns for the new entry
8. **Transfer enchantments**: Read all enchant slots and gems from the old item, destroy old item, add new item to inventory, then restore enchantments and gems to the new item
9. **Refresh client cache**: Call `SendForgeItemQuery()` to push the new template data to the client

### Returns

- On success: `newEntry, itemName, stats`
- On failure (pool exhausted, etc.): `nil`

### Key Design Decision

Stats are always recalculated from the item's current affix state, never copied from the old template. This means every orb application produces correctly balanced stats for the item's quality and level, and any balance changes to the stat generation system automatically apply to all future orb uses.

## Addon Communication Protocol

The client addon (ForgeOrbs) communicates with the server using the addon message channel.

### Addon Prefix

`"FORB"` (4 characters, registered via `C_ChatInfo.RegisterAddonMessagePrefix`)

### Server to Client

| Message | Trigger | Client Action |
|---|---|---|
| `"ID:<itemName>"` | Scroll of Identification used | Show rename editbox popup |
| `"DV:<quality>\|<slotName>\|<sourceName>"` | Divine Orb used | Show transmog confirmation popup |

### Client to Server

| Message | Trigger | Server Action |
|---|---|---|
| `"N:<newName>"` | Player submits name | Store name in `orb_pending.new_name`, trigger cast |
| `"D:OK"` | Player confirms transmog | Trigger cast spell |
| `"D:NO"` | Player cancels transmog | Clean up pending data |

### Transport

Messages are sent via `WHISPER` channel (type 7) to the player themselves. The addon listens for `CHAT_MSG_ADDON` events filtered by the `"FORB"` prefix.

## Enchantment Preservation

When `recreateItem` destroys the old item and creates a replacement, all enchantments and socketed gems are preserved:

1. Before destruction: read all enchant slots (permanent, temporary, sockets) from the old item
2. Destroy old item and its template
3. Create new item with recalculated stats
4. Re-apply all enchantments and gems to the new item

This ensures that players don't lose their enchantments or gems when using orbs.

## Recipe System

### Skill Line

Recipes appear under a custom secondary profession: **"Forge - Smithing"** (skill ID 903). All characters learn this skill automatically and all recipes are auto-learned on login.

### Implementation

- Each recipe is a spell with `Reagent1`/`ReagentCount1` fields defining inputs
- The `ORB_RECIPE_OUTPUTS` Lua table maps recipe spell IDs to output item entries
- When a recipe spell completes, the handler looks up the output from `ORB_RECIPE_OUTPUTS` and adds the result item to the player's inventory

## File Structure

```
forge-loot-poe-orbs/
  mod.yaml                    # Manifest: name, version, dependencies, token declarations
  README.md                   # This file
  content/
    orb_tables.sql            # awakener_pending and orb_pending table creation
    orb_items.sql             # Item templates and spell definitions (2 spells per orb)
    orb_displays.sql          # ItemDisplayInfo DBC entries for orb icons
    orb_recipes.sql           # Recipe spells, skill line, SkillLineAbility entries
    orb_loot_pool.sql         # reference_loot_template with drop weights
  scripts/
    forge_orbs.lua            # Main orb logic (~1500 lines, @load-order 20)
    orb_recipes.lua           # Recipe data and auto-learning (@load-order 5)
  addon/
    ForgeOrbs/
      ForgeOrbs.toc           # Addon metadata (Interface: 30300)
      ForgeOrbs.lua           # Client-side popup handlers for identify and transmog
  prebuild/
    generate_orb_icons.py     # PNG to BLP2 icon converter with DXT1 compression
  icons/
    Interface/Icons/          # Source PNGs and generated BLP2 files for orb icons
```

### Token Categories (142 tokens in mod.yaml)

| Prefix | Count | Purpose |
|---|---|---|
| `ITEM_ORB_*` | 11 | Orb item template entries |
| `DISPLAYINFO_ORB_*` | 11 | Item display info IDs |
| `SPELL_ORB_*` | 11 | Instant spells (on-use targeting) |
| `SPELL_ORB_*_CAST` | 11 | Cast spells (1.5s cast bar) |
| `ENCHANTMENT_INFLUENCE_*` | 18 | Influence stat enchantments |
| `SPELL_RECIPE_*` | 8 | Crafting recipe spells |
| `SLA_*` | 9 | SkillLineAbility entries |
| `LOOT_FORGE_POOL_*` | 6 | Tiered loot pools (Common/Uncommon/Rare/Epic/Legendary/Artifact) |

---

## Design Philosophy

### Leveling vs Endgame

The currency system is designed so that leveling players naturally accumulate a stockpile for endgame:

- **Leveling**: Transmute interesting bases, test suffixes with Alterations, slam Regals casually for upgrades. Gamble Chaos/Alchemy for lucky jackpots. Replace gear from drops more than investing in it.
- **Endgame**: Regal/Annul loop for perfect prefixes (gated by Annulment consumption). Exalt as a gambling milestone. Awakener path for guaranteed influenced prefix on best-in-slot pieces.

### Key Tension Points

- **Regal vs Annulment**: Both drop at the same rate, but Annulment demand far exceeds Scouring in the perfection loop. When you run out of Annulments, Scouring is the painful fallback (costs ~20 Alterations to re-fish suffix).
- **Exalted**: Rare enough that each slam feels like a gamble. Miss? Live with the bad prefix until another drops. Not worth Annul-slamming like Regals.
- **Awakener**: The chase item. Guarantees the prefix you want via the Influenced Exalted path. Worth ~4-6 Exalts for most players (accept 3-4 useful prefixes) up to ~17 for perfectionists (1 specific prefix out of 18).
- **Mirror**: Insurance, not trophy. Snapshot a good item before risky Annul attempts. Rarer than Exalted so the insurance itself is a meaningful cost.
- **Scouring**: Borderline as a direct-use item, but never feels bad to find -- it's always 1/8th of an Exalt or 1/20th of a Mirror.