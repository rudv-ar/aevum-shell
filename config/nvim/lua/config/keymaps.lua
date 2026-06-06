-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Ctrl+S save (in any mode)
map({ "n", "i", "v", "x" }, "<C-s>", "<Cmd>w<CR>", { desc = "Save" })

-- Ctrl+X exit (in any mode)
map({ "n", "i", "v", "x" }, "<C-x>", "<Cmd>q<CR>", { desc = "Quit" })

-- Ctrl+Shift+S save and exit in any mode
map({ "n", "i", "v", "x" }, "<C-S-s>", "<Cmd>wq<CR>", { desc = "Save and Quit" })

-- Ctrl+Shift+X exit without saving in any mode
map({ "n", "i", "v", "x" }, "<C-S-x>", "<Cmd>q!<CR>", { desc = "Force Quit" })
