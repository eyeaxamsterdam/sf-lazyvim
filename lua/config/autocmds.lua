-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Reopen the LazyVim dashboard (instead of a blank scratch buffer) when the last real file closes
vim.api.nvim_create_autocmd("BufDelete", {
  group = vim.api.nvim_create_augroup("dashboard_on_last_close", { clear = true }),
  callback = function()
    vim.schedule(function()
      local real_buffers = vim.tbl_filter(function(buf)
        return vim.bo[buf].buflisted and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= ""
      end, vim.api.nvim_list_bufs())
      if #real_buffers == 0 then
        Snacks.dashboard.open({ buf = vim.api.nvim_get_current_buf(), win = vim.api.nvim_get_current_win() })
        -- if the explorer sidebar is open, send focus there instead of leaving it on the dashboard
        local explorer = Snacks.picker.get({ source = "explorer" })[1]
        if explorer and explorer.list.win:valid() then
          vim.api.nvim_set_current_win(explorer.list.win.win)
        end
      end
    end)
  end,
})

-- Explorer: when the entry under the cursor is too long to fit the sidebar's
-- width (deep nesting eats into the space left for the filename), show the
-- full line in a floating window that overlaps the editor area to its right,
-- instead of permanently widening the sidebar.
--
-- Reads the picker's own selection state (explorer.list.cursor) rather than
-- the list window's actual cursor position: while the explorer's search
-- prompt has focus, <C-j>/<C-k> move the selection in the (non-current) list
-- window via the API, which never fires CursorMoved for that window -- so
-- triggering on "any cursor movement, anywhere" and re-deriving the real
-- selected row each time is what keeps this working during a live search.
local explorer_overflow_win ---@type integer?
local explorer_overflow_row ---@type integer?

local function close_explorer_overflow()
  if explorer_overflow_win and vim.api.nvim_win_is_valid(explorer_overflow_win) then
    vim.api.nvim_win_close(explorer_overflow_win, true)
  end
  explorer_overflow_win = nil
  explorer_overflow_row = nil
end

local function update_explorer_overflow()
  local explorer = Snacks.picker.get({ source = "explorer" })[1]
  if not explorer or not explorer.list.win:valid() then
    return close_explorer_overflow()
  end

  local row = explorer.list:idx2row(explorer.list.cursor) - 1 -- 0-indexed
  if row == explorer_overflow_row then
    return
  end
  close_explorer_overflow()
  explorer_overflow_row = row

  local win = explorer.list.win.win
  local win_width = vim.api.nvim_win_get_width(win)
  local line = vim.api.nvim_buf_get_lines(explorer.list.win.buf, row, row + 1, false)[1] or ""
  local text_width = vim.fn.strdisplaywidth(line)
  if text_width <= win_width then
    return
  end

  -- Don't ask for more columns than actually exist to the right of the sidebar
  local win_screen_col = vim.api.nvim_win_get_position(win)[2]
  local max_width = vim.o.columns - win_screen_col - 1

  explorer_overflow_win = vim.api.nvim_open_win(explorer.list.win.buf, false, {
    relative = "win",
    win = win,
    bufpos = { row, 0 },
    row = 0,
    col = 0,
    width = math.min(text_width, max_width),
    height = 1,
    style = "minimal",
    focusable = false,
    zindex = 200,
  })
  vim.wo[explorer_overflow_win].wrap = false
  vim.wo[explorer_overflow_win].cursorline = true
  vim.api.nvim_win_set_cursor(explorer_overflow_win, { row + 1, 0 })
end

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "WinLeave", "BufLeave" }, {
  group = vim.api.nvim_create_augroup("explorer_overflow", { clear = true }),
  callback = function(ev)
    if ev.event == "WinLeave" or ev.event == "BufLeave" then
      return close_explorer_overflow()
    end
    pcall(update_explorer_overflow)
  end,
})
