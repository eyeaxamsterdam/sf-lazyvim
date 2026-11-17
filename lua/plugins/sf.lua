-- Salesforce workflow commands: Apex tests (+ coverage signs), anonymous Apex,
-- SOQL execution, diff-against-org, push/retrieve, org switching, debug logs.
-- Built on the sf CLI; doesn't bundle its own Apex LSP (still uses apex_ls, see
-- salesforce.lua), but can regenerate sObject stubs so apex_ls autocompletes fields.
return {
  { "stevearc/overseer.nvim", opts = {} }, -- task-list UI for sf.nvim's commands, instead of a plain terminal
  {
    "xixiaofinland/sf.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/overseer.nvim",
    },
    config = function()
      require("sf").setup({
        -- enable_hotkeys left off (its own default): we bind every sf.nvim command
        -- ourselves below, all under <leader>sf, instead of its scattered defaults.
        terminal = "overseer", -- show runs in overseer's task list instead of a plain terminal split
      })

      -- Reimplements sf.nvim's own hotkey-setup trigger (see its
      -- sf/sub/config_auto_cmd.lua) with our own <leader>sf* key choices instead
      -- of its defaults. Runs on the same events it uses, with the same
      -- "only inside an sf project" / "only in metadata filetypes" gating.
      local function set_sf_keys()
        if not pcall(require("sf.util").get_sf_root) then
          return
        end
        local Sf = require("sf")
        local function nmap(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = true, desc = desc and (desc .. " [Sf]") })
        end

        -- Common: available in every file, anywhere in the sf project
        nmap("<leader>sfs", Sf.set_target_org, "Set target org (workspace)")
        nmap("<leader>sfS", Sf.set_global_target_org, "Set target org (global)")
        nmap("<leader>sfl", Sf.fetch_org_list, "Fetch org list")
        nmap("<leader>sfo", Sf.org_open, "Open target org")
        nmap("<leader>sf-", Sf.go_to_sf_root, "cd into sf project root")
        nmap("<leader>sfcc", Sf.create_ctags, "Create ctags")
        nmap("<leader>sfcl", Sf.create_and_list_ctags, "Fuzzy-list ctags")
        nmap("<leader>sfML", Sf.list_md_to_retrieve, "List metadata to retrieve")
        nmap("<leader>sfMT", Sf.list_md_type_to_retrieve, "List metadata types to retrieve")
        nmap("<leader>sfa", function() Sf.run_anonymous_stdin(false) end, "Run buffer anonymously")
        nmap("<leader>sfA", Sf.run_anonymous, "Run file anonymously")
        vim.keymap.set("v", "<leader>sfa", function() Sf.run_anonymous_stdin(true) end,
          { buffer = true, desc = "Run selection anonymously [Sf]" })
        -- Left outside the <leader>sf scheme on purpose (double-tap / ctrl-combo don't
        -- fit it), but still need to be (re)bound ourselves now that enable_hotkeys is
        -- off -- this was the ONLY thing that ever set these globally (not just inside
        -- the SFTerm buffer itself), so without it <leader><leader> fell through to
        -- LazyVim's own "Find Files" (identical key sequence, since <leader> is space).
        nmap("<leader><leader>", Sf.toggle_term, "Terminal toggle")
        nmap("<C-c>", Sf.cancel, "Cancel running command")

        -- Metadata files only
        if vim.tbl_contains(vim.g.sf.hotkeys_in_filetypes, vim.bo.filetype) then
          nmap("<leader>sfO", Sf.org_open_current_file, "Open current file in target org")
          nmap("<leader>sfd", Sf.diff_in_target_org, "Diff against target org")
          nmap("<leader>sfD", Sf.diff_in_org, "Diff against a chosen org")
          nmap("<leader>sfu", Sf.retrieve_apex_under_cursor, "Retrieve Apex under cursor")
          nmap("<leader>sfp", Sf.save_and_push, "Push current file")
          nmap("<leader>sfr", Sf.retrieve, "Retrieve current file")
          nmap("<leader>sfR", Sf.rename_apex_class_remote_and_local, "Rename Apex class (remote + local)")
          nmap("<leader>sfX", Sf.delete_current_apex_remote_and_local, "Delete Apex class (remote + local)")
          vim.keymap.set("x", "<leader>sfq", Sf.run_highlighted_soql, { buffer = true, desc = "Run selection as SOQL [Sf]" })
          nmap("<leader>sfq", Sf.run_query, "Run buffer as SOQL")
          nmap("<leader>sfQ", Sf.run_tooling_query, "Run buffer as Tooling API query")

          nmap("<leader>sftu", Sf.run_current_test, "Test under cursor")
          nmap("<leader>sfT", Sf.run_current_test_with_coverage, "Test under cursor + coverage")
          nmap("<leader>sfta", Sf.run_all_tests_in_this_file, "All tests in file")
          nmap("<leader>sftA", Sf.run_all_tests_in_this_file_with_coverage, "All tests in file + coverage")
          nmap("<leader>sfto", Sf.open_test_select, "Pick tests to run")
          nmap("<leader>sftr", Sf.repeat_last_tests, "Repeat last test run")
          nmap("<leader>sfC", Sf.toggle_sign, "Toggle coverage highlighting")
          nmap("[v", Sf.uncovered_jump_backward, "Prev uncovered line")
          nmap("]v", Sf.uncovered_jump_forward, "Next uncovered line")
          nmap("<leader>cc", Sf.copy_apex_name, "Copy Apex name")
        end
      end

      vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType", "DirChanged" }, {
        group = vim.api.nvim_create_augroup("sf_custom_keys", { clear = true }),
        callback = set_sf_keys,
      })
      set_sf_keys() -- setup() runs late (lazy loading); the current buffer's events already fired
    end,
  },
}
