return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",

    opts = {
      ensure_installed = {
        "bash",
        "c",
        "cpp",
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
        "html",
        "css",
        "dockerfile",
        "sql",
        "rust",
        "java",
        "kotlin",
        "zig",
        "xml",
        "asm",
      },

      highlight = {
        enable = true,
      },

      indent = {
        enable = true,
      },
    },

    config = function(_, opts)
      require("nvim-treesitter").setup(opts)
    end,
  },
}
