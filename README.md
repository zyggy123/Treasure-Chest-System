<h1 align="center">Treasure Chest System</h1>
<p align="center">
<img src="https://github.com/zyggy123/Treasure-Chest-System/blob/main/icon.png" />
</p>


```markdown
# 🌟 Treasure Chest System

## 🗺️ Description
A dynamic treasure chest system for **AzerothCore** that allows Game Masters to create and manage treasure chests with custom loot and hints. Players can discover and loot these chests, with server-wide announcements for discoveries.

---

## 🚀 Installation Guide  
Follow these steps to install the script:  

### 1️⃣ **Download the Files**  
- **Lua Script**: Copy the `treasure_chest_system.lua` file to your `lua_scripts` folder.  
  > 📂 **Path Example**: `AzerothCore/server/lua_scripts/`  

### 2️⃣ **Execute the SQL Script**  
1. Open a database management tool like **HeidiSQL**, **Navicat**, or **MySQL Workbench**.  
2. Connect to your **AzerothCore world database** (commonly named `acore_world`).  
3. Import and execute the provided SQL script (`data/sql/db_world/base/treasure_chest_install.sql`).  

### 3️⃣ **Restart the Server**  
Once the Lua script is in place and the SQL script is executed:  
1. Restart your server to load the new script and changes.  
2. You’re good to go! 🎉  

---

## 📜 SQL Details  
The SQL installation script:  
- 🛠️ **Creates** a custom gameobject (ID: `800001`).  
- 🎨 **Sets** the chest model (`DisplayID: 8686`).  
- ⚙️ **Configures** basic properties (type `3` for chest).  
- 📦 **Creates** custom tables for live loot and config storage (`custom_treasure_chest_loot`, etc.)

---

## ⚙️ Configuration  
Customize the script with the following options in the `CONFIG` table:  
```lua
local CONFIG = {
    CHEST_ENTRY  = 800001,
    MIN_GM_LEVEL = 3,
    LOOT_TABLE   = "custom_treasure_chest_loot",
    CONFIG_TABLE = "custom_treasure_chest_config",
    SPAWN_TABLE  = "custom_treasure_chest_spawn",
    -- ... colors
}
```

---

## 🎨 Message Colors  
The system uses different colors to improve visibility:  
- 🟡 **Yellow**: General announcements  
- 🔴 **Red**: Error messages  
- 🟢 **Green**: Success messages  
- ⚪ **White**: Standard information  

---

## 📋 Requirements  
- AzerothCore v4.0.0+  
- Eluna Lua Engine  

---

## ⚠️ Known Issues  
- None! Version 2.0 fixes all prior caching bugs natively via custom SQL tables.

---

## 🛠️ Troubleshooting  
### 💡 If items are missing in new chests:  
- Check if the item ID exists in the database.  
- Ensure your GM level is 3 or higher.  

### 💡 If the chest fails to spawn or is not interactable:  
- Confirm the gameobject entry exists in the database.  
- Make sure you actually restarted the worldserver after applying the SQL script (this caches the chest correctly).  

---

## 🛡️ Commands  
- **`#chest spawn`** - 🗺️ Spawns a treasure chest at your location.  
- **`#chest list`** - 📜 Lists the current chest contents.  
- **`#chest clear`** - 🧹 Clears all chest contents.  
- **`#chest cleanup`** - 🗑️ Deletes all spawned chests from the world and database.  
- **`#chest add <itemID> <count>`** - 🎁 Adds an item to the chest.  
- **`#chest gold <amount>`** - 💰 Sets gold amount.  
- **`#chest hint`** - ❓ Displays the current chest hint.  
- **`#chest addhint <text>`** - 🖋️ Sets a hint for the chest.  

---

## 📖 Usage Example  
```plaintext
1. #chest clear           // Wipe the previous chest's contents
2. #chest add 49426 1     // Add item to chest (no reload needed!)
3. #chest gold 5000       // Add gold reward
4. #chest spawn           // Spawn the chest with updated loot
```

---

## 🙌 Credits  
- **[Zyggy123](https://github.com/zyggy123)** - Original script development.  

---

## 📜 License  
This module is released under the **[GNU AGPL v3](LICENSE)**.  

---

## 🔗 Links  
- [AzerothCore](https://github.com/azerothcore/azerothcore-wotlk)  
- [Module Catalogue](https://github.com/azerothcore/modules-catalogue)  

---

## 🤝 Support  
For issues and feature requests, please use the **GitHub issue tracker**.  

---

## 🔧 Contributing  
1. Fork the repository.  
2. Create your feature branch.  
3. Commit your changes.  
4. Push to the branch.  
5. Create a Pull Request.  

---

## 📜 Version History  
- **1.0.0**  
  - Initial release with basic chest functionality.  
  - Command system.  
  - SQL installation script included.
 

    
<h1 align="center">Video is from v1</h1>

[![Video Demo](https://github.com/zyggy123/Treasure-Chest-System/blob/main/Youtube.png)](https://www.youtube.com/watch?v=7GWxilR0674)
