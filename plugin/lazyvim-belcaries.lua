-- LazyVim Belcaries Edition - Plugin loader
-- This file is loaded automatically by Neovim

if vim.g.loaded_lazyvim_belcaries then
  return
end
vim.g.loaded_lazyvim_belcaries = true

-- Create user commands
vim.api.nvim_create_user_command("BelcariesTutorial", function()
  require("lazyvim-belcaries").show_menu()
end, { desc = "Open LazyVim Belcaries Tutorial" })

vim.api.nvim_create_user_command("BelcariesQuickRef", function()
  require("lazyvim-belcaries").quick_reference()
end, { desc = "Show quick reference" })

vim.api.nvim_create_user_command("BelcariesPractice", function()
  require("lazyvim-belcaries").practice_mode()
end, { desc = "Start practice quiz" })
