```markdown
# 🌟 Treasure Chest System

## 🗺️ Description
A dynamic treasure chest system for **AzerothCore** that allows Game Masters to create and manage treasure chests with custom loot and hints. Players can discover and loot these chests, with server-wide announcements for discoveries.  

---

## 📜 SQL Details
The SQL installation script:  
- 🛠️ **Creates** a custom gameobject (ID: `500001`).  
- 🎨 **Sets** the chest model (`DisplayID: 8686`).  
- ⚙️ **Configures** basic properties (type `3` for chest).  
- 🎁 **Adds** initial test loot:  
  - 🧵 *Linen Cloth*  
  - 🧀 *Darnassian Bleu*  
  - 🧵 *Silk Cloth*  
- 🔗 **Links** loot templates properly to the chest.

---

## ⚙️ Configuration
Customize the script with the following options in the `CONFIG` table:  
```lua
CONFIG = {
  CHEST_ENTRY = 500001,        -- Must match SQL entry ID
  DEBUG = false,               -- Enable/disable debug messages
  MIN_GM_LEVEL = 3,            -- Minimum GM level required to use commands
  ANNOUNCE_COLOR = "|cFFFFFF00", -- Color for announcements
  ERROR_COLOR = "|cFFFF0000",    -- Color for error messages
  SUCCESS_COLOR = "|cFF00FF00"   -- Color for success messages
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
- **Loot Changes**: Always use `.reload gameobject_loot_template` after adding items for changes to take effect.  
- **Persistence**: Chest contents remain in the database until manually cleared.  

---

## 🛠️ Troubleshooting
### 💡 If items are missing in new chests:
- Verify you used `.reload gameobject_loot_template`.  
- Check if the item ID exists in the database.  
- Ensure your GM level is 3 or higher.  

### 💡 If the chest fails to spawn:
- Check the console for error messages.  
- Confirm the gameobject entry exists in the database.  
- Make sure you're in a valid location.  

---

## 🛡️ Commands
- **`#chest spawn`** - 🗺️ Spawns a treasure chest at your location.  
- **`#chest list`** - 📜 Lists the current chest contents.  
- **`#chest clear`** - 🧹 Clears all chest contents.  
- **`#chest add <itemID> <count>`** - 🎁 Adds an item to the chest.  
  - **📝 Note**: Use `.reload gameobject_loot_template` after adding items!  
- **`#chest gold <amount>`** - 💰 Sets gold amount.  
- **`#chest reload`** - 🔄 Reloads chest loot templates.  
- **`#chest hint`** - ❓ Displays the current chest hint.  
- **`#chest addhint <text>`** - 🖋️ Sets a hint for the chest.  

---

## 📖 Usage Example
```plaintext
1. #chest add 49426 1     // Add item to chest
2. .reload gameobject_loot_template // Reload templates
3. #chest spawn           // Spawn the chest with updated loot
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
