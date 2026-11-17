This is my personal nvim setup for Salesforce development. I use multiple machines and change my configs a lot so this is a way to at least keep them all in sync. 

# sf-lazyvim

A [LazyVim](https://github.com/LazyVim/LazyVim) config for Salesforce development:
Apex / LWC / Visualforce language servers, SOQL, deploy/retrieve, Apex tests with coverage,
and anonymous Apex, all without leaving Neovim.

## Requirements

- Neovim 0.11+
- git, a C compiler (for Treesitter parsers), `ripgrep`, `fd`, `fzf`
- A [Nerd Font](https://www.nerdfonts.com/) in your terminal
- For the Salesforce features:
  - [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli) (`sf`)
  - Node.js + npm (LWC language server, Prettier)
  - Java 11+ (Apex language server)
  - Optional: `ctags` (Universal Ctags) for `<leader>sfcc` / `<leader>sfcl`
- Optional: [Claude Code](https://claude.com/claude-code) CLI for the `claudecode` extra

## Install

```sh
# (Optional) back up any existing config first
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak

git clone https://github.com/eyeaxamsterdam/sf-lazyvim ~/.config/nvim
nvim
```

On first launch lazy.nvim installs every plugin at the versions pinned in `lazy-lock.json`,
and Mason installs the language servers. Run `:checkhealth` if anything looks off.

Apex formatting on save uses the **project's** Prettier, so in each Salesforce project run:

```sh
npm install --save-dev prettier prettier-plugin-apex
```

## What's customized

- **Theme:** [base16-3024](https://github.com/boonyarit-iamsaard/dark-2026.nvim), with italics stripped everywhere
- **Options:** system clipboard, 4-space indent, absolute line numbers, bufferline always shown
- **Salesforce file types:** `.cls`/`.trigger`/`.apex` → Apex, `.page`/`.component` → Visualforce,
  `.soql`/`.sosl`, plus icons for Salesforce files and `*-meta.xml`
- **Language servers:** `apex_ls`, `lwc_ls`, `visualforce_ls`
- **Formatting:** Prettier for Apex, JS, CSS, HTML, JSON; Apex also gets a blank line after the class declaration
- **Statusline:** shows the current Salesforce target org inside an SFDX project
- **Explorer:** long filenames pop out in a floating window instead of being cut off
- **Dashboard** reopens when you close the last file
- **Disabled:** tokyonight, catppuccin, trouble.nvim, todo-comments.nvim

## Salesforce keymaps

`<leader>` is space. These are only active inside an SFDX project (a folder with `sfdx-project.json`).
Press `<leader>sf` and wait to see them all in which-key.

| Keys | Action |
| --- | --- |
| `<leader>sfs` / `sfS` | Set target org (workspace / global) |
| `<leader>sfo` | Open target org in browser |
| `<leader>sfp` | Push current file |
| `<leader>sfr` | Retrieve current file |
| `<leader>sfm` | Retrieve everything in `manifest/package.xml` |
| `<leader>sfP` | Deploy preview (current file) |
| `<leader>sfv` | Retrieve preview (whole org) |
| `<leader>sfd` / `sfD` | Diff current file against target org / a chosen org |
| `<leader>sfa` | Run buffer (or visual selection) as anonymous Apex |
| `<leader>sfq` | Run buffer (or visual selection) as SOQL |
| `<leader>sftu` / `sfta` | Run test under cursor / all tests in file |
| `<leader>sfT` / `sftA` | Same, with coverage |
| `<leader>sfC` | Toggle coverage highlighting (`[v` / `]v` jump between uncovered lines) |
| `<leader>sfR` / `sfX` | Rename / delete Apex class (in org and locally) |
| `<leader>ft` | Terminal at project root |
| `<leader>uN` | Notification history |

Built on [sf.nvim](https://github.com/xixiaofinland/sf.nvim); full key list in `lua/plugins/sf.lua`.

## Keeping machines in sync

```sh
cd ~/.config/nvim
git pull                                        # get changes from other machines
git add -A && git commit -m "..." && git push   # share your changes
```

After `:Lazy update`, commit `lazy-lock.json` so every machine runs the same plugin versions.
