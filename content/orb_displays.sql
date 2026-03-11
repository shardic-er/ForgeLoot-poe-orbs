-- =============================================================================
-- ForgeLoot PoE Orbs: ItemDisplayInfo entries
-- =============================================================================
-- Custom display entries for orb item icons. Uses existing orb textures as
-- placeholders until custom BLP icons are generated.
-- =============================================================================

-- Transmutation (white/silver orb)
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
    DISPLAYINFO_ORB_TRANSMUTATION, '', '', '', '',
    'INV_Misc_Orb_01', '',
    0, 0, 0, 0, 0, 0, 0, 0,
    '', '', '', '', '', '', '', '', 0, 0
);

-- Regal (blue orb)
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
    DISPLAYINFO_ORB_REGAL, '', '', '', '',
    'INV_Misc_Orb_04', '',
    0, 0, 0, 0, 0, 0, 0, 0,
    '', '', '', '', '', '', '', '', 0, 0
);

-- Exalted (purple/gold orb)
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
    DISPLAYINFO_ORB_EXALTED, '', '', '', '',
    'INV_Misc_Orb_05', '',
    0, 0, 0, 0, 0, 0, 0, 0,
    '', '', '', '', '', '', '', '', 0, 0
);

-- Alchemy (gold/amber orb)
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
    DISPLAYINFO_ORB_ALCHEMY, '', '', '', '',
    'INV_Orb_Arcanite_01', '',
    0, 0, 0, 0, 0, 0, 0, 0,
    '', '', '', '', '', '', '', '', 0, 0
);

-- Scouring (dark/void orb)
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
    DISPLAYINFO_ORB_SCOURING, '', '', '', '',
    'INV_Enchant_VoidSphere', '',
    0, 0, 0, 0, 0, 0, 0, 0,
    '', '', '', '', '', '', '', '', 0, 0
);

-- Chaos (prismatic/swirling orb)
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
    DISPLAYINFO_ORB_CHAOS, '', '', '', '',
    'INV_Enchant_PrismaticSphere', '',
    0, 0, 0, 0, 0, 0, 0, 0,
    '', '', '', '', '', '', '', '', 0, 0
);

-- Divine (radiant/holy orb)
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
    DISPLAYINFO_ORB_DIVINE, '', '', '', '',
    'INV_Misc_Orb_03', '',
    0, 0, 0, 0, 0, 0, 0, 0,
    '', '', '', '', '', '', '', '', 0, 0
);
