```markdown
# Treasure Chest System

## Description
The Treasure Chest System is a dynamic module for AzerothCore, enabling Game Masters to create and manage treasure chests with custom loot, hints, and server-wide announcements. This system enhances gameplay by allowing players to discover and loot these chests, adding an extra layer of excitement to the world.

## Features
- **Spawn treasure chests** at GM-specified locations.
- **Add/remove items and gold** to/from chests.
- **Set and display hints** for chest locations.
- **Server-wide announcements** for chest spawns and loot discoveries.
- **Colored messages** for enhanced visibility.
- Full **GM command system**.
- Integrated **debug logging** for troubleshooting.

## Installation

### Prerequisites
- A running AzerothCore server with Eluna Lua Engine enabled.
- Access to the `acore_world` database to execute SQL scripts.

### Steps
1. **Place the Lua Script**  
   Copy `treasure_chest_system.lua` to your server's `lua_scripts` folder.

2. **Execute the SQL Script**  
   Open your SQL client (e.g., HeidiSQL, MySQL Workbench) and run the provided `treasure_chest_system.sql` in your `acore_world` database. This script will:  
   - Remove conflicting entries (if any).  
   - Create a custom gameobject (Treasure Chest) with loot and properties.  
   - Add initial test loot for functionality verification.

3. **Restart the Server**  
   Restart your server to load the Lua script and database entries.

4. **Verify Installation**  
   - Use SQL verification queries in the script to confirm entries exist in the database.  
   - Test in-game using GM commands like `#chest spawn`.

### Critical Notes
- *⚠️*Always Reload Loot Templates*⚠️*: After using `#chest add`, execute `.reload gameobject_loot_template` for changes to take effect.  
- Use `#chest help` in-game to see all available GM commands.

## Commands
- `#chest spawn` - Spawns a treasure chest at your location.
- `#chest list` - Lists current chest contents.
- `#chest clear` - Clears all chest contents.
- `#chest add <itemID> <count>` - Adds an item to the chest.  
  - **Note**: Use `.reload gameobject_loot_template` after adding items!
- `#chest gold <amount>` - Sets gold amount.
- `#chest reload` - Reloads chest loot templates.
- `#chest hint` - Displays the current chest hint.
- `#chest addhint <text>` - Sets a hint for the chest.

## Usage Example

1. #chest add 49426 1 // Add item to chest
2. .reload gameobject_loot_template // Reload templates
3. #chest spawn // Spawn the chest with updated loot
```

## Configuration
Modify settings in the `CONFIG` table of the Lua script:
```lua
CONFIG = {
  CHEST_ENTRY = 501000,        -- Gameobject entry ID for the chest
  DEBUG = false,               -- Enable/disable debug messages
  MIN_GM_LEVEL = 3,            -- Minimum GM level required to use commands
  ANNOUNCE_COLOR = "|cFFFFFF00", -- Color for announcements
  ERROR_COLOR = "|cFFFF0000",    -- Color for error messages
  SUCCESS_COLOR = "|cFF00FF00"   -- Color for success messages
}
```

## Requirements
- AzerothCore v4.0.0+
- Eluna Lua Engine

## Known Issues
- Loot changes require `.reload gameobject_loot_template` to take effect.
- Chest contents persist in the database until manually cleared.

## Troubleshooting
1. *⚠️*If items don't appear in new chests:*⚠️*
   - Verify you used `.reload gameobject_loot_template`. 
   - Check if the item ID exists in your database.
   - Ensure you have GM level 3 or higher.

2. **If chest doesn't spawn:**
   - Check the server console for errors.
   - Verify the gameobject entry exists in the database.
   - Ensure you're spawning it in a valid location.

## Credits
- [Zyggy123](https://github.com/zyggy123) - Script development.

## License
This project is licensed under the [GNU AGPL v3](LICENSE).

## Links
- [AzerothCore](https://github.com/azerothcore/azerothcore-wotlk)
- [Module Catalogue](https://github.com/azerothcore/modules-catalogue)

## Support
For bugs, feature requests, or questions, use the GitHub issue tracker.

## Contributing
1. Fork the repository.
2. Create a new branch for your feature.
3. Commit your changes.
4. Push to your branch.
5. Create a Pull Request.

## Version History
- **1.0.0**  
  - Initial release with core treasure chest functionality.
