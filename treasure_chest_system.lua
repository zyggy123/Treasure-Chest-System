-- Treasure Chest System
-- Author: Zyggy123 (https://github.com/zyggy123/Treasure-Chest-System)
-- Version: 1.0
-- Description: Advanced treasure chest system with dynamic loot and gold distribution

-- Constants and Configuration
local CONFIG = {
    CHEST_ENTRY = 500001,
    CHEST_DISPLAY_ID = 8686,
    DEBUG = true,
    COLORS = {
        DEBUG = "|cFF00FF00",
        ERROR = "|cFFFF0000",
        WARNING = "|cFFFFFF00",
        INFO = "|cFF00FFFF",
        SUCCESS = "|cFF00FF00",
        SYSTEM = "|cFFFF8000",
        PLAYER = "|cFFFF0000", -- Adăugat pentru numele playerului
        ZONE = "|cFFFF0000",   -- Adăugat pentru zonă
        RESET = "|r"
    },
    PREFIX = {
        DEBUG = "[Treasure Event]",
        CHAT = "[Treasure System]",
        EVENT = "[Treasure Event]" -- Adăugat pentru mesaje publice
    }
}

-- Adăugat variabila pentru hint
local currentHint = nil

-- Command Help System
local COMMANDS = {
    ["chest spawn"] = "Spawns a treasure chest at your location",
    ["chest list"] = "Lists current chest contents",
    ["chest clear"] = "Clears all chest contents",
    ["chest gold"] = "Sets gold amount (Usage: #chest gold <amount>)",
    ["chest add"] = "Adds item to chest (Usage: #chest add <itemID> <count>)",
    ["chest reload"] = "Reloads chest templates",
    ["chest addhint"] = "Adds a hint for the chest (Usage: #chest addhint <text>)",
    ["chest hint"] = "Shows the current chest hint"
}

-- Utility Functions
local function GetColoredText(color, text)
    return CONFIG.COLORS[color] .. text .. CONFIG.COLORS.RESET
end

-- Enhanced Debug Function
local function Debug(msg, type)
    if CONFIG.DEBUG then
        local messageType = type or "INFO"
        print(GetColoredText("SYSTEM", CONFIG.PREFIX.DEBUG) .. " " .. 
              GetColoredText(messageType, msg))
    end
end

-- Enhanced Zone Detection System
local function GetZoneName(player)
    local zoneId = player:GetZoneId()
    local areaId = player:GetAreaId()

    -- Get zone and area names directly from client DB
    local zoneName = GetAreaName(zoneId)
    local areaName = GetAreaName(areaId)

    -- Build informative location string
    local locationName = zoneName
    if areaName and areaName ~= zoneName then
        locationName = zoneName .. " - " .. areaName
    end

    return locationName
end

-- Enhanced Message System
local function SendSystemMessage(player, msg, messageType)
    if player:IsGM() then
        local prefix = GetColoredText("SYSTEM", CONFIG.PREFIX.CHAT)
        local message = GetColoredText(messageType or "INFO", msg)
        player:SendBroadcastMessage(prefix .. " " .. message)
    end
end

local function SendWorldSystemMessage(msg, messageType)
    local prefix = GetColoredText("SYSTEM", CONFIG.PREFIX.EVENT)
    local message = GetColoredText(messageType or "INFO", msg)
    SendWorldMessage(prefix .. " " .. message)
end

-- Command Validation
local function ValidateCommand(player, cmd, args)
    Debug("Validating command: " .. cmd)
    if not player:IsGM() and cmd ~= "hint" then
        SendSystemMessage(player, "You don't have permission to use this command.", "ERROR")
        return false
    end
    return true
end

-- Help System
local function ShowHelp(player)
    if player:IsGM() then
        SendSystemMessage(player, "Available Treasure Chest Commands:", "INFO")
        for cmd, desc in pairs(COMMANDS) do
            SendSystemMessage(player, string.format("#%s - %s", cmd, desc), "INFO")
        end
    else
        player:SendBroadcastMessage("Available commands: #chest hint")
    end
end

-- Hint System Functions
local function SetHint(player, hint)
    currentHint = hint
    if player:IsGM() then
        SendSystemMessage(player, "Hint set successfully: " .. hint, "SUCCESS")
    end
end

local function ShowHint(player)
    if currentHint then
        player:SendBroadcastMessage(GetColoredText("INFO", "Treasure Hint: " .. currentHint))
    else
        local zoneName = GetColoredText("ZONE", GetZoneName(player))
        player:SendBroadcastMessage(GetColoredText("INFO", "The treasure chest was last seen in: " .. zoneName))
    end
end
-- Loot Management Functions
local function AddLoot(player, itemEntry, count)
    Debug("Adding loot: Item " .. itemEntry .. " Count: " .. count)

    -- Verify item exists
    local itemQuery = string.format("SELECT entry, name FROM item_template WHERE entry = %d;", itemEntry)
    local itemResult = WorldDBQuery(itemQuery)

    if not itemResult then
        SendSystemMessage(player, "Invalid Item ID!", "ERROR")
        return
    end

    local itemName = itemResult:GetString(1)

    -- Add item to loot template
    local insertQuery = string.format([[
        INSERT INTO gameobject_loot_template 
        (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment) 
        VALUES 
        (%d, %d, 0, 100, 0, 1, 0, %d, %d, 'Item_%d');
    ]], CONFIG.CHEST_ENTRY, itemEntry, count, count, itemEntry)
    WorldDBExecute(insertQuery)

    if player:IsGM() then
        SendSystemMessage(player, string.format("Added item %s (x%d) to treasure chest!", 
            itemName, count), "SUCCESS")
        -- Adăugat mesajul dublu pentru reload
        SendSystemMessage(player, "Use .reload gameobject_loot_template for new item to be available in new chest", "ERROR")
        SendSystemMessage(player, "Use .reload gameobject_loot_template for new item to be available in new chest", "ERROR")
    end
    Debug(string.format("Added item %d (x%d) to loot template", itemEntry, count))
end

local function SetGold(player, amount)
    Debug("Setting gold amount: " .. amount)

    local copperAmount = amount * 10000

    local updateQuery = string.format([[
        UPDATE gameobject_template_addon 
        SET mingold = %d, maxgold = %d 
        WHERE entry = %d;
    ]], copperAmount, copperAmount, CONFIG.CHEST_ENTRY)
    WorldDBExecute(updateQuery)

    SendWorldSystemMessage(string.format("GM %s set treasure chest gold to %d!", 
        player:GetName(), amount), "SUCCESS")
    SendSystemMessage(player, string.format("Gold amount set to: %d gold", amount), "SUCCESS")
    Debug("Gold amount updated in database")
end

local function ClearLoot(player)
    Debug("Clearing all loot")

    -- Clear existing loot
    WorldDBExecute(string.format("DELETE FROM gameobject_loot_template WHERE Entry = %d;", CONFIG.CHEST_ENTRY))

    -- Add empty entry
    WorldDBExecute(string.format([[
        INSERT INTO gameobject_loot_template 
        (Entry, Item, Reference, Chance, QuestRequired, LootMode, GroupId, MinCount, MaxCount, Comment) 
        VALUES 
        (%d, 0, 0, 100, 0, 1, 0, 0, 0, 'Empty');
    ]], CONFIG.CHEST_ENTRY))

    -- Reset gold
    WorldDBExecute(string.format([[
        UPDATE gameobject_template_addon 
        SET mingold = 0, maxgold = 0 
        WHERE entry = %d;
    ]], CONFIG.CHEST_ENTRY))

    SendWorldSystemMessage(string.format("GM %s cleared the treasure chest contents!", 
        player:GetName()), "WARNING")
    SendSystemMessage(player, "Chest loot and gold cleared!", "SUCCESS")
    Debug("Chest loot cleared from database")
end

local function SpawnChest(player)
    Debug("Attempting to spawn chest")

    -- Verify loot exists
    local lootQuery = string.format([[
        SELECT COUNT(*) as count 
        FROM gameobject_loot_template 
        WHERE Entry = %d AND Item > 0;
    ]], CONFIG.CHEST_ENTRY)
    local lootResult = WorldDBQuery(lootQuery)

    -- Check gold
    local goldQuery = string.format([[
        SELECT mingold 
        FROM gameobject_template_addon 
        WHERE entry = %d;
    ]], CONFIG.CHEST_ENTRY)
    local goldResult = WorldDBQuery(goldQuery)
    local hasGold = goldResult and goldResult:GetUInt32(0) > 0

    if (not lootResult or lootResult:GetUInt32(0) == 0) and not hasGold then
        SendSystemMessage(player, "Cannot spawn empty chest. Add loot or gold first!", "ERROR")
        return
    end

    local x, y, z = player:GetLocation()
    local o = player:GetO()

    local chest = player:SummonGameObject(CONFIG.CHEST_ENTRY, x, y, z, o, 300)
    if chest then
        local zoneName = GetColoredText("ZONE", GetZoneName(player))
        SendWorldSystemMessage(string.format("A surprise chest has appeared in %s!", zoneName), "INFO")
        SendSystemMessage(player, "Chest spawned successfully!", "SUCCESS")
        Debug(string.format("Chest spawned at: X:%f Y:%f Z:%f", x, y, z))
    else
        Debug("Failed to spawn chest")
        SendSystemMessage(player, "Failed to spawn chest!", "ERROR")
    end
end

local function ListChests(player)
    Debug("Listing chest loot")

    local query = string.format([[
        SELECT Item, MinCount, MaxCount, Comment 
        FROM gameobject_loot_template 
        WHERE Entry = %d;
    ]], CONFIG.CHEST_ENTRY)
    local result = WorldDBQuery(query)

    if not result then
        SendSystemMessage(player, "No loot configured for chest", "WARNING")
        return
    end

    SendSystemMessage(player, "Current chest configuration:", "INFO")
    repeat
        local itemId = result:GetUInt32(0)
        local minCount = result:GetUInt32(1)
        local maxCount = result:GetUInt32(2)
        local comment = result:GetString(3)
        if itemId > 0 then
            SendSystemMessage(player, string.format("Item: %d (%s) - Count: %d-%d", 
                itemId, comment, minCount, maxCount), "INFO")
        end
    until not result:NextRow()

    -- Show gold configuration
    local goldQuery = string.format([[
        SELECT mingold 
        FROM gameobject_template_addon 
        WHERE entry = %d;
    ]], CONFIG.CHEST_ENTRY)
    local goldResult = WorldDBQuery(goldQuery)
    if goldResult then
        local goldAmount = math.floor(goldResult:GetUInt32(0) / 10000)
        SendSystemMessage(player, string.format("Configured gold amount: %d", goldAmount), "INFO")
    end

    SendWorldSystemMessage(string.format("GM %s is checking the treasure chest contents!", 
        player:GetName()), "INFO")
end

-- Command Handler
local function OnChatCommand(event, player, msg, Type, lang)
    if msg:sub(1,1) ~= "#" then return end

    local cmd, args = msg:match("^#chest%s+(%w+)%s*(.*)")
    if not cmd then 
        if msg == "#chest" then
            ShowHelp(player)
        end
        return 
    end

    Debug("Received command: chest " .. cmd)

    -- Permite comanda hint pentru toți playerii
    if cmd == "hint" then
        ShowHint(player)
        return false
    end

    if not ValidateCommand(player, cmd, args) then return end

    if cmd == "spawn" then
        SpawnChest(player)
    elseif cmd == "list" then
        ListChests(player)
    elseif cmd == "add" then
        local entry, count = args:match("(%d+)%s+(%d+)")
        if entry and count then
            AddLoot(player, tonumber(entry), tonumber(count))
        else
            SendSystemMessage(player, "Usage: #chest add <itemID> <count>", "WARNING")
        end
    elseif cmd == "addhint" then
        if args and args ~= "" then
            SetHint(player, args)
        else
            SendSystemMessage(player, "Usage: #chest addhint <text>", "WARNING")
        end
    elseif cmd == "clear" then
        ClearLoot(player)
    elseif cmd == "gold" then
        local amount = tonumber(args)
        if amount then
            SetGold(player, amount)
        else
            SendSystemMessage(player, "Usage: #chest gold <amount>", "WARNING")
        end
    elseif cmd == "reload" then
        player:ExecuteCommand("reload gameobject_loot_template")
        SendWorldSystemMessage(string.format("GM %s reloaded treasure chest templates!", 
            player:GetName()), "SUCCESS")
    else
        ShowHelp(player)
    end

    return false
end

-- Chest Interaction Handler
RegisterGameObjectEvent(CONFIG.CHEST_ENTRY, 14, function(event, go, player)
    Debug(string.format("OnUse triggered for GO ID: %d", go:GetGUIDLow()))

    -- Load loot
    local lootQuery = string.format([[
        SELECT Item, MinCount, MaxCount 
        FROM gameobject_loot_template 
        WHERE Entry = %d;
    ]], CONFIG.CHEST_ENTRY)
    local lootResult = WorldDBQuery(lootQuery)

    -- Load gold
    local goldQuery = string.format([[
        SELECT mingold 
        FROM gameobject_template_addon 
        WHERE entry = %d;
    ]], CONFIG.CHEST_ENTRY)
    local goldResult = WorldDBQuery(goldQuery)
    local goldAmount = goldResult and math.floor(goldResult:GetUInt32(0) / 10000) or 0

    -- Award gold
    if goldAmount > 0 then
        player:ModifyMoney(goldAmount * 10000)
        Debug(string.format("Added %d gold to player", goldAmount))
        SendWorldSystemMessage(string.format("%s found %d gold in the treasure chest!", 
            player:GetName(), goldAmount), "SUCCESS")
    end

-- Award items
if lootResult then
    local itemsAwarded = false
    repeat
        local itemId = lootResult:GetUInt32(0)
        local minCount = lootResult:GetUInt32(1)
        local maxCount = lootResult:GetUInt32(2)
        local count = math.random(minCount, maxCount)

        if count > 0 and itemId > 0 then
            if player:AddItem(itemId, count) then
                Debug(string.format("Added item %d (x%d) to player", itemId, count))
                itemsAwarded = true
            else
                SendSystemMessage(player, "Your inventory is full!", "ERROR")
                return true
            end
        end
    until not lootResult:NextRow()

    -- Send message only once after all items are awarded
    if itemsAwarded then
        local playerName = GetColoredText("PLAYER", player:GetName())
        SendWorldMessage(GetColoredText("SYSTEM", CONFIG.PREFIX.EVENT) .. " " .. 
                      playerName .. " found the treasure chest! Better luck next time!")
    end
end

    -- Despawn chest
    go:DespawnOrUnsummon(5000)

    return true
end)

-- Register Events
RegisterPlayerEvent(18, OnChatCommand)

Debug("Treasure Chest System loaded successfully!", "SUCCESS")