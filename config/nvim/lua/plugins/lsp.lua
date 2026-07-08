return {
  {
    "neovim/nvim-lspconfig",

    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      local servers = {
        nil_ls = {},
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
            },
          },
        },
        pyright = {},
        ruff = {},
        ts_ls = {},
        marksman = {
          filetypes = { "markdown" },
        },
        taplo = {},
        bashls = {},
        clangd = {},
        dockerls = {},
        html = {},
        cssls = {},
        jsonls = {},
        yamlls = {},
        rust_analyzer = {},
        jdtls = {},
        kotlin_language_server = {},
        sqls = {},
        zls = {},
        lemminx = {},
        asm_lsp = {},
        hls = {},
      }

      for name, opts in pairs(servers) do
        opts.capabilities = capabilities
        vim.lsp.config(name, opts)
      end

      vim.lsp.enable(vim.tbl_keys(servers))

      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
      vim.keymap.set("n", "<leader>lr", vim.lsp.buf.references, { desc = "References" })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
    end,
  },
}
