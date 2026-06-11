return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },

    config = function()
      local colors = {
        bg       = "NONE",
        fg       = "#a6adc8",
        muted    = "#6c7086",
        surface  = "#313244",
        blue     = "#89b4fa",
        green    = "#94e2d5",
        lavender = "#b4befe",
        pink     = "#f5c2e7",
        peach    = "#fab387",
        red      = "#f38ba8",
        mauve    = "#cba6f7",
      }

      local theme = {
        normal = {
          a = { fg = colors.mauve, bg = colors.bg, gui = "bold" },
          b = { fg = colors.blue,  bg = colors.bg },
          c = { fg = colors.fg,    bg = colors.bg },
        },
        insert = {
          a = { fg = colors.green, bg = colors.bg, gui = "bold" },
        },
        visual = {
          a = { fg = colors.peach, bg = colors.bg, gui = "bold" },
        },
        replace = {
          a = { fg = colors.red, bg = colors.bg, gui = "bold" },
        },
        command = {
          a = { fg = colors.blue, bg = colors.bg, gui = "bold" },
        },
        inactive = {
          a = { fg = colors.muted, bg = colors.bg },
          b = { fg = colors.muted, bg = colors.bg },
          c = { fg = colors.muted, bg = colors.bg },
        },
      }

      require("lualine").setup({
        options = {
          theme = theme,
          globalstatus = true,
          component_separators = { left = "│", right = "│" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            statusline = { "alpha" },
          },
        },

        sections = {
          lualine_a = {
            {
              "mode",
              fmt = function(s)
                return s:lower()
              end,
            },
          },

          lualine_b = {
            {
              "branch",
              icon = "",
              color = { fg = colors.mauve, bg = colors.bg, gui = "bold" },
            },
            {
              "diff",
              symbols = {
                added = "+",
                modified = "~",
                removed = "-",
              },
              colored = true,
            },
          },

          lualine_c = {
            {
              "filename",
              path = 1,
              color = { fg = colors.fg, bg = colors.bg },
            },
          },

          lualine_x = {
            {
              "diagnostics",
              symbols = {
                error = "E ",
                warn  = "W ",
                info  = "I ",
                hint  = "H ",
              },
            },
            {
              "encoding",
              color = { fg = colors.muted, bg = colors.bg },
            },
            {
              "filetype",
              colored = true,
            },
          },

          lualine_y = {
            {
              "progress",
              color = { fg = colors.lavender, bg = colors.bg },
            },
          },

          lualine_z = {
            {
              "location",
              color = { fg = colors.blue, bg = colors.bg, gui = "bold" },
            },
          },
        },

        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {
            {
              "filename",
              path = 1,
              color = { fg = colors.muted, bg = colors.bg },
            },
          },
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
      })
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },
}
