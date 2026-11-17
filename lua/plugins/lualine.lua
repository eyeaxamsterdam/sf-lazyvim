-- Show the current Salesforce target-org in the statusline.
-- Only appears inside a project with an sfdx-project.json. Prefers the
-- project-local target-org (.sf/config.json); falls back to the global
-- default (~/.sf/config.json) when the project never set its own.
local function read_target_org(config_path)
  local f = io.open(config_path, "r")
  if not f then return nil end
  local content = f:read("*a")
  f:close()
  return content:match('"target%-org"%s*:%s*"([^"]+)"')
end

local function sf_org()
  local root = vim.fs.root(vim.fn.expand("%:p"), "sfdx-project.json")
  if not root then return "" end
  local org = read_target_org(root .. "/.sf/config.json") or read_target_org(vim.fn.expand("~/.sf/config.json"))
  if not org then return "" end
  return "󰢎 " .. org
end

return {
  "nvim-lualine/lualine.nvim",
  opts = {
    sections = {
      lualine_x = { sf_org, "encoding", "fileformat", "filetype" },
    },
  },
}
