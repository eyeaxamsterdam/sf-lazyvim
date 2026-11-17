-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Carried over from the old config (LazyVim already defaults number, mouse, expandtab, smartindent)
vim.opt.clipboard = "unnamedplus" -- always use the system clipboard, even over SSH
vim.opt.shiftwidth = 4 -- LazyVim defaults to 2
vim.opt.relativenumber = false -- LazyVim defaults to true; show real line numbers everywhere, not distance-from-cursor
