# LazyVim Belcaries Edition

An interactive tutorial plugin to master Neovim and LazyVim keybindings with comprehensive hands-on practice.

## Features

- **10 Lesson Reference** - Quick reference for all keybindings organized by topic
- **Comprehensive Practice Mode** - Learn by doing on REAL projects (Python/Go/JS)
- **11 Practice Modules** - Movement, editing, visual mode, search, text objects, file navigation, buffers, LSP, git, terminal, UI
- **60+ Guided Tasks** - Step-by-step instructions with auto-detection
- **Progress Tracking** - See your progress with completion percentage
- **Keybinding Quiz** - Test your knowledge with random questions
- **Quick Reference** - All keymaps in one scrollable view

## Installation

### Using lazy.nvim

```lua
{
  "mono1374/lazyvim-belcaries-edition",
  keys = {
    { "<leader>ht", function() require("lazyvim-belcaries").show_menu() end, desc = "Tutorial Menu" },
    { "<leader>hh", function() require("lazyvim-belcaries").quick_reference() end, desc = "Quick Reference" },
    { "<leader>hp", function() require("lazyvim-belcaries").practice_mode() end, desc = "Comprehensive Practice" },
    { "<leader>hq", function() require("lazyvim-belcaries").quiz_mode() end, desc = "Keybinding Quiz" },
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
| `<leader>hp` | Comprehensive Practice |
| `<leader>hq` | Keybinding Quiz |
| `<leader>hn` | Next Lesson |
| `<leader>hb` | Previous Lesson |

## Comprehensive Practice Mode

The main feature! Press `<leader>hp` to start:

1. **Choose a project** - Python Calculator, Go HTTP Server, or JavaScript Todo App
2. **Work on real code** - The project opens in nvim
3. **Follow guided tasks** - Floating instruction popup in corner
4. **Auto-detection** - Many tasks auto-complete when you perform the action
5. **Learn everything** - 11 modules cover the full LazyVim workflow

### Practice Modules (60+ tasks)

| Module | Topics |
|--------|--------|
| 1. Basic Movement | hjkl, w/b/e, 0/$, gg/G, Ctrl+d/u, f/t |
| 2. Editing | i/a/o, d/c/y, p/P, u/Ctrl+r, r/R |
| 3. Visual Mode | v, V, Ctrl+v, actions (d/y/c/>/=) |
| 4. Search | /, *, :s, :noh |
| 5. Text Objects | ciw, ci", ci(, da", af/if |
| 6. File Navigation | <leader>e, <leader>ff, <leader>fr, <leader>sg |
| 7. Buffers & Windows | Shift+h/l, <leader>bd, <leader>\|, Ctrl+hjkl |
| 8. LSP Features | K, gd, gr, <leader>ca, <leader>cr, ]d/[d |
| 9. Git Integration | <leader>gg, <leader>gb, ]h/[h, <leader>ghs |
| 10. Terminal | Ctrl+/, <leader>ft, run project |
| 11. UI & Extras | <leader>u toggles, which-key, <leader>sk |

### Practice Controls

| Key | Action |
|-----|--------|
| `s` | Skip current task |
| `Ctrl+n` | Next task |
| `Ctrl+p` | Previous task |
| `q` | Quit practice |

Projects are stored in `~/.local/share/nvim/lazyvim-belcaries-projects/`

## Lesson Reference

The tutorial menu (`<leader>ht`) provides quick reference for all keybindings:

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

### Inside Lesson Popups

| Key | Action |
|-----|--------|
| `n` | Next section |
| `p` | Previous section |
| `]` | Next lesson |
| `[` | Previous lesson |
| `1-9, 0` | Jump to lesson |
| `<Space>` | Start practice |
| `q` / `Esc` | Close popup |

## Commands

| Command | Description |
|---------|-------------|
| `:BelcariesTutorial` | Open tutorial menu |
| `:BelcariesQuickRef` | Show quick reference |
| `:BelcariesPractice` | Start comprehensive practice |
| `:BelcariesQuiz` | Start keybinding quiz |
| `:BelcariesStopPractice` | Stop current practice session |

## Progress

Your lesson progress is saved to `~/.local/share/nvim/lazyvim-belcaries-progress.json`

## License

MIT

## Author

Belcaries Edition - Built with Claude Code
