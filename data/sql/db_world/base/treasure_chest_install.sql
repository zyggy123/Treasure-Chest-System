/***************************************************************************
* Treasure Chest System - SQL Installation v2.0
* Created for: AzerothCore
* Author: Zyggy123 (https://github.com/zyggy123/Treasure-Chest-System)
***************************************************************************/

-- =========================================================
-- 1. Clean up any previous installation
-- =========================================================
DELETE FROM gameobject_template       WHERE entry = 800001;
DELETE FROM gameobject_template_addon WHERE entry = 800001;
DELETE FROM gameobject_loot_template  WHERE Entry = 800001;

DROP TABLE IF EXISTS `custom_treasure_chest_loot`;
DROP TABLE IF EXISTS `custom_treasure_chest_config`;
DROP TABLE IF EXISTS `custom_treasure_chest_spawn`;

-- =========================================================
-- 2. Create the custom loot storage table
-- =========================================================
CREATE TABLE `custom_treasure_chest_loot` (
    `id`         INT          NOT NULL AUTO_INCREMENT,
    `item_entry` INT          NOT NULL COMMENT 'item_template.entry',
    `min_count`  INT          NOT NULL DEFAULT 1,
    `max_count`  INT          NOT NULL DEFAULT 1,
    `chance`     FLOAT        NOT NULL DEFAULT 100.0 COMMENT 'Drop chance 0-100',
    `comment`    VARCHAR(255) NOT NULL DEFAULT '',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Treasure Chest System – custom loot (not cached)';

-- =========================================================
-- 3. Create the config/state table (gold + hint)
-- =========================================================
CREATE TABLE `custom_treasure_chest_config` (
    `config_key`   VARCHAR(64)  NOT NULL,
    `config_value` VARCHAR(512) NOT NULL DEFAULT '',
    PRIMARY KEY (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Treasure Chest System – persistent config';

-- =========================================================
-- 4. Spawn position table
-- =========================================================
CREATE TABLE `custom_treasure_chest_spawn` (
    `id`          TINYINT UNSIGNED NOT NULL DEFAULT 1,
    `map_id`      SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `pos_x`       FLOAT NOT NULL DEFAULT 0,
    `pos_y`       FLOAT NOT NULL DEFAULT 0,
    `pos_z`       FLOAT NOT NULL DEFAULT 0,
    `orientation` FLOAT NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Treasure Chest System – active spawn position';

INSERT INTO `custom_treasure_chest_config` (`config_key`, `config_value`) VALUES
('gold_amount', '0'),
('hint',        '');

-- =========================================================
-- 5. Gameobject template (type 3 = chest, displayId 8686)
-- =========================================================
INSERT INTO `gameobject_template`
    (`entry`,`type`,`displayId`,`name`,`IconName`,`castBarCaption`,`unk1`,
     `size`,
     `Data0`,`Data1`,`Data2`,`Data3`,`Data4`,`Data5`,`Data6`,`Data7`,
     `Data8`,`Data9`,`Data10`,`Data11`,`Data12`,`Data13`,`Data14`,`Data15`,
     `Data16`,`Data17`,`Data18`,`Data19`,`Data20`,`Data21`,`Data22`,`Data23`,
     `AIName`,`ScriptName`,`VerifiedBuild`)
VALUES
    (800001, 3, 8686, 'Treasure Chest', '', '', '', 1,
     0, 800001, 0, 1, 0, 0, 0, 0,   -- Type 3 (Chest), Data1=800001
     0, 0, 0, 0, 0, 0, 0, 0,
     0, 0, 0, 0, 0, 0, 0, 0,
     '', '', 0);

-- =========================================================
-- 5. Addon entry (gold is managed by Lua — keep 0 here)
-- =========================================================
INSERT INTO `gameobject_template_addon` (`entry`, `faction`, `flags`, `mingold`, `maxgold`)
VALUES (800001, 0, 0, 0, 0);


-- =========================================================
-- 6. Placeholder row in gameobject_loot_template
--
--    CRITICAL: Chance MUST be > 0 (we use 100).
--    If Chance=0, the server evaluates loot at chest creation,
--    finds nothing, and sets the GO to GO_JUST_DEACTIVATED
--    (already-looted state) — making it permanently non-clickable.
--    With Chance=100, the chest is GO_READY and interactable.
--    Item 25 = Worn Shortsword (1c vendor value, effectively ignored).
--    Lua overrides what the player actually receives.
-- =========================================================
INSERT INTO `gameobject_loot_template`
    (`Entry`,`Item`,`Reference`,`Chance`,`QuestRequired`,`LootMode`,`GroupId`,`MinCount`,`MaxCount`,`Comment`)
VALUES
    (800001, 25, 0, 100, 0, 1, 0, 1, 1, 'PLACEHOLDER - required for chest interactability');

-- =========================================================
-- 7. Add test loot into our CUSTOM table (read live by Lua)
-- =========================================================
INSERT INTO `custom_treasure_chest_loot` (`item_entry`, `min_count`, `max_count`, `chance`, `comment`) VALUES
(2589, 1, 3, 100, 'Linen Cloth'),
(2070, 1, 2,  75, 'Darnassian Bleu'),
(4306, 1, 2,  50, 'Silk Cloth');


-- =========================================================
-- 7. Verification
-- =========================================================
SELECT 'gameobject_template'        AS tbl, entry  FROM gameobject_template        WHERE entry  = 800001;
SELECT 'gameobject_template_addon'  AS tbl, entry  FROM gameobject_template_addon  WHERE entry  = 800001;
SELECT 'custom_treasure_chest_loot' AS tbl, id, item_entry, min_count, max_count, chance, comment
    FROM custom_treasure_chest_loot;
SELECT 'custom_treasure_chest_config' AS tbl, config_key, config_value
    FROM custom_treasure_chest_config;
