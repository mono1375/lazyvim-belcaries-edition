# LazyVim Belcaries Edition

An interactive tutorial plugin to master Neovim and LazyVim keybindings with popup-based lessons and practice sessions.

## Features

- **10 Progressive Lessons** - From basics to advanced text objects
- **Interactive Popups** - Clean, readable keybinding tables
- **Practice Mode** - Guided exercises for each section
- **Progress Tracking** - Marks completed lessons
- **Random Quiz** - Test your knowledge with random questions
- **Quick Reference** - All keymaps in one scrollable view

## Installation

### Using lazy.nvim

```lua
{
  "mono1374/lazyvim-belcaries-edition",
  keys = {
    { "<leader>ht", function() require("lazyvim-belcaries").show_menu() end, desc = "Tutorial Menu" },
    { "<leader>hh", function() require("lazyvim-belcaries").quick_reference() end, desc = "Quick Reference" },
    { "<leader>hp", function() require("lazyvim-belcaries").practice_mode() end, desc = "Practice Mode" },
    { "<leader>hn", function() require("lazyvim-belcaries").next_lesson() end, desc = "Next Lesson" },
    { "<leader>hb", function() require("lazyvim-belcaries").prev_lesson() end, desc = "Previous Lesson" },
  },
}
```

### Local Installation

Clone to your nvim config:

```bash
git clone https://github.com/mono1374/lazyvim-belcaries-edition ~/.local/share/nvim/lazy/lazyvim-belcaries-edition
```

Then add to your lazy.nvim config:

```lua
{
  dir = "~/.local/share/nvim/lazy/lazyvim-belcaries-edition",
  -- ... keys as above
}
```

## Usage

| Keybinding | Action |
|------------|--------|
| `<leader>ht` | Open Tutorial Menu |
| `<leader>hh` | Quick Reference (all keymaps) |
| `<leader>hp` | Practice Mode (random quiz) |
| `<leader>hn` | Next Lesson |
| `<leader>hb` | Previous Lesson |

### Inside Tutorial Popups

| Key | Action |
|-----|--------|
| `n` | Next section |
| `p` | Previous section |
| `]` | Next lesson |
| `[` | Previous lesson |
| `1-9, 0` | Jump to lesson |
| `<Space>` | Practice current section |
| `m` | Mark section complete |
| `q` / `Esc` | Close popup |

## Lessons

1. **BASICS** - Movement & Navigation (hjkl, w/b/e, gg/G, scrolling)
2. **EDITING** - Insert, Delete, Change, Copy/Paste
3. **VISUAL MODE** - Character, Line, Block selection
4. **SEARCH** - Find & Replace patterns
5. **LAZYVIM LEADER** - File, Buffer, Window, Search commands
6. **CODE/LSP** - Go to definition, references, code actions
7. **GIT** - Lazygit, blame, hunks navigation
8. **UI TOGGLES** - Format, spell, diagnostics, theme
9. **TERMINAL & TABS** - Terminal commands, tab management
10. **TEXT OBJECTS** - Power editing with inner/around motions

## Progress

Your progress is saved to `~/.local/share/nvim/lazyvim-belcaries-progress.json`

## License

MIT

## Author

Belcaries Edition - Built with Claude Code
