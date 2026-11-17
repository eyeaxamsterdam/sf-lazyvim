return {
  -- LazyVim's core has a fallback colorscheme; point it at ours.
  { "LazyVim/LazyVim", opts = { colorscheme = "base16-3024" } },

  {
    "RRethy/base16-nvim",
    lazy = false,
    priority = 1000, -- load before other plugins so UI renders with the right colors
    config = function()
      -- No italics anywhere, ever: wrap nvim_set_hl so italic is stripped the
      -- instant anything sets it (including lazy-loaded plugins later).
      local set_hl = vim.api.nvim_set_hl
      vim.api.nvim_set_hl = function(ns, name, val)
        if val.italic then
          val = vim.tbl_extend("force", val, { italic = false })
        end
        return set_hl(ns, name, val)
      end

      vim.cmd.colorscheme("base16-3024")

      -- Safety net for highlights set via :highlight before this point.
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
