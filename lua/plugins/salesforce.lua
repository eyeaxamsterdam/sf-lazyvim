-- Neovim doesn't know Salesforce file types (it treats .cls as Smalltalk, .page as Mallard)
vim.filetype.add({
  extension = {
    cls = "apex",
    trigger = "apex",
    apex = "apex",
    page = "visualforce",
    component = "visualforce",
    soql = "soql",
    sosl = "sosl",
    -- any *-meta.xml file (there are 200+ Salesforce metadata suffixes: .cls-meta.xml,
    -- .object-meta.xml, .flow-meta.xml, .permissionset-meta.xml, ...) gets its own
    -- filetype here so it can get its own icon below, without enumerating every
    -- suffix individually. A plain `pattern = {...}` entry does NOT win here --
    -- confirmed empirically that the plain built-in "xml" extension match takes
    -- priority over a pattern-table rule -- so override the "xml" extension itself
    -- with a function, which Neovim's vim.filetype.add explicitly supports.
    xml = function(path)
      if path:match("%-meta%.xml$") then
        return "sf_meta_xml"
      end
      return "xml"
    end,
  },
})

-- Give Apex's class-sharing modifiers (with/without/inherited sharing) their own
-- highlight capture, separate from the rest of @keyword, so only they can be
-- recolored (see colorscheme.lua's @keyword.sharing override; VS Code's 3024 theme
-- renders these white, unlike other keywords).
-- A plain after/queries/apex/highlights.scm override does NOT merge in here --
-- confirmed with a Lua-language control test that this nvim-treesitter version
-- bypasses the standard runtimepath query-combination for added query files --
-- so extend the query directly via vim.treesitter.query.set() instead, run on
-- FileType so nvim-treesitter's own query is already in place by the time we run.
local apex_highlights_extended = false
vim.api.nvim_create_autocmd("FileType", {
  pattern = "apex",
  callback = function()
    if apex_highlights_extended then
      return
    end
    local base_path = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/runtime/queries/apex/highlights.scm"
    local ok, lines = pcall(vim.fn.readfile, base_path)
    if not ok then
      return
    end
    local extra = "\n[\n  (with_sharing)\n  (without_sharing)\n  (inherited_sharing)\n] @keyword.sharing\n"
    local set_ok = pcall(vim.treesitter.query.set, "apex", "highlights", table.concat(lines, "\n") .. extra)
    if set_ok then
      apex_highlights_extended = true
    end
  end,
})

return {
  -- mini.icons has no built-in entries for Salesforce extensions, so everything falls
  -- back to a generic file icon in the explorer/picker. cls/trigger get the actual
  -- Salesforce "cloud" icon; any *-meta.xml file gets the wireless/broadcast icon --
  -- matching the real Salesforce VS Code extension's icon theme. page/component/soql/sosl
  -- reuse the exact glyphs mini.icons already uses for html/sql, just with distinct colors.
  {
    "nvim-mini/mini.icons",
    opts = {
      extension = {
        css = { glyph = "", hl = "MiniIconsGrey" }, -- plain CSS ("#" Seti-style icon)
        auradoc = { glyph = "󰅴", hl = "MiniIconsPurple" }, -- Aura doc (code-tags icon)
        cmp = { glyph = "󰅴", hl = "MiniIconsPurple" }, -- Aura component markup (code-tags icon)
        design = { glyph = "󰏘", hl = "MiniIconsPurple" }, -- Aura design file (App Builder config)
        svg = { glyph = "󰜡", hl = "MiniIconsGreen" }, -- same glyph as mini.icons default, just green
        cls = { glyph = "", hl = "MiniIconsBlue" }, -- Apex class
        trigger = { glyph = "", hl = "MiniIconsOrange" }, -- Apex trigger
        page = { glyph = "󰌝", hl = "MiniIconsPurple" }, -- Visualforce page
        component = { glyph = "󰅴", hl = "MiniIconsOrange" }, -- Visualforce component (code-tags "<>" icon)
        soql = { glyph = "󰆼", hl = "MiniIconsGreen" }, -- SOQL query
        sosl = { glyph = "󰆼", hl = "MiniIconsCyan" }, -- SOSL query
      },
      filetype = {
        javascript = { glyph = "", hl = "MiniIconsYellow" }, -- plain JS ("JS" Seti-style badge)
        sf_meta_xml = { glyph = "", hl = "MiniIconsRed" }, -- any Salesforce *-meta.xml file
      },
    },
  },

  -- syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "apex", "soql", "sosl", "sflog" } }, -- sflog: debug-log viewing (sf.nvim)
  },

  -- apex_ls isn't auto-installed by mason-lspconfig (apex_jar_path below points
  -- straight into Mason's folder instead), so tell Mason to install it directly.
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "apex-language-server" } },
  },

  -- language servers (installed automatically through Mason)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- apex_jar_path is NOT auto-detected (despite what the old setup notes assumed) --
        -- without it, nvim-lspconfig builds `java -cp <nil> ...`, which fails instantly
        -- with "-cp requires class path specification" every single launch.
        apex_ls = {
          apex_jar_path = vim.fn.stdpath("data") .. "/mason/share/apex-language-server/apex-jorje-lsp.jar",
        },
        lwc_ls = {},
        visualforce_ls = {},
      },
    },
  },

  -- format Apex on save with the project's prettier + prettier-plugin-apex
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        apex = { "prettier", "apex_blank_line_after_decl" },
        -- plain Prettier handles these natively, no plugin needed (unlike apex)
        css = { "prettier" },
        html = { "prettier" },
        javascript = { "prettier" },
        json = { "prettier" },
      },
      formatters = {
        -- prettier-plugin-apex has no option for this, so add it ourselves:
        -- a blank line between the class/interface/trigger declaration's
        -- opening brace and the first member, if one isn't already there.
        apex_blank_line_after_decl = {
          format = function(_, _, lines, callback)
            for i, line in ipairs(lines) do
              local trimmed = line:gsub("%s+$", "")
              local is_top_level_decl = not line:match("^%s")
                and trimmed:match("{$")
                and (trimmed:match("class%s") or trimmed:match("interface%s") or trimmed:match("^trigger%s"))
              if is_top_level_decl then
                local next_line = lines[i + 1]
                if next_line and next_line:match("%S") and not next_line:match("^%s*}%s*$") then
                  local out = {}
                  for j = 1, i do
                    table.insert(out, lines[j])
                  end
                  table.insert(out, "")
                  for j = i + 1, #lines do
                    table.insert(out, lines[j])
                  end
                  return callback(nil, out)
                end
                break
              end
            end
            callback(nil, lines)
          end,
        },
      },
    },
  },
}
