-- LazyVim Belcaries Edition
-- Interactive Tutorial Plugin for Neovim/LazyVim
-- Master keybindings with popup lessons and practice sessions

local M = {}

-- Load the new practice module
local practice = require("lazyvim-belcaries.practice")

-- State management
local state = {
  current_lesson = 1,
  current_section = 1,
  completed_lessons = {},
  practice_score = 0,
  popup_win = nil,
  popup_buf = nil,
}

-- Save/Load progress
local progress_file = vim.fn.stdpath("data") .. "/lazyvim-belcaries-progress.json"

local function save_progress()
  local data = vim.fn.json_encode(state.completed_lessons)
  local file = io.open(progress_file, "w")
  if file then
    file:write(data)
    file:close()
  end
end

local function load_progress()
  local file = io.open(progress_file, "r")
  if file then
    local data = file:read("*all")
    file:close()
    local ok, decoded = pcall(vim.fn.json_decode, data)
    if ok then
      state.completed_lessons = decoded or {}
    end
  end
end

-- ============================================================================
-- LESSON DATABASE
-- ============================================================================

local lessons = {
  -- LESSON 1: Fundamentals
  {
    title = "1. BASICS: Movement & Navigation",
    sections = {
      {
        name = "Basic Movement",
        keys = {
          { key = "h", desc = "Move left", practice = "Move cursor left 5 times" },
          { key = "j", desc = "Move down", practice = "Move cursor down 3 lines" },
          { key = "k", desc = "Move up", practice = "Move cursor up 3 lines" },
          { key = "l", desc = "Move right", practice = "Move cursor right 5 times" },
          { key = "w", desc = "Jump to next word start", practice = "Jump 3 words forward" },
          { key = "b", desc = "Jump to previous word start", practice = "Jump 2 words back" },
          { key = "e", desc = "Jump to word end", practice = "Jump to end of current word" },
          { key = "W/B/E", desc = "Same but for WORDS (spaces)", practice = "Try with punctuation" },
        },
      },
      {
        name = "Line Navigation",
        keys = {
          { key = "0", desc = "Go to line start (column 0)", practice = "Go to start of line" },
          { key = "$", desc = "Go to line end", practice = "Go to end of line" },
          { key = "^", desc = "Go to first non-blank char", practice = "Go to first character" },
          { key = "gg", desc = "Go to first line of file", practice = "Jump to file start" },
          { key = "G", desc = "Go to last line of file", practice = "Jump to file end" },
          { key = "{num}G", desc = "Go to line number", practice = "Go to line 10 with 10G" },
          { key = ":{num}", desc = "Go to line (command)", practice = "Type :15 to go to line 15" },
        },
      },
      {
        name = "Screen Movement",
        keys = {
          { key = "Ctrl+f", desc = "Page down (forward)", practice = "Scroll one page down" },
          { key = "Ctrl+b", desc = "Page up (backward)", practice = "Scroll one page up" },
          { key = "Ctrl+d", desc = "Half page down", practice = "Scroll half page down" },
          { key = "Ctrl+u", desc = "Half page up", practice = "Scroll half page up" },
          { key = "zz", desc = "Center cursor on screen", practice = "Center current line" },
          { key = "zt", desc = "Cursor line to top", practice = "Move line to top" },
          { key = "zb", desc = "Cursor line to bottom", practice = "Move line to bottom" },
          { key = "H/M/L", desc = "Cursor to High/Mid/Low screen", practice = "Try each one" },
        },
      },
      {
        name = "Jump Motions",
        keys = {
          { key = "%", desc = "Jump to matching bracket", practice = "Find matching ()[]{}" },
          { key = "*", desc = "Search word forward", practice = "Search current word" },
          { key = "#", desc = "Search word backward", practice = "Search word backward" },
          { key = "f{char}", desc = "Find char forward on line", practice = "Try fa to find 'a'" },
          { key = "F{char}", desc = "Find char backward on line", practice = "Try Fa backward" },
          { key = "t{char}", desc = "Till char (before it)", practice = "Try ta" },
          { key = ";", desc = "Repeat last f/t motion", practice = "Use after f{char}" },
          { key = ",", desc = "Repeat f/t in reverse", practice = "Go back with ," },
        },
      },
    },
  },

  -- LESSON 2: Editing
  {
    title = "2. EDITING: Insert, Delete, Change",
    sections = {
      {
        name = "Entering Insert Mode",
        keys = {
          { key = "i", desc = "Insert before cursor", practice = "Insert text before cursor" },
          { key = "I", desc = "Insert at line start", practice = "Insert at beginning of line" },
          { key = "a", desc = "Append after cursor", practice = "Append text after cursor" },
          { key = "A", desc = "Append at line end", practice = "Append at end of line" },
          { key = "o", desc = "Open line below", practice = "Create new line below" },
          { key = "O", desc = "Open line above", practice = "Create new line above" },
          { key = "gi", desc = "Insert at last insert pos", practice = "Return to last edit" },
          { key = "Esc / Ctrl+[", desc = "Exit insert mode", practice = "Return to normal mode" },
        },
      },
      {
        name = "Deleting Text",
        keys = {
          { key = "x", desc = "Delete char under cursor", practice = "Delete one character" },
          { key = "X", desc = "Delete char before cursor", practice = "Backspace delete" },
          { key = "dd", desc = "Delete entire line", practice = "Delete current line" },
          { key = "dw", desc = "Delete word", practice = "Delete next word" },
          { key = "de", desc = "Delete to word end", practice = "Delete to end of word" },
          { key = "d$", desc = "Delete to line end", practice = "Delete to end of line" },
          { key = "d0", desc = "Delete to line start", practice = "Delete to start of line" },
          { key = "D", desc = "Delete to line end (= d$)", practice = "Delete rest of line" },
          { key = "dG", desc = "Delete to file end", practice = "Delete to end of file" },
          { key = "dgg", desc = "Delete to file start", practice = "Delete to start of file" },
        },
      },
      {
        name = "Changing Text",
        keys = {
          { key = "r{char}", desc = "Replace single character", practice = "Replace one char" },
          { key = "R", desc = "Replace mode (overwrite)", practice = "Enter replace mode" },
          { key = "cw", desc = "Change word", practice = "Change next word" },
          { key = "ce", desc = "Change to word end", practice = "Change to end of word" },
          { key = "cc", desc = "Change entire line", practice = "Change whole line" },
          { key = "C", desc = "Change to line end", practice = "Change rest of line" },
          { key = "s", desc = "Substitute char (delete+insert)", practice = "Delete char and insert" },
          { key = "S", desc = "Substitute line (= cc)", practice = "Delete line and insert" },
          { key = "~", desc = "Toggle case of char", practice = "Swap upper/lowercase" },
        },
      },
      {
        name = "Copy & Paste (Yank & Put)",
        keys = {
          { key = "yy", desc = "Yank (copy) entire line", practice = "Copy current line" },
          { key = "yw", desc = "Yank word", practice = "Copy word" },
          { key = "y$", desc = "Yank to line end", practice = "Copy to end of line" },
          { key = "yG", desc = "Yank to file end", practice = "Copy to end of file" },
          { key = "p", desc = "Put (paste) after cursor", practice = "Paste below/after" },
          { key = "P", desc = "Put before cursor", practice = "Paste above/before" },
          { key = '"+y', desc = "Yank to system clipboard", practice = "Copy to clipboard" },
          { key = '"+p', desc = "Paste from system clipboard", practice = "Paste from clipboard" },
          { key = ":reg", desc = "Show registers (clipboards)", practice = "View all yanked text" },
        },
      },
      {
        name = "Undo & Redo",
        keys = {
          { key = "u", desc = "Undo last change", practice = "Undo something" },
          { key = "Ctrl+r", desc = "Redo (undo the undo)", practice = "Redo something" },
          { key = "U", desc = "Undo all changes on line", practice = "Restore line" },
          { key = ".", desc = "Repeat last command", practice = "Repeat last action" },
        },
      },
    },
  },

  -- LESSON 3: Visual Mode
  {
    title = "3. VISUAL MODE: Selection",
    sections = {
      {
        name = "Visual Mode Types",
        keys = {
          { key = "v", desc = "Character-wise visual", practice = "Select characters" },
          { key = "V", desc = "Line-wise visual", practice = "Select whole lines" },
          { key = "Ctrl+v", desc = "Block visual mode", practice = "Select column/block" },
          { key = "gv", desc = "Reselect last selection", practice = "Restore last selection" },
          { key = "o", desc = "Jump to other end of selection", practice = "Toggle selection end" },
          { key = "Esc", desc = "Exit visual mode", practice = "Cancel selection" },
        },
      },
      {
        name = "Visual Mode Actions",
        keys = {
          { key = "d", desc = "Delete selection", practice = "Delete selected text" },
          { key = "y", desc = "Yank (copy) selection", practice = "Copy selected text" },
          { key = "c", desc = "Change selection", practice = "Replace selected text" },
          { key = "p", desc = "Paste over selection", practice = "Replace with yanked" },
          { key = ">", desc = "Indent selection right", practice = "Indent selected lines" },
          { key = "<", desc = "Indent selection left", practice = "Unindent selected lines" },
          { key = "=", desc = "Auto-indent selection", practice = "Fix indentation" },
          { key = "~", desc = "Toggle case", practice = "Swap upper/lowercase" },
          { key = "u", desc = "Lowercase selection", practice = "Make lowercase" },
          { key = "U", desc = "Uppercase selection", practice = "Make uppercase" },
          { key = "J", desc = "Join selected lines", practice = "Merge lines" },
        },
      },
      {
        name = "Block Visual Special",
        keys = {
          { key = "Ctrl+v then I", desc = "Insert at block start", practice = "Add text to multiple lines" },
          { key = "Ctrl+v then A", desc = "Append at block end", practice = "Append to multiple lines" },
          { key = "Ctrl+v then c", desc = "Change block", practice = "Change column" },
          { key = "Ctrl+v then r", desc = "Replace block chars", practice = "Replace column chars" },
        },
      },
    },
  },

  -- LESSON 4: Search
  {
    title = "4. SEARCH: Find & Replace",
    sections = {
      {
        name = "Basic Search",
        keys = {
          { key = "/{pattern}", desc = "Search forward", practice = "Type /function and Enter" },
          { key = "?{pattern}", desc = "Search backward", practice = "Type ?return and Enter" },
          { key = "n", desc = "Next match", practice = "Go to next match" },
          { key = "N", desc = "Previous match", practice = "Go to previous match" },
          { key = "*", desc = "Search word under cursor (fwd)", practice = "Search current word" },
          { key = "#", desc = "Search word under cursor (bwd)", practice = "Search word backward" },
          { key = "g*", desc = "Partial word search forward", practice = "Partial match forward" },
          { key = "g#", desc = "Partial word search backward", practice = "Partial match backward" },
        },
      },
      {
        name = "Search Options",
        keys = {
          { key = "/\\c{pat}", desc = "Case insensitive search", practice = "Try /\\cHello" },
          { key = "/\\C{pat}", desc = "Case sensitive search", practice = "Try /\\CHello" },
          { key = "/\\<word\\>", desc = "Whole word only", practice = "Try /\\<the\\>" },
          { key = ":noh", desc = "Clear search highlight", practice = "Remove highlights" },
          { key = "<leader>ur", desc = "Clear highlight (LazyVim)", practice = "Space u r" },
        },
      },
      {
        name = "Search & Replace",
        keys = {
          { key = ":s/old/new/", desc = "Replace first on line", practice = "Replace once" },
          { key = ":s/old/new/g", desc = "Replace all on line", practice = "Replace all on line" },
          { key = ":%s/old/new/g", desc = "Replace in entire file", practice = "Replace in file" },
          { key = ":%s/old/new/gc", desc = "Replace with confirm", practice = "Confirm each replace" },
          { key = ":5,10s/old/new/g", desc = "Replace in line range", practice = "Replace lines 5-10" },
          { key = ":'<,'>s/old/new/g", desc = "Replace in selection", practice = "Visual select first" },
          { key = "<leader>sr", desc = "Search & Replace UI (grug-far)", practice = "Open replace UI" },
        },
      },
    },
  },

  -- LESSON 5: LazyVim Leader Commands
  {
    title = "5. LAZYVIM: Leader Key Commands",
    sections = {
      {
        name = "File Operations (<leader>f)",
        keys = {
          { key = "<leader>ff", desc = "Find files (root dir)", practice = "Open file finder" },
          { key = "<leader>fF", desc = "Find files (cwd)", practice = "Find in current dir" },
          { key = "<leader>fr", desc = "Recent files", practice = "Open recent files" },
          { key = "<leader>fn", desc = "New file", practice = "Create new file" },
          { key = "<leader>fb", desc = "Browse buffers", practice = "Show open buffers" },
          { key = "<leader>fg", desc = "Find in git files", practice = "Git-tracked files only" },
          { key = "<leader>e", desc = "File explorer (NeoTree)", practice = "Toggle file tree" },
          { key = "<leader>E", desc = "File explorer (cwd)", practice = "Explorer at cwd" },
          { key = "<leader>fe", desc = "Explorer NeoTree", practice = "Focus file tree" },
        },
      },
      {
        name = "Buffer Management (<leader>b)",
        keys = {
          { key = "<leader>bb", desc = "Switch to other buffer", practice = "Toggle buffer" },
          { key = "<leader>bd", desc = "Delete buffer", practice = "Close buffer" },
          { key = "<leader>bo", desc = "Delete other buffers", practice = "Keep only this" },
          { key = "<leader>bD", desc = "Delete buffer + window", practice = "Close buffer & window" },
          { key = "<S-h>", desc = "Previous buffer", practice = "Go to prev buffer" },
          { key = "<S-l>", desc = "Next buffer", practice = "Go to next buffer" },
          { key = "[b", desc = "Previous buffer (alt)", practice = "Prev buffer" },
          { key = "]b", desc = "Next buffer (alt)", practice = "Next buffer" },
          { key = "<leader>`", desc = "Switch to last buffer", practice = "Toggle last buffer" },
        },
      },
      {
        name = "Window Management (<leader>w & Ctrl)",
        keys = {
          { key = "<leader>-", desc = "Split horizontal (below)", practice = "Split below" },
          { key = "<leader>|", desc = "Split vertical (right)", practice = "Split right" },
          { key = "<leader>wd", desc = "Delete window", practice = "Close window" },
          { key = "<leader>wm", desc = "Toggle maximize", practice = "Maximize window" },
          { key = "<C-h>", desc = "Go to left window", practice = "Navigate left" },
          { key = "<C-j>", desc = "Go to lower window", practice = "Navigate down" },
          { key = "<C-k>", desc = "Go to upper window", practice = "Navigate up" },
          { key = "<C-l>", desc = "Go to right window", practice = "Navigate right" },
          { key = "<C-Up>", desc = "Increase window height", practice = "Grow window" },
          { key = "<C-Down>", desc = "Decrease window height", practice = "Shrink window" },
          { key = "<C-Left>", desc = "Decrease window width", practice = "Narrow window" },
          { key = "<C-Right>", desc = "Increase window width", practice = "Widen window" },
        },
      },
      {
        name = "Search & Telescope (<leader>s)",
        keys = {
          { key = "<leader>sg", desc = "Grep (live search in files)", practice = "Search in files" },
          { key = "<leader>sG", desc = "Grep (cwd)", practice = "Grep in current dir" },
          { key = "<leader>sw", desc = "Search word under cursor", practice = "Search this word" },
          { key = "<leader>sk", desc = "Search keymaps", practice = "Find keybindings" },
          { key = "<leader>sh", desc = "Search help tags", practice = "Search help docs" },
          { key = "<leader>sc", desc = "Search commands", practice = "Find commands" },
          { key = "<leader>ss", desc = "Goto symbol (buffer)", practice = "Find symbol" },
          { key = "<leader>sS", desc = "Goto symbol (workspace)", practice = "Workspace symbols" },
          { key = "<leader>sm", desc = "Search marks", practice = "Find marks" },
          { key = "<leader>sr", desc = "Search & replace (grug-far)", practice = "Open replace UI" },
          { key = "<leader>/", desc = "Search in buffer (fuzzy)", practice = "Fuzzy find in file" },
        },
      },
    },
  },

  -- LESSON 6: LSP & Code
  {
    title = "6. CODE: LSP & Intelligence",
    sections = {
      {
        name = "Go To Commands (g prefix)",
        keys = {
          { key = "gd", desc = "Go to definition", practice = "Jump to definition" },
          { key = "gD", desc = "Go to declaration", practice = "Jump to declaration" },
          { key = "gr", desc = "Find all references", practice = "Show all references" },
          { key = "gI", desc = "Go to implementation", practice = "Jump to implementation" },
          { key = "gy", desc = "Go to type definition", practice = "Show type definition" },
          { key = "K", desc = "Hover documentation", practice = "Show docs popup" },
          { key = "gK", desc = "Signature help", practice = "Show function signature" },
          { key = "<C-k>", desc = "Signature help (insert mode)", practice = "Show sig in insert" },
        },
      },
      {
        name = "Code Actions (<leader>c)",
        keys = {
          { key = "<leader>ca", desc = "Code action", practice = "Show code actions" },
          { key = "<leader>cA", desc = "Source action", practice = "Source-level action" },
          { key = "<leader>cr", desc = "Rename symbol", practice = "Rename variable/func" },
          { key = "<leader>cf", desc = "Format document", practice = "Format code" },
          { key = "<leader>cF", desc = "Format selection", practice = "Format selected" },
          { key = "<leader>cd", desc = "Line diagnostics", practice = "Show line errors" },
          { key = "<leader>cl", desc = "LSP info", practice = "Show LSP status" },
        },
      },
      {
        name = "Diagnostics Navigation",
        keys = {
          { key = "]d", desc = "Next diagnostic", practice = "Go to next error/warn" },
          { key = "[d", desc = "Previous diagnostic", practice = "Go to prev error/warn" },
          { key = "]e", desc = "Next error only", practice = "Go to next error" },
          { key = "[e", desc = "Previous error only", practice = "Go to prev error" },
          { key = "]w", desc = "Next warning only", practice = "Go to next warning" },
          { key = "[w", desc = "Previous warning only", practice = "Go to prev warning" },
          { key = "<leader>xx", desc = "Trouble: all diagnostics", practice = "Show all errors" },
          { key = "<leader>xX", desc = "Trouble: buffer diagnostics", practice = "Buffer errors" },
        },
      },
      {
        name = "Comments",
        keys = {
          { key = "gc", desc = "Comment (operator)", practice = "gc + motion to comment" },
          { key = "gcc", desc = "Comment current line", practice = "Toggle line comment" },
          { key = "gco", desc = "Add comment below", practice = "Comment on new line below" },
          { key = "gcO", desc = "Add comment above", practice = "Comment on new line above" },
          { key = "gcA", desc = "Add comment at end", practice = "Comment at line end" },
        },
      },
    },
  },

  -- LESSON 7: Git
  {
    title = "7. GIT: Version Control",
    sections = {
      {
        name = "Git Commands (<leader>g)",
        keys = {
          { key = "<leader>gg", desc = "Open Lazygit (root)", practice = "Open git UI" },
          { key = "<leader>gG", desc = "Open Lazygit (cwd)", practice = "Git UI at cwd" },
          { key = "<leader>gb", desc = "Git blame line", practice = "Show who wrote line" },
          { key = "<leader>gB", desc = "Browse in browser", practice = "Open in GitHub/GitLab" },
          { key = "<leader>gY", desc = "Copy git URL", practice = "Copy permalink" },
          { key = "<leader>gf", desc = "File history", practice = "Show file commits" },
          { key = "<leader>gl", desc = "Git log (root)", practice = "Show git log" },
          { key = "<leader>gL", desc = "Git log (cwd)", practice = "Log for current dir" },
        },
      },
      {
        name = "Hunk Navigation & Actions",
        keys = {
          { key = "]h", desc = "Next git hunk", practice = "Go to next change" },
          { key = "[h", desc = "Previous git hunk", practice = "Go to prev change" },
          { key = "<leader>ghs", desc = "Stage hunk", practice = "Stage this change" },
          { key = "<leader>ghr", desc = "Reset hunk", practice = "Discard this change" },
          { key = "<leader>ghu", desc = "Undo stage hunk", practice = "Unstage change" },
          { key = "<leader>ghp", desc = "Preview hunk", practice = "Preview the diff" },
          { key = "<leader>ghb", desc = "Blame line (popup)", practice = "Show blame popup" },
          { key = "<leader>ghd", desc = "Diff this", practice = "Diff against index" },
        },
      },
      {
        name = "Lazygit Inside (when open)",
        keys = {
          { key = "space", desc = "Stage/unstage file", practice = "Toggle staging" },
          { key = "c", desc = "Commit", practice = "Open commit msg" },
          { key = "P", desc = "Push", practice = "Push to remote" },
          { key = "p", desc = "Pull", practice = "Pull from remote" },
          { key = "s", desc = "Stash", practice = "Stash changes" },
          { key = "b", desc = "Branch menu", practice = "Manage branches" },
          { key = "q", desc = "Quit lazygit", practice = "Close lazygit" },
        },
      },
    },
  },

  -- LESSON 8: UI Toggles
  {
    title = "8. UI: Toggles & Display",
    sections = {
      {
        name = "Toggle Options (<leader>u)",
        keys = {
          { key = "<leader>uf", desc = "Toggle format on save", practice = "Toggle auto-format" },
          { key = "<leader>uF", desc = "Toggle format (global)", practice = "Toggle format globally" },
          { key = "<leader>us", desc = "Toggle spell check", practice = "Toggle spelling" },
          { key = "<leader>uw", desc = "Toggle word wrap", practice = "Toggle line wrap" },
          { key = "<leader>ul", desc = "Toggle line numbers", practice = "Toggle numbers" },
          { key = "<leader>uL", desc = "Toggle relative numbers", practice = "Toggle relative" },
          { key = "<leader>ud", desc = "Toggle diagnostics", practice = "Show/hide errors" },
          { key = "<leader>uc", desc = "Toggle conceal", practice = "Toggle conceal chars" },
          { key = "<leader>uh", desc = "Toggle inlay hints", practice = "Toggle type hints" },
          { key = "<leader>uT", desc = "Toggle treesitter highlight", practice = "Toggle syntax" },
          { key = "<leader>ub", desc = "Toggle dark/light", practice = "Toggle background" },
          { key = "<leader>ug", desc = "Toggle indent guides", practice = "Toggle indent lines" },
          { key = "<leader>uS", desc = "Toggle smooth scroll", practice = "Toggle scrolling" },
        },
      },
      {
        name = "UI Panels & Lists",
        keys = {
          { key = "<leader>l", desc = "Open Lazy (plugin manager)", practice = "Show plugins" },
          { key = "<leader>L", desc = "LazyVim changelog", practice = "Show changelog" },
          { key = "<leader>xl", desc = "Toggle location list", practice = "Toggle loc list" },
          { key = "<leader>xq", desc = "Toggle quickfix list", practice = "Toggle quickfix" },
          { key = "[q", desc = "Previous quickfix item", practice = "Prev quickfix" },
          { key = "]q", desc = "Next quickfix item", practice = "Next quickfix" },
          { key = "<leader>xx", desc = "Trouble: diagnostics", practice = "Show diagnostics" },
          { key = "<leader>xs", desc = "Trouble: symbols", practice = "Show symbols" },
        },
      },
      {
        name = "Notifications & Messages",
        keys = {
          { key = "<leader>sn", desc = "Notifications", practice = "Show notifications" },
          { key = "<leader>un", desc = "Dismiss notifications", practice = "Clear notifications" },
        },
      },
    },
  },

  -- LESSON 9: Terminal & Tabs
  {
    title = "9. TERMINAL & TABS",
    sections = {
      {
        name = "Terminal",
        keys = {
          { key = "<leader>ft", desc = "Terminal (root dir)", practice = "Open terminal" },
          { key = "<leader>fT", desc = "Terminal (cwd)", practice = "Terminal at cwd" },
          { key = "<C-/>", desc = "Toggle terminal", practice = "Toggle terminal" },
          { key = "<C-_>", desc = "Toggle terminal (alt)", practice = "Same as Ctrl+/" },
          { key = "<Esc><Esc>", desc = "Exit terminal mode", practice = "Go to normal mode" },
          { key = "<C-\\><C-n>", desc = "Exit terminal (alt)", practice = "Alternative exit" },
        },
      },
      {
        name = "Tabs (<leader><Tab>)",
        keys = {
          { key = "<leader><Tab><Tab>", desc = "New tab", practice = "Create new tab" },
          { key = "<leader><Tab>d", desc = "Close tab", practice = "Close current tab" },
          { key = "<leader><Tab>]", desc = "Next tab", practice = "Go to next tab" },
          { key = "<leader><Tab>[", desc = "Previous tab", practice = "Go to prev tab" },
          { key = "<leader><Tab>l", desc = "Last tab", practice = "Go to last tab" },
          { key = "<leader><Tab>f", desc = "First tab", practice = "Go to first tab" },
          { key = "<leader><Tab>o", desc = "Close other tabs", practice = "Keep only this tab" },
          { key = "gt", desc = "Go to next tab (vim)", practice = "Next tab" },
          { key = "gT", desc = "Go to prev tab (vim)", practice = "Prev tab" },
        },
      },
      {
        name = "Session Management",
        keys = {
          { key = "<leader>qq", desc = "Quit all", practice = "Close nvim" },
          { key = "<leader>qs", desc = "Save session", practice = "Save workspace" },
          { key = "<leader>qS", desc = "Select session", practice = "Pick session" },
          { key = "<leader>ql", desc = "Load last session", practice = "Restore last" },
          { key = "<leader>qd", desc = "Don't save session", practice = "Quit no save" },
        },
      },
    },
  },

  -- LESSON 10: Text Objects
  {
    title = "10. TEXT OBJECTS: Power Editing",
    sections = {
      {
        name = "Inner Objects (i = inside)",
        keys = {
          { key = "ciw", desc = "Change inner word", practice = "Change whole word" },
          { key = "diw", desc = "Delete inner word", practice = "Delete whole word" },
          { key = 'ci"', desc = "Change inside double quotes", practice = "Change quoted text" },
          { key = "ci'", desc = "Change inside single quotes", practice = "Change 'text'" },
          { key = "ci`", desc = "Change inside backticks", practice = "Change `text`" },
          { key = "ci(", desc = "Change inside parentheses", practice = "Change (text)" },
          { key = "ci[", desc = "Change inside brackets", practice = "Change [text]" },
          { key = "ci{", desc = "Change inside braces", practice = "Change {text}" },
          { key = "cit", desc = "Change inside HTML tag", practice = "Change <tag>text</tag>" },
          { key = "dip", desc = "Delete inner paragraph", practice = "Delete paragraph" },
          { key = "yis", desc = "Yank inner sentence", practice = "Copy sentence" },
        },
      },
      {
        name = "Around Objects (a = around/including)",
        keys = {
          { key = "daw", desc = "Delete around word (+space)", practice = "Delete word + space" },
          { key = 'da"', desc = "Delete around quotes", practice = "Delete with quotes" },
          { key = "da'", desc = "Delete around single quotes", practice = "Delete 'with' quotes" },
          { key = "da(", desc = "Delete around parens", practice = "Delete (with) parens" },
          { key = "da[", desc = "Delete around brackets", practice = "Delete [with] brackets" },
          { key = "da{", desc = "Delete around braces", practice = "Delete {with} braces" },
          { key = "dat", desc = "Delete around tag", practice = "Delete <tag>...</tag>" },
          { key = "yap", desc = "Yank around paragraph", practice = "Copy paragraph + blank" },
          { key = "das", desc = "Delete around sentence", practice = "Delete sentence + space" },
        },
      },
      {
        name = "Treesitter Text Objects",
        keys = {
          { key = "af", desc = "Around function", practice = "Select whole function" },
          { key = "if", desc = "Inner function", practice = "Select function body" },
          { key = "ac", desc = "Around class", practice = "Select whole class" },
          { key = "ic", desc = "Inner class", practice = "Select class body" },
          { key = "aa", desc = "Around argument/parameter", practice = "Select with comma" },
          { key = "ia", desc = "Inner argument/parameter", practice = "Select argument" },
          { key = "]f", desc = "Next function start", practice = "Go to next function" },
          { key = "[f", desc = "Previous function start", practice = "Go to prev function" },
          { key = "]c", desc = "Next class start", practice = "Go to next class" },
          { key = "[c", desc = "Previous class start", practice = "Go to prev class" },
        },
      },
      {
        name = "Mini.surround (if enabled)",
        keys = {
          { key = "sa{motion}{char}", desc = "Add surrounding", practice = "saiw' adds 'word'" },
          { key = "sd{char}", desc = "Delete surrounding", practice = 'sd" removes quotes' },
          { key = "sr{old}{new}", desc = "Replace surrounding", practice = "sr'\" changes ' to \"" },
          { key = "sf{char}", desc = "Find surrounding forward", practice = "Find next {char}" },
          { key = "sF{char}", desc = "Find surrounding backward", practice = "Find prev {char}" },
          { key = "sh", desc = "Highlight surrounding", practice = "Show surrounding" },
        },
      },
    },
  },
}

