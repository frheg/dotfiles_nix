return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash",
          "c",
          "lua",
          "vim",
          "vimdoc",
          "python",
          "javascript",
          "typescript",
          "tsx",
          "json",
          "yaml",
          "toml",
          "markdown",
          "markdown_inline",
          "nix",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
}
