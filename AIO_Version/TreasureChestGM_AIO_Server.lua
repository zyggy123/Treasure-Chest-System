-- Treasure Chest System (AIO Version)
-- Author: Zyggy123 (https://github.com/zyggy123/Treasure-Chest-System)
-- Version: 2.0 (AIO Integration)
-- Description: Advanced treasure chest system with dynamic loot and AIO GM UI.

local AIO = AIO or require("AIO")
local MyHandlers = AIO.AddHandlers("TreasureChestGM", {})
-- ============================================================
-- Configuration
-- ============================================================


local CONFIG = {
    CHEST_ENTRY  = 800001,
    DEBUG        = false,
    MIN_GM_LEVEL = 3,
    LOOT_TABLE   = "custom_treasure_chest_loot",
    CONFIG_TABLE = "custom_treasure_chest_config",
    SPAWN_TABLE  = "custom_treasure_chest_spawn",
    COLORS = {
        ERROR   = "|cFFFF0000",
        WARNING = "|cFFFFFF00",
        INFO    = "|cFF00FFFF",
        SUCCESS = "|cFF00FF00",
        SYSTEM  = "|cFFFF8000",
        PLAYER  = "|cFFFFFF00",
        ZONE    = "|cFFADD8E6",
        RESET   = "|r"
    },
    PREFIX = {
        CHAT  = "[Treasure System]",
        EVENT = "[Treasure Event]"
    }
}

-- ============================================================
-- Utility helpers
-- ============================================================

local function Color(key, text)
    return (CONFIG.COLORS[key] or "") .. tostring(text) .. CONFIG.COLORS.RESET
end

local function Debug(msg)
    if CONFIG.DEBUG then
        -- so we can trace issues without restarting the server.
        print("[TCS-DBG] " .. tostring(msg))
    end
end

-- Send a colored message only to the given player
local function Msg(player, msg, colorKey)
    player:SendBroadcastMessage(Color("SYSTEM", CONFIG.PREFIX.CHAT) ..
        " " .. Color(colorKey or "INFO", msg))
end

-- Broadcast to the whole server
local function World(msg, colorKey)
    SendWorldMessage(Color("SYSTEM", CONFIG.PREFIX.EVENT) ..
        " " .. Color(colorKey or "INFO", msg))
end

-- ============================================================
-- Zone/location helper
-- GetAreaName() exists in AzerothCore Eluna builds and reads
-- area names from the loaded DBC data. We use pcall so the
-- script never crashes if a future build removes it.
-- ============================================================
local function GetLocationString(player)
    local zoneId = player:GetZoneId()
    local areaId = player:GetAreaId()

    -- Try GetAreaName() (available in AzerothCore Eluna)
    local ok, zoneName = pcall(GetAreaName, zoneId)
    if ok and zoneName and zoneName ~= "" then
        local ok2, areaName = pcall(GetAreaName, areaId)
        if ok2 and areaName and areaName ~= "" and areaName ~= zoneName then
            return zoneName .. " - " .. areaName
        end
        return zoneName
    end

    -- Fallback: raw IDs (safe on any build)
    return string.format("Map %d / Zone %d", player:GetMapId(), zoneId)
end

-- ============================================================
-- Config DB helpers  (gold & hint stored in custom_treasure_chest_config)
-- ============================================================

local function GetConfig(key)
    local r = WorldDBQuery(string.format(
        "SELECT config_value FROM %s WHERE config_key = '%s' LIMIT 1;",
        CONFIG.CONFIG_TABLE, key))
    return r and r:GetString(0) or nil
end

local function SetConfig(key, value)
    WorldDBExecute(string.format(
        "UPDATE %s SET config_value = '%s' WHERE config_key = '%s';",
        CONFIG.CONFIG_TABLE, tostring(value), key))
end

-- ============================================================
-- GM level check
-- ============================================================
local function IsAuthorized(player)
    if not player:IsGM() then return false end
    if player:GetGMRank() < CONFIG.MIN_GM_LEVEL then return false end
    return true
end

-- ============================================================
-- COMMAND: #chest add <itemID> <count>
-- Inserts into custom_treasure_chest_loot (NOT gameobject_loot_template)
-- No reload needed — data is read live at chest-open time.
-- ============================================================
local function CmdAdd(player, itemEntry, count)
    -- Validate item exists
    local q = WorldDBQuery(string.format(
        "SELECT entry, name FROM item_template WHERE entry = %d LIMIT 1;", itemEntry))
    if not q then
        Msg(player, "Invalid item ID: " .. itemEntry, "ERROR")
        return
    end
    local itemName = q:GetString(1)
    local safeName = itemName:gsub("'", "''")

    WorldDBExecute(string.format([[
        INSERT INTO %s (item_entry, min_count, max_count, chance, comment)
        VALUES (%d, %d, %d, 100, '%s');
    ]], CONFIG.LOOT_TABLE, itemEntry, count, count, safeName))

    Msg(player, string.format("Added %s x%d to the chest loot.", safeName, count), "SUCCESS")
    Msg(player, "Changes are live — no reload needed. Spawn a new chest to use updated loot.", "INFO")
end

-- ============================================================
-- COMMAND: #chest gold <amount>
-- Stores gold in custom_treasure_chest_config.
-- ============================================================
local function CmdGold(player, amount)
    SetConfig("gold_amount", tostring(amount))
    World(string.format("GM %s set treasure chest gold to %d gold!", player:GetName(), amount), "SUCCESS")
    Msg(player, string.format("Gold set to %d. No reload needed.", amount), "SUCCESS")
end

-- ============================================================
-- COMMAND: #chest clear
-- Deletes all rows from the custom loot table + resets gold.
-- ============================================================
local function CmdClear(player)
    WorldDBExecute("DELETE FROM " .. CONFIG.LOOT_TABLE .. ";")
    SetConfig("gold_amount", "0")
    World(string.format("GM %s cleared the treasure chest!", player:GetName()), "WARNING")
    Msg(player, "Chest loot and gold cleared. No reload needed.", "SUCCESS")
end

-- ============================================================
-- COMMAND: #chest list
-- ============================================================
local function CmdList(player)
    Msg(player, "=== Chest Configuration ===", "INFO")

    local r = WorldDBQuery(string.format([[
        SELECT item_entry, min_count, max_count, chance, comment
        FROM %s ORDER BY id;
    ]], CONFIG.LOOT_TABLE))

    if not r then
        Msg(player, "  No items configured.", "WARNING")
    else
        repeat
            local entry    = r:GetUInt32(0)
            local minC     = r:GetUInt32(1)
            local maxC     = r:GetUInt32(2)
            local chance   = r:GetFloat(3)
            local comment  = r:GetString(4)
            Msg(player, string.format("  [%d] %s  x%d-%d  (%.0f%%)",
                entry, comment, minC, maxC, chance), "INFO")
        until not r:NextRow()
    end

    local gold = tonumber(GetConfig("gold_amount") or "0") or 0
    Msg(player, string.format("  Gold: %d gold", gold), "INFO")

    local hint = GetConfig("hint") or ""
    if hint ~= "" then
        Msg(player, "  Hint: " .. hint, "INFO")
    end

    Msg(player, "=== End ===", "INFO")
end



-- ============================================================
-- COMMAND: #chest spawn
--
-- Uses PerformIngameSpawn(type, entry, mapId, x, y, z, o, save, 0, phase)
--   save = true  → chest is written to the `gameobject` DB table
--                  and survives ANY player logout / server crash.
--   duration = 0 → no auto-timer; we delete from DB manually when looted.
-- Falls back to player:SummonGameObject() if PerformIngameSpawn fails.
-- ============================================================
local function CmdSpawn(player)

    local lootR     = WorldDBQuery(string.format("SELECT COUNT(*) FROM %s;", CONFIG.LOOT_TABLE))
    local lootCount = lootR and lootR:GetUInt32(0) or 0

    local gold = tonumber(GetConfig("gold_amount") or "0") or 0

    if lootCount == 0 and gold == 0 then
        Msg(player, "Cannot spawn an empty chest. Add items or gold first!", "ERROR")
        return
    end

    local x, y, z, o = player:GetLocation()
    local mapId       = player:GetMapId()

    local chest      = nil
    local persistent = false

    -- Param #4 must be instanceId! 
    -- Signature: PerformIngameSpawn(spawnType, entry, mapId, instanceId, x, y, z, o, save, spawntime, phase)
    local instanceId = player:GetInstanceId()

    local ok, result = pcall(PerformIngameSpawn,
        2, CONFIG.CHEST_ENTRY, mapId, instanceId, x, y, z, o, true, 0)


    if ok and result then
        chest      = result
        persistent = true
    else
        chest = player:SummonGameObject(CONFIG.CHEST_ENTRY, x, y, z, o, 3600)
        if chest then
        end
    end

    if chest then
        local loc = Color("ZONE", GetLocationString(player))
        World("A treasure chest has appeared in " .. loc .. "!", "INFO")
        Msg(player, "Chest spawned! (It is now saved in the world)", "SUCCESS")
    else
        Msg(player, "Failed to spawn chest! Check server logs.", "ERROR")
    end
end

-- ============================================================
-- COMMAND: #chest cleanup
-- Deletes all chests from the world and the database.
-- ============================================================
local function CmdCleanup(player)
    -- Remove from DB (in AC, gameobject id is the entry)
    WorldDBExecute("DELETE FROM gameobject WHERE id = " .. CONFIG.CHEST_ENTRY .. ";")
    
    -- Despawn active ones near the player
    local count = 0
    local gos = player:GetGameObjectsInRange(50000) -- get all
    if gos then
        for _, go in ipairs(gos) do
            if go:GetEntry() == CONFIG.CHEST_ENTRY then
                go:RemoveFromWorld()
                count = count + 1
            end
        end
    end
    
    Msg(player, string.format("Cleanup complete! Despawned %d active chests and cleared DB.", count), "SUCCESS")
end

-- ============================================================
-- COMMAND: #chest addhint <text>
-- Persists hint to DB so it survives server restarts.
-- ============================================================
local function CmdAddHint(player, text)
    -- Escape single quotes to avoid SQL injection
    local safe = text:gsub("'", "''")
    SetConfig("hint", safe)
    Msg(player, "Hint saved: " .. text, "SUCCESS")
end

-- ============================================================
-- COMMAND: #chest hint  (available to ALL players)
-- ============================================================
local function CmdHint(player)
    local hint = GetConfig("hint") or ""
    if hint ~= "" then
        player:SendBroadcastMessage(Color("INFO",
            "[Treasure] Hint: " .. hint))
    else
        local loc = Color("ZONE", GetLocationString(player))
        player:SendBroadcastMessage(Color("INFO",
            "[Treasure] The treasure was last seen around: " .. loc))
    end
end

-- ============================================================
-- Help
-- ============================================================
local HELP = {
    {"#chest spawn",          "Spawns the treasure chest at your location"},
    {"#chest list",           "Lists configured loot and gold"},
    {"#chest cleanup",        "Removes all spawned chests from the world"},
    {"#chest add <id> <n>",   "Adds item (no reload needed!)"},
    {"#chest clear",          "Clears all items and gold"},
    {"#chest gold <amount>",  "Sets gold reward"},
    {"#chest addhint <text>", "Sets a hint for players"},
    {"#chest hint",           "Shows the hint (available to everyone)"},
}

local function ShowHelp(player)
    if player:IsGM() then
        Msg(player, "=== Treasure Chest Commands ===", "INFO")
        for _, row in ipairs(HELP) do
            Msg(player, string.format("  %-28s - %s", row[1], row[2]), "INFO")
        end
    else
        player:SendBroadcastMessage(Color("INFO",
            "[Treasure System] Type #chest hint to get a clue!"))
    end
end

-- ============================================================
-- Chat command dispatcher
-- ============================================================
local function OnChatCommand(event, player, msg, Type, lang)
    if msg:sub(1,1) ~= "#" then return end

    -- #chest with no sub-command
    if msg:match("^#chest%s*$") then
        ShowHelp(player)
        return false
    end

    local cmd, args = msg:match("^#chest%s+(%S+)%s*(.*)")
    if not cmd then return end


    -- hint is open to all players
    if cmd == "hint" then
        CmdHint(player)
        return false
    end

    -- everything else is GM-only
    if not IsAuthorized(player) then
        Msg(player, string.format(
            "You need GM level %d+ to use chest commands.", CONFIG.MIN_GM_LEVEL), "ERROR")
        return false
    end

    if cmd == "spawn" then
        CmdSpawn(player)
    elseif cmd == "list" then
        CmdList(player)
    elseif cmd == "cleanup" then
        CmdCleanup(player)
    elseif cmd == "add" then
        local id, count = args:match("(%d+)%s+(%d+)")
        if id and count then
            CmdAdd(player, tonumber(id), tonumber(count))
        else
            Msg(player, "Usage: #chest add <itemID> <count>", "WARNING")
        end
    elseif cmd == "gold" then
        local amount = tonumber(args)
        if amount and amount >= 0 then
            CmdGold(player, amount)
        else
            Msg(player, "Usage: #chest gold <amount>", "WARNING")
        end
    elseif cmd == "clear" then
        CmdClear(player)
    elseif cmd == "addhint" then
        if args and args ~= "" then
            CmdAddHint(player, args)
        else
            Msg(player, "Usage: #chest addhint <text>", "WARNING")
        end
    else
        ShowHelp(player)
    end

    return false
end

-- ============================================================
-- EVENT 14 = GAMEOBJECT_EVENT_ON_USE
-- Fires when a player right-clicks the chest.
-- ============================================================
local chestLooted = {}   -- [GUIDLow] = true, prevents double loot

local function OnChestInteract(event, go, player)
    local guid = go:GetGUIDLow()
    
    if chestLooted[guid] then
        return true
    end
    
    chestLooted[guid] = true   -- prevent double-looting
    GiveLootToPlayer(go, player)
    return true
end

RegisterGameObjectEvent(CONFIG.CHEST_ENTRY, 14, OnChestInteract)

-- ============================================================
-- Shared loot logic (called from event 14)
-- ============================================================
function GiveLootToPlayer(go, player)
    local anyReward = false

    -- Gold
    local gold = tonumber(GetConfig("gold_amount") or "0") or 0
    if gold > 0 then
        player:ModifyMoney(gold * 10000)
        anyReward = true
    end

    -- Items
    local lootR = WorldDBQuery(string.format(
        "SELECT item_entry, min_count, max_count, chance FROM %s ORDER BY id;",
        CONFIG.LOOT_TABLE))

    if lootR then
        local rowNum = 0
        repeat
            rowNum = rowNum + 1
            local itemId   = lootR:GetUInt32(0)
            local minCount = lootR:GetUInt32(1)
            local maxCount = lootR:GetUInt32(2)
            local chance   = lootR:GetFloat(3)

            if math.random(0, 100) <= chance then
                local count = (minCount == maxCount) and minCount
                              or math.random(minCount, maxCount)
                local added = player:AddItem(itemId, count)
                if added then
                    anyReward = true
                else
                    Msg(player, "Inventory full!", "ERROR")
                    break
                end
            end
        until not lootR:NextRow()
    else
    end

    if anyReward then
        Msg(player,
            string.format("Treasure looted! Check your bags%s.",
                gold > 0 and string.format(" (+%d gold)", gold) or ""),
            "SUCCESS")
        World(Color("PLAYER", player:GetName()) ..
            Color("INFO", " found the treasure chest! Better luck next time!"))
    else
        Msg(player, "The chest was empty...", "WARNING")
    end

    -- Remove from DB
    -- Aggressive delete: wipe the entry from gameobject table so it doesn't
    -- respawn after server restart.
    WorldDBExecute("DELETE FROM gameobject WHERE id = " .. CONFIG.CHEST_ENTRY .. ";")

    go:RemoveFromWorld()
end

-- ============================================================
-- Register AIO Handlers
-- ============================================================
-- We route the secure AIO message directly into the existing chat handler
-- so all validation and GM level checks are preserved.
function MyHandlers.ExecuteCommand(player, msg)
    if not player or not msg then return end
    OnChatCommand(18, player, msg, 0, 0)
end

-- Optional: we keep the chat hook just in case the GM wants to type manually,
-- but the UI will now send it hidden via AIO!
RegisterPlayerEvent(18, OnChatCommand)
