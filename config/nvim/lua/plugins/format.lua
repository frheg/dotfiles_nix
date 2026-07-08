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
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          scss = { "prettier" },
          sh = { "shfmt" },
          bash = { "shfmt" },
          c = { "clang_format" },
          cpp = { "clang_format" },
          toml = { "taplo" },
        },
      })
    end,
  },
}