-- ============================================================================
-- POPUP HELPERS
-- ============================================================================

local function create_popup(content, title, opts)
  opts = opts or {}
  local width = opts.width or 80
  local height = opts.height or 30

  -- Calculate position
  local ui = vim.api.nvim_list_uis()[1]
  local col = math.floor((ui.width - width) / 2)
  local row = math.floor((ui.height - height) / 2)

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

  -- Create window
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
    title = title and (" " .. title .. " ") or nil,
    title_pos = "center",
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)

  -- Set content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

  -- Keymaps for popup
  local close_popup = function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  vim.keymap.set("n", "q", close_popup, { buffer = buf, silent = true })
  vim.keymap.set("n", "<Esc>", close_popup, { buffer = buf, silent = true })

  state.popup_win = win
  state.popup_buf = buf

  return buf, win
end

local function format_lesson(lesson, section_idx)
  local lines = {}
  table.insert(lines, "")
  table.insert(lines, "  " .. lesson.title)
  table.insert(lines, "  " .. string.rep("=", #lesson.title))
  table.insert(lines, "")

  local section = lesson.sections[section_idx]
  if section then
    table.insert(lines, "  Section: " .. section.name)
    table.insert(lines, "  " .. string.rep("-", 50))
    table.insert(lines, "")
    table.insert(lines, string.format("  %-22s %-30s %s", "KEY", "DESCRIPTION", "PRACTICE"))
    table.insert(lines, "  " .. string.rep("-", 75))

    for _, key in ipairs(section.keys) do
      local keystr = string.format("%-22s", key.key)
      local descstr = string.format("%-30s", key.desc)
      table.insert(lines, "  " .. keystr .. descstr .. key.practice)
    end

    table.insert(lines, "")
    table.insert(lines, "  " .. string.rep("-", 75))
    table.insert(lines, string.format("  Section %d of %d | Lesson %d of %d",
      section_idx, #lesson.sections, state.current_lesson, #lessons))
  end

  table.insert(lines, "")
  table.insert(lines, "  Navigation:")
  table.insert(lines, "    n / ]     Next section / Next lesson")
  table.insert(lines, "    p / [     Previous section / Previous lesson")
  table.insert(lines, "    1-9, 0    Jump to lesson")
  table.insert(lines, "    <Space>   Practice this section")
  table.insert(lines, "    q / Esc   Close popup")
  table.insert(lines, "")

  return lines
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

-- Show lesson popup
function M.show_lesson(lesson_idx, section_idx)
  lesson_idx = lesson_idx or state.current_lesson
  section_idx = section_idx or 1

  if lesson_idx < 1 then lesson_idx = 1 end
  if lesson_idx > #lessons then lesson_idx = #lessons end

  local lesson = lessons[lesson_idx]
  if section_idx < 1 then section_idx = 1 end
  if section_idx > #lesson.sections then section_idx = #lesson.sections end

  state.current_lesson = lesson_idx
  state.current_section = section_idx

  local content = format_lesson(lesson, section_idx)
  local buf, win = create_popup(content, "Belcaries Tutorial - Lesson " .. lesson_idx, { height = 38, width = 85 })

  -- Navigation keymaps
  vim.keymap.set("n", "n", function()
    if state.current_section < #lessons[state.current_lesson].sections then
      vim.api.nvim_win_close(win, true)
      M.show_lesson(state.current_lesson, state.current_section + 1)
    else
      vim.api.nvim_win_close(win, true)
      M.show_lesson(state.current_lesson + 1, 1)
    end
  end, { buffer = buf, silent = true })

  vim.keymap.set("n", "]", function()
    vim.api.nvim_win_close(win, true)
    M.show_lesson(state.current_lesson + 1, 1)
  end, { buffer = buf, silent = true })

  vim.keymap.set("n", "p", function()
    if state.current_section > 1 then
      vim.api.nvim_win_close(win, true)
      M.show_lesson(state.current_lesson, state.current_section - 1)
    else
      local prev_lesson = state.current_lesson - 1
      if prev_lesson >= 1 then
        vim.api.nvim_win_close(win, true)
        M.show_lesson(prev_lesson, #lessons[prev_lesson].sections)
      end
    end
  end, { buffer = buf, silent = true })

  vim.keymap.set("n", "[", function()
    vim.api.nvim_win_close(win, true)
    M.show_lesson(state.current_lesson - 1, 1)
  end, { buffer = buf, silent = true })

  -- Number keys to jump to lessons
  for i = 1, 9 do
    vim.keymap.set("n", tostring(i), function()
      if i <= #lessons then
        vim.api.nvim_win_close(win, true)
        M.show_lesson(i, 1)
      end
    end, { buffer = buf, silent = true })
  end

  vim.keymap.set("n", "0", function()
    if 10 <= #lessons then
      vim.api.nvim_win_close(win, true)
      M.show_lesson(10, 1)
    end
  end, { buffer = buf, silent = true })

  -- Practice mode
  vim.keymap.set("n", "<Space>", function()
    vim.api.nvim_win_close(win, true)
    M.practice_section(state.current_lesson, state.current_section)
  end, { buffer = buf, silent = true })
end

-- Main menu
function M.show_menu()
  load_progress()

  local lines = {
    "",
    "  LAZYVIM BELCARIES EDITION",
    "  ==========================",
    "",
    "  Interactive Neovim & LazyVim Tutorial",
    "  Master keybindings with popup lessons and practice!",
    "",
    "  LESSONS:",
    "",
  }

  for i, lesson in ipairs(lessons) do
    local status = state.completed_lessons[tostring(i)] and "[x]" or "[ ]"
    local title_clean = lesson.title:match("^%d+%. (.+)") or lesson.title
    table.insert(lines, string.format("    %s %2d. %s", status, i, title_clean))
  end

  table.insert(lines, "")
  table.insert(lines, "  KEYBINDINGS:")
  table.insert(lines, "    <leader>ht  This menu")
  table.insert(lines, "    <leader>hh  Quick reference (all keymaps)")
  table.insert(lines, "    <leader>hp  COMPREHENSIVE PRACTICE")
  table.insert(lines, "    <leader>hq  Keybinding quiz")
  table.insert(lines, "    <leader>hn  Next lesson")
  table.insert(lines, "    <leader>hb  Previous lesson")
  table.insert(lines, "")
  table.insert(lines, "  COMPREHENSIVE PRACTICE (<leader>hp):")
  table.insert(lines, "  Work on a real Python/Go/JS project while learning")
  table.insert(lines, "  ALL keybindings: movement, editing, visual mode,")
  table.insert(lines, "  search, LSP, git, terminal - 11 modules, 60+ tasks!")
  table.insert(lines, "")
  table.insert(lines, "  TIP: Press <leader>sk to search all keymaps!")
  table.insert(lines, "")
  table.insert(lines, "  Press 1-9 or 0 to jump to a lesson")
  table.insert(lines, "  Press Enter to start current lesson")
  table.insert(lines, "  Press q or Esc to close")
  table.insert(lines, "")

  local buf, win = create_popup(lines, "Belcaries Tutorial", { height = 38, width = 60 })

  -- Number keys for quick jump
  for i = 1, 9 do
    vim.keymap.set("n", tostring(i), function()
      if i <= #lessons then
        vim.api.nvim_win_close(win, true)
        M.show_lesson(i, 1)
      end
    end, { buffer = buf, silent = true })
  end

  vim.keymap.set("n", "0", function()
    if 10 <= #lessons then
      vim.api.nvim_win_close(win, true)
      M.show_lesson(10, 1)
    end
  end, { buffer = buf, silent = true })

  vim.keymap.set("n", "<CR>", function()
    vim.api.nvim_win_close(win, true)
    M.show_lesson(state.current_lesson, 1)
  end, { buffer = buf, silent = true })
end

-- Quick reference - all keymaps at once
function M.quick_reference()
  local lines = {
    "",
    "  LAZYVIM BELCARIES - QUICK REFERENCE",
    "  =====================================",
    "",
  }

  for _, lesson in ipairs(lessons) do
    table.insert(lines, "  " .. lesson.title)
    table.insert(lines, "  " .. string.rep("-", 60))

    for _, section in ipairs(lesson.sections) do
      table.insert(lines, "")
      table.insert(lines, "  " .. section.name .. ":")
      for _, key in ipairs(section.keys) do
        table.insert(lines, string.format("    %-20s %s", key.key, key.desc))
      end
    end
    table.insert(lines, "")
  end

  table.insert(lines, "")
  table.insert(lines, "  TIP: Press <leader>sk to search all keymaps interactively!")
  table.insert(lines, "  TIP: Press <Space> and wait to see which-key suggestions!")
  table.insert(lines, "")

  create_popup(lines, "Quick Reference", { width = 75, height = 45 })
end

-- Practice mode for a section - now launches comprehensive practice
function M.practice_section(lesson_idx, section_idx)
  -- Launch the comprehensive interactive practice
  practice.select_project()
end

-- Navigate to next lesson
function M.next_lesson()
  M.show_lesson(state.current_lesson + 1, 1)
end

-- Navigate to previous lesson
function M.prev_lesson()
  M.show_lesson(state.current_lesson - 1, 1)
end

-- Interactive practice mode - launches real project practice
function M.practice_mode()
  practice.select_project()
end

-- Quiz mode with randomized keys (for review)
function M.quiz_mode()
  -- Collect all keys
  local all_keys = {}
  for _, lesson in ipairs(lessons) do
    for _, section in ipairs(lesson.sections) do
      for _, key in ipairs(section.keys) do
        table.insert(all_keys, {
          key = key.key,
          desc = key.desc,
          lesson = lesson.title,
          section = section.name,
        })
      end
    end
  end

  -- Shuffle and pick random keys
  local function shuffle(t)
    for i = #t, 2, -1 do
      local j = math.random(i)
      t[i], t[j] = t[j], t[i]
    end
  end

  math.randomseed(os.time())
  shuffle(all_keys)

  local quiz_keys = {}
  for i = 1, math.min(12, #all_keys) do
    table.insert(quiz_keys, all_keys[i])
  end

  local lines = {
    "",
    "  KEYBINDING QUIZ",
    "  ================",
    "",
    "  What key combination does this action?",
    "  Try to answer before looking!",
    "",
    "  " .. string.rep("-", 55),
    "",
  }

  for i, key in ipairs(quiz_keys) do
    table.insert(lines, string.format("  %2d. %-42s", i, key.desc))
    table.insert(lines, string.format("      Answer: %-20s [%s]", key.key, key.section))
    table.insert(lines, "")
  end

  table.insert(lines, "  " .. string.rep("-", 55))
  table.insert(lines, "")
  table.insert(lines, "  Press 'r' to refresh with new questions")
  table.insert(lines, "  Press q to close, <leader>ht for tutorial menu")
  table.insert(lines, "")

  local buf, win = create_popup(lines, "Keybinding Quiz", { height = 42, width = 65 })

  vim.keymap.set("n", "r", function()
    vim.api.nvim_win_close(win, true)
    M.quiz_mode()
  end, { buffer = buf, silent = true })
end

-- Setup function for plugin initialization
function M.setup(opts)
  opts = opts or {}
  load_progress()

  -- Optional: Show welcome message
  if opts.show_welcome then
    vim.defer_fn(function()
      vim.notify("LazyVim Belcaries Edition loaded! Press <leader>ht to start", vim.log.levels.INFO)
    end, 100)
  end
end

-- Initialize on load
load_progress()

return M
