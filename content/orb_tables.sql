-- =============================================================================
-- ForgeLoot PoE Orbs: Custom tables
-- =============================================================================

-- Tracks which prefix was consumed by Awakener's Orb, so the Influenced
-- Exalted Orb can apply it as a guaranteed prefix when upgrading rare->epic.
-- One pending influence per player at a time.
CREATE TABLE IF NOT EXISTS `awakener_pending` (
    `player_guid` INT UNSIGNED NOT NULL,
    `prefix_stat_id` TINYINT UNSIGNED NOT NULL,
    `prefix_label` VARCHAR(64) NOT NULL DEFAULT '',
    PRIMARY KEY (`player_guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Cross-state pending data for addon-message-based orbs (identify, transmog).
-- Item ON_USE runs in MAP state, addon messages run in WORLD state, cast
-- completion runs in MAP state. Local Lua tables aren't shared, so this DB
-- table bridges the three.
-- orb_pending is ephemeral (in-flight data only), safe to recreate on schema change
DROP TABLE IF EXISTS `orb_pending`;
CREATE TABLE `orb_pending` (
    `player_guid` INT UNSIGNED NOT NULL,
    `orb_type` VARCHAR(16) NOT NULL,
    `target_entry` INT UNSIGNED NOT NULL DEFAULT 0,
    `orb_item_entry` INT UNSIGNED NOT NULL DEFAULT 0,
    `timestamp` INT UNSIGNED NOT NULL,
    `new_name` VARCHAR(64) NULL,
    `equipped_entry` INT UNSIGNED NULL,
    `source_entry` INT UNSIGNED NULL,
    `display_id` INT UNSIGNED NULL,
    `display_entry` INT UNSIGNED NULL,
    `source_item_class` TINYINT UNSIGNED NULL,
    `source_item_subclass` TINYINT UNSIGNED NULL,
    `source_inv_type` TINYINT UNSIGNED NULL,
    PRIMARY KEY (`player_guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
