
/***************************************************************************
* Treasure Chest System - SQL Installation
* Created for: AzerothCore
* Author: Zyggy123 (https://github.com/zyggy123/Treasure-Chest-System)
*
* This SQL script sets up the necessary database entries for the 
* Treasure Chest System. It creates a custom gameobject that will
* serve as the treasure chest, configures its properties, and sets
* up the initial loot template.

***************************************************************************/
-- 1. First we delete any existing entries for safetyDELETE FROM gameobject_template WHERE entry = 500001;
DELETE FROM gameobject_template_addon WHERE entry = 500001;
DELETE FROM gameobject_loot_template WHERE Entry = 500001;

-- 2. Create gameobject_template entry
INSERT INTO `gameobject_template` (`entry`, `type`, `displayId`, `name`, `IconName`, `castBarCaption`, `unk1`, `size`, `Data0`, `Data1`, `Data2`, `Data3`, `Data4`, `Data5`, `Data6`, `Data7`, `Data8`, `Data9`, `Data10`, `Data11`, `Data12`, `Data13`, `Data14`, `Data15`, `Data16`, `Data17`, `Data18`, `Data19`, `Data20`, `Data21`, `Data22`, `Data23`, `AIName`, `ScriptName`, `VerifiedBuild`) VALUES
(500001, 3, 8686, 'Treasure Chest', '', '', '', 1, 57, 500001, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', 0);

-- 3. We create the gameobject_template_addon entry
INSERT INTO `gameobject_template_addon` (`entry`, `faction`, `flags`, `mingold`, `maxgold`) VALUES
(500001, 0, 0, 0, 0);

-- 4. We create loot template with some test items
INSERT INTO `gameobject_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`, `Comment`) VALUES 
(500001, 2589, 0, 100, 0, 1, 0, 1, 3, 'Linen Cloth'),
(500001, 2070, 0, 75, 0, 1, 0, 1, 2, 'Darnassian Bleu'),
(500001, 4306, 0, 50, 0, 1, 0, 1, 2, 'Silk Cloth');

-- 5. We check if everything was created correctly
SELECT * FROM gameobject_template WHERE entry = 500001;
SELECT * FROM gameobject_template_addon WHERE entry = 500001;
SELECT * FROM gameobject_loot_template WHERE Entry = 500001;