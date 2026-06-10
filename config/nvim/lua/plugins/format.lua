return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    keys = {
      {
        "<leader>lf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        desc = "Format buffer",
      },
    },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          nix = { "nixfmt" },
          python = { "ruff_format" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          json = { "prettier" },
          markdown = { "prettier" },
        },
      })
    end,
  },
}
