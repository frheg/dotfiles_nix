vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.expandtab      = true
vim.opt.tabstop        = 2
vim.opt.shiftwidth     = 2
vim.opt.scrolloff      = 8
vim.opt.signcolumn     = "yes"
vim.opt.wrap           = false
vim.opt.ignorecase     = true
vim.opt.smartcase      = true
vim.opt.splitright     = true
vim.opt.splitbelow     = true
vim.opt.termguicolors  = true
vim.opt.undofile       = true
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- Lualine already shows mode, so do not duplicate "-- INSERT --" below it.
vim.opt.showmode = false

-- Hide command line when not actively used.
vim.opt.cmdheight = 0

vim.filetype.add({
  extension = {
    mdx = "markdown.mdx",
  },
})

-- Clipboard:
-- - local graphical sessions use system clipboard providers
-- - SSH/tmux sessions use OSC52, which copies through the terminal
vim.opt.clipboard = "unnamedplus"

if vim.env.SSH_TTY ~= nil then
  vim.g.clipboard = {
    name = "OSC52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = function()
        return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
      end,
      ["*"] = function()
        return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
      end,
    },
  }
elseif vim.fn.executable("wl-copy") == 1 then
  vim.g.clipboard = {
    name = "wl-clipboard",
    copy = {
      ["+"] = "wl-copy",
      ["*"] = "wl-copy",
    },
    paste = {
      ["+"] = "wl-paste --no-newline",
      ["*"] = "wl-paste --no-newline",
    },
    cache_enabled = 0,
  }
end
