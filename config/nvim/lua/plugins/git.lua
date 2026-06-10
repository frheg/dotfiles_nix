return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },

    opts = {
      current_line_blame = false,

      current_line_blame_opts = {
        delay = 300,
        virt_text_pos = "eol",
      },

      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("n", "]h", gs.next_hunk, "Next git hunk")
        map("n", "[h", gs.prev_hunk, "Previous git hunk")

        map("n", "<leader>gb", gs.blame_line, "Git blame line")
        map("n", "<leader>gB", function()
          gs.blame_line({ full = true })
        end, "Git blame line full")

        map("n", "<leader>gtb", gs.toggle_current_line_blame, "Toggle git blame")
        map("n", "<leader>gd", gs.diffthis, "Git diff this")
        map("n", "<leader>gp", gs.preview_hunk, "Preview git hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset git hunk")
        map("n", "<leader>gs", gs.stage_hunk, "Stage git hunk")
      end,
    },
  },

  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gdo", "<cmd>DiffviewOpen<CR>", desc = "Open diffview" },
      { "<leader>gdc", "<cmd>DiffviewClose<CR>", desc = "Close diffview" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "File history" },
    },
  },

  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
    keys = {
      { "<leader>gg", "<cmd>Git<CR>", desc = "Git status" },
    },
  },
}
