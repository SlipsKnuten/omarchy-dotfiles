-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Exit insert mode with 'nn'
vim.keymap.set("i", "nn", "<Esc>", { noremap = true, silent = true, desc = "Exit insert mode" })

-- Open file explorer with 'mm'
vim.keymap.set("n", "mm", ":Ex<CR>", { noremap = true, silent = true, desc = "Open file explorer" })
