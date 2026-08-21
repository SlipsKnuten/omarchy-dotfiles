-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = false
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true

local cargo_bin = vim.fn.expand("~/.cargo/bin")
if not (vim.env.PATH or ""):find(cargo_bin, 1, true) then
  vim.env.PATH = cargo_bin .. ":" .. (vim.env.PATH or "")
end

vim.opt.clipboard = "unnamedplus"
