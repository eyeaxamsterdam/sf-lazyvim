return {
  -- LazyVim's own core init.lua has a hardcoded fallback: require("tokyonight").load().
  -- It runs independently of the plugin spec below, so even though we only ever
  -- wanted dark-2026, deleting tokyonight.nvim broke LazyVim's internal default.
  -- This tells LazyVim itself to use dark-2026 for that internal mechanism too.
  { "LazyVim/LazyVim", opts = { colorscheme = "dark-2026" } },

  {
    "boonyarit-iamsaard/dark-2026.nvim",
    lazy = false,
    priority = 1000, -- load before other plugins so UI elements render with the right colors from the start
    config = function()
      -- No italics anywhere, ever: wrap nvim_set_hl itself so italic is
      -- stripped the instant anything sets it, not just once at startup --
      -- catches LSP/treesitter/markdown groups defined later by lazy-loaded
      -- plugins too, not only what dark-2026 itself defines up front.
      local set_hl = vim.api.nvim_set_hl
      vim.api.nvim_set_hl = function(ns, name, val)
        if val.italic then
          val = vim.tbl_extend("force", val, { italic = false })
        end
        return set_hl(ns, name, val)
      end

      require("dark-2026").setup({})
      vim.cmd.colorscheme("dark-2026")

      -- Safety net for any highlight set via :highlight/:hi (old-style,
      -- bypasses the Lua API wrap above) before this point.
      for name, _ in pairs(vim.api.nvim_get_hl(0, {})) do
        local hl = vim.api.nvim_get_hl(0, { name = name })
        if hl.italic then
          hl.italic = nil
          vim.api.nvim_set_hl(0, name, hl)
        end
      end
    end,
  },
}
