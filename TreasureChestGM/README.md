# Treasure Chest GM Control (companion addon)

A lightweight client-side WotLK 3.3.5a addon that gives you a minimap icon
and a small quick-command panel for **zyggy123/Treasure-Chest-System**
(https://github.com/zyggy123/Treasure-Chest-System), instead of typing
`#chest ...` by hand every time.

## Installation

1. Copy the whole `TreasureChestGM` folder into your WoW client's
   `Interface/AddOns/` directory.
   - Path example: `World of Warcraft/Interface/AddOns/TreasureChestGM/`
2. Make sure the folder contains `TreasureChestGM.toc` and
   `TreasureChestGM.lua` directly (not nested one level deeper).
3. Restart the client, or reload the UI (`/reload`), and enable the addon
   at the character-select AddOns screen if it isn't already checked.

No server-side changes are needed — this only talks to the existing
`treasure_chest_system.lua` Eluna script through normal chat, exactly like
typing the command yourself.

## Usage

- Click the treasure-chest icon on the minimap (or type `/tcs` /
  `/tcsgm`) to open the panel.
- **Icon row**: Spawn chest, List loot, Cleanup (with confirmation), Hint.
- **Add Item**: enter an item ID and count, click **Add**.
- **Set Gold**: enter an amount, click **Set Gold**.
- **Set Hint**: type the hint text, click **Save Hint**.
- **Clear All Loot & Gold**: asks for confirmation before wiping the table.
- Drag the panel by its title bar; drag the minimap icon to reposition it.

## Important: how commands are actually sent

The server script only listens on Eluna's `PLAYER_EVENT_ON_CHAT` (event 18),
which fires for normal **public Say/Yell chat** — not party, guild, or
whisper. So this addon sends every command with `SendChatMessage(cmd, "SAY")`.
That means:

- Anyone standing near you will see the raw `#chest ...` text in chat, the
  same as if you'd typed it yourself. This addon doesn't change that
  behavior — it's inherent to how the server module is written.
- If you'd rather it use `/yell` instead of `/say`, change the
  `CHAT_CHANNEL` constant near the top of `TreasureChestGM.lua`.
- If you want it fully invisible to nearby players, the server script would
  need an added `RegisterPlayerEvent(19, ...)` (whisper) hook that also
  accepts `#chest` commands — happy to help with that if you want it.

## Files

- `TreasureChestGM.toc` — addon manifest (Interface: 30300)
- `TreasureChestGM.lua` — all UI + logic, single file
- `TreasureChestGM_DB` — SavedVariable, stores only the minimap icon's angle
