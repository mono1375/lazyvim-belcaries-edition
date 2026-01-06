# Changelog

## [1.0.0] - 2026-01-06

### Initial Release

Created LazyVim Belcaries Edition - An interactive tutorial plugin for mastering Neovim and LazyVim keybindings.

#### Features
- **10 Progressive Lessons** covering all essential nvim/LazyVim concepts
- **Interactive Popups** with keybinding tables and descriptions
- **Practice Mode** with guided exercises for each section
- **Random Quiz** to test knowledge with shuffled questions
- **Quick Reference** showing all keymaps in one scrollable view
- **Progress Tracking** saved to `~/.local/share/nvim/lazyvim-belcaries-progress.json`

#### Lessons Included
1. BASICS: Movement & Navigation (hjkl, w/b/e, gg/G, scrolling, jumps)
2. EDITING: Insert, Delete, Change, Copy/Paste, Undo/Redo
3. VISUAL MODE: Character, Line, Block selection and actions
4. SEARCH: Find & Replace patterns
5. LAZYVIM LEADER: Files, Buffers, Windows, Search/Telescope
6. CODE/LSP: Go to definition, references, code actions, comments
7. GIT: Lazygit, blame, hunks, git navigation
8. UI TOGGLES: Format, spell, diagnostics, theme options
9. TERMINAL & TABS: Terminal commands, tab management, sessions
10. TEXT OBJECTS: Inner/Around motions, Treesitter objects, Surround

#### Keybindings
- `<leader>ht` - Tutorial Menu
- `<leader>hh` - Quick Reference
- `<leader>hp` - Practice Mode
- `<leader>hn` - Next Lesson
- `<leader>hb` - Previous Lesson

#### Commands
- `:BelcariesTutorial`
- `:BelcariesQuickRef`
- `:BelcariesPractice`

### Sources Used
- [LazyVim Official Keymaps](https://www.lazyvim.org/keymaps)
- [LazyVim keymaps.lua](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua)
- [Cheatography LazyVim Cheatsheet](https://cheatography.com/thesujit/cheat-sheets/lazyvim-neovim/)
- [DeepWiki LazyVim Documentation](https://deepwiki.com/LazyVim/LazyVim/5-keymaps-and-navigation)
