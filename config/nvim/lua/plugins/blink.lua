return {
  {
    "saghen/blink.cmp",

    dependencies = {
      "rafamadriz/friendly-snippets",
    },

    version = "*",

    opts = {
      keymap = {
        preset = "default",
      },

      appearance = {
        nerd_font_variant = "mono",
      },

      completion = {
        documentation = {
          auto_show = true,
        },

        ghost_text = {
          enabled = true,
        },
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },

      fuzzy = {
        implementation = "prefer_rust_with_warning",
      },
    },

    opts_extend = { "sources.default" },
  },
}
