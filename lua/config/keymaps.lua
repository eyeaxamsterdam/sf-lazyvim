-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Terminal at project root (falls back to cwd if no sfdx-project.json)
vim.keymap.set("n", "<leader>ft", function()
  local file = vim.fn.expand("%:p")
  local root = vim.fs.root(file, "sfdx-project.json") or vim.fn.getcwd()
  Snacks.terminal(nil, { cwd = root, win = { position = "bottom" } })
end, { desc = "Terminal (project root)" })

-- Salesforce: deploy / retrieve the current file in a split terminal
local function sf_terminal(cmd)
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file open", vim.log.levels.WARN)
    return
  end
  local root = vim.fs.root(file, "sfdx-project.json")
  if not root then
    vim.notify("No sfdx-project.json found", vim.log.levels.WARN)
    return
  end
  Snacks.terminal("cd " .. vim.fn.shellescape(root) .. " && sf " .. cmd .. " --source-dir " .. vim.fn.shellescape(file), {
    win = { position = "bottom" },
    auto_close = false,
  })
end

-- sfd (deploy current file) and sfr (retrieve current file) removed: sf.nvim's
-- <leader>sfp/<leader>sfr cover these (see Note below on the --ignore-conflicts difference).
-- Renamed sfD->sfP and sfR->sfv: sf.nvim's own scheme now uses sfD (diff against a
-- chosen org) and sfR (rename Apex class), so ours moved to avoid colliding with those.
vim.keymap.set("n", "<leader>sfP", function() sf_terminal("project deploy preview") end, { desc = "SF Deploy preview (current file)" })
vim.keymap.set("n", "<leader>sfv", function()
  local file = vim.fn.expand("%:p")
  local root = vim.fs.root(file, "sfdx-project.json")
  if not root then
    vim.notify("No sfdx-project.json found", vim.log.levels.WARN)
    return
  end
  Snacks.terminal("cd " .. vim.fn.shellescape(root) .. " && sf project retrieve preview", {
    win = { position = "bottom" },
    auto_close = false,
  })
end, { desc = "SF Retrieve preview (whole org)" })

-- Salesforce: retrieve everything listed in manifest/package.xml
vim.keymap.set("n", "<leader>sfm", function()
  local file = vim.fn.expand("%:p")
  local root = vim.fs.root(file, "sfdx-project.json") or vim.fn.getcwd()
  Snacks.terminal("cd " .. vim.fn.shellescape(root) .. " && sf project retrieve start --manifest manifest/package.xml", {
    win = { position = "bottom" },
    auto_close = false,
  })
end, { desc = "SF Retrieve from manifest" })

-- sfo (switch org) removed: sf.nvim's <leader>ss does the same thing (same org-list
-- source, same picker, same underlying `sf config set target-org` command).

-- Show notification history (like VS Code's Output panel): every vim.notify
-- call this session, newest first, kept until you quit Neovim. Press again to close.
vim.keymap.set("n", "<leader>uN", function()
  Snacks.notifier.show_history()
end, { desc = "Notification History" })

-- sfc (compare current file to org) removed: sf.nvim's <leader>sd does the same
-- thing (retrieve a copy, vert diffsplit).
