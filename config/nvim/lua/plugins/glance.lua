return {
  {
    "dnlhc/glance.nvim",
    cmd = "Glance",
    keys = {
      { "gp", "<cmd>Glance definitions<CR>", desc = "Peek definition" },
      { "<leader>lp", "<cmd>Glance references<CR>", desc = "Peek references" },
      { "<leader>li", "<cmd>Glance implementations<CR>", desc = "Peek implementations" },
    },
    config = function()
      require("glance").setup({})
    end,
  },
}
