return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",

    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "bash",
          "markdown",
          "markdown_inline",
          "python",
          "typescript",
          "tsx",
          "javascript",
          "json",
          "yaml",
          "toml",
          "c",
        },

        highlight = {
          enable = true,
        },

        indent = {
          enable = true,
        },
      })
    end,
  },
}
