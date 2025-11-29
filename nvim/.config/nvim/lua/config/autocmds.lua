-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Hide diagnostic underlines by clearing the highlight groups
vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", {})
vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", {})
vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", {})
vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", {})

-- Also hide signs and virtual text
vim.api.nvim_set_hl(0, "DiagnosticSignError", {})
vim.api.nvim_set_hl(0, "DiagnosticSignWarn", {})
vim.api.nvim_set_hl(0, "DiagnosticSignInfo", {})
vim.api.nvim_set_hl(0, "DiagnosticSignHint", {})
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", {})
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", {})
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", {})
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", {})
