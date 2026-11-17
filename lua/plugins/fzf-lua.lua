-- Just the fzf-lua library, for sf.nvim's own metadata/ctags listing pickers
-- (:SF md list, :SF mdtype list). Deliberately NOT enabling LazyVim's fzf.lua
-- extra -- that replaces Snacks as the primary picker everywhere (file find,
-- grep, gd/gr/gI/gy, many <leader>f*/<leader>s* keys), which is a much bigger
-- change than sf.nvim actually needs.
return {
  { "ibhagwan/fzf-lua", opts = {} },
}
