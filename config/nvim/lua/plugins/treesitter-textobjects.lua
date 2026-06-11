return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",

    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },

    event = { "BufReadPost", "BufNewFile" },

    opts = {
      select = {
        enable = true,
        lookahead = true,

        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
        },
      },

      move = {
        enable = true,
        set_jumps = true,

        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@class.outer",
        },

        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
        },
      },
    },

    config = function(_, opts)
      require("nvim-treesitter-textobjects").setup(opts)
    end,
  },
}
