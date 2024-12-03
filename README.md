```markdown
# Treasure Chest System

## Description
A dynamic treasure chest system for AzerothCore that allows Game Masters to create and manage treasure chests with custom loot and hints. Players can find and loot these chests, with server-wide announcements for discoveries.

## Features
- Spawn treasure chests at GM location.
- Add/remove items and gold to chests.
- Set and show hints for chest locations.
- Server-wide announcements for chest spawns and loots.
- Colored messages for better visibility.
- Full GM command system.
- Debug logging system.

## Installation
1. Copy `treasure_chest_system.lua` to your `lua_scripts` folder.
2. Execute the SQL files in your world database.
3. Restart your server.

## Important Notes
⚠️ **CRITICAL**: After adding items to the chest using `#chest add`, you **MUST** use the `.reload gameobject_loot_template` command for the changes to take effect in newly spawned chests. Without this reload, new chests will not contain the added items.

## Commands
- `#chest spawn` - Spawns a treasure chest at your location.
- `#chest list` - Lists current chest contents.
- `#chest clear` - Clears all chest contents.
- `#chest add <itemID> <count>` - Adds an item to the chest.
  - **Remember**: Use `.reload gameobject_loot_template` after adding items!
- `#chest gold <amount>` - Sets gold amount.
- `#chest reload` - Reloads chest loot templates.
- `#chest hint` - Shows current chest hint.
- `#chest addhint <text>` - Sets chest hint.

## Usage Example

1. #chest add 49426 1 // Add item to chest
2. .reload gameobject_loot_template // IMPORTANT: Reload templates
3. #chest spawn // Now spawn the chest with updated loot
```

## Configuration
The script includes several configurable options in the `CONFIG` table:
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

## Message Colors
The system uses different colors for various message types:
- **Yellow**: General announcements.
- **Red**: Error messages.
- **Green**: Success messages.
- **White**: Standard information.

## Requirements
- AzerothCore v4.0.0+
- Eluna Lua Engine

## Known Issues
- Always use `.reload gameobject_loot_template` after adding items.
- Chest contents persist in the database until manually cleared.

## Troubleshooting
1. **If items don't appear in new chests:**
   - Verify you used `.reload gameobject_loot_template`.
   - Check if the item ID exists in your database.
   - Ensure you have GM level 3 or higher.

2. **If chest doesn't spawn:**
   - Check console for error messages.
   - Verify the gameobject entry exists in your database.
   - Ensure you're in a valid location.

## Credits
* [Zyggy123](https://github.com/zyggy123) - Original script development.

## License
This module is released under the [GNU AGPL v3](LICENSE).

## Links
- [AzerothCore](https://github.com/azerothcore/azerothcore-wotlk)
- [Module Catalogue](https://github.com/azerothcore/modules-catalogue)

## Support
For issues and feature requests, please use the GitHub issue tracker.

## Contributing
1. Fork the repository.
2. Create your feature branch.
3. Commit your changes.
4. Push to the branch.
5. Create a new Pull Request.

## Version History
- **1.0.0**
  - Initial release.
  - Basic chest functionality.
  - Command system implementation.
