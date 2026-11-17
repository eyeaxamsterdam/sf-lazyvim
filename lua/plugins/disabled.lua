-- LazyVim core bundles these by default. Disabled here to strip down the setup --
-- revert any single line to bring one back.
return {
  -- Unused alternate colorschemes (we use dark-2026 exclusively, see colorscheme.lua)
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", enabled = false },

  -- UI elements not wanted: pretty diagnostics/quickfix list, TODO-comment
  -- highlighting.
  -- (which-key.nvim, bufferline.nvim, and noice.nvim/nui.nvim all restored --
  -- turned out to be wanted; noice.nvim was the floating ':' cmdline popup)
  { "folke/trouble.nvim", enabled = false },
  { "folke/todo-comments.nvim", enabled = false },
}
