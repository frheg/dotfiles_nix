return {
  {
    "mikavilpas/yazi.nvim",

    event = "VeryLazy",

    dependencies = {
      "nvim-lua/plenary.nvim",
    },

    keys = {
      {
        "<leader>e",
        "<cmd>Yazi<CR>",
        desc = "Open Yazi file explorer",
      },
      {
        "<leader>E",
        "<cmd>Yazi cwd<CR>",
        desc = "Open Yazi in cwd",
      },
    },

    opts = {
      open_for_directories = true,

      keymaps = {
        show_help = "<f1>",
      },
    },
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash jump",
      },
    },
  },
}
