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
vim.opt.clipboard      = "unnamedplus"
if vim.fn.executable("wl-copy") == 1 then
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

vim.opt.undofile       = true

vim.g.mapleader      = " "
vim.g.maplocalleader = " "

vim.filetype.add({
  extension = {
    mdx = "markdown.mdx",
  },
})

