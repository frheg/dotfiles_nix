return {
  {
    "neovim/nvim-lspconfig",

    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },

    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.lsp.config("nil_ls", {
        capabilities = capabilities,
      })

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      vim.lsp.config("pyright", {
        capabilities = capabilities,
      })

      vim.lsp.config("ruff", {
        capabilities = capabilities,
      })

      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
      })

      vim.lsp.config("marksman", {
        capabilities = capabilities,
      })

      vim.lsp.config("taplo", {
        capabilities = capabilities,
      })

      vim.lsp.enable({
        "nil_ls",
        "lua_ls",
        "pyright",
        "ruff",
        "ts_ls",
        "marksman",
        "taplo",
      })

      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
      vim.keymap.set("n", "<leader>lr", vim.lsp.buf.references, { desc = "References" })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
    end,
  },
}
