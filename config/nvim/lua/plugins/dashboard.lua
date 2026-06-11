return {
  {
    "goolord/alpha-nvim",

    event = "VimEnter",

    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },

    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "                                                     ",
        " ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
        " ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
        " ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
        " ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
        " ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
        " ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
        "                                                     ",
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "Find file", "<cmd>Telescope find_files<CR>"),
        dashboard.button("g", "Live grep", "<cmd>Telescope live_grep<CR>"),
        dashboard.button("e", "Yazi file explorer", "<cmd>Yazi<CR>"),
        dashboard.button("r", "Recent files", "<cmd>Telescope oldfiles<CR>"),
        dashboard.button("c", "Edit Neovim config", "<cmd>e ~/.config/dotfiles_nix/config/nvim/init.lua<CR>"),
        dashboard.button("d", "Open dotfiles", "<cmd>cd ~/.config/dotfiles_nix | Yazi<CR>"),
        dashboard.button("l", "Lazy plugins", "<cmd>Lazy<CR>"),
        dashboard.button("h", "Healthcheck", "<cmd>checkhealth<CR>"),
        dashboard.button("q", "Quit", "<cmd>qa<CR>"),
      }

      dashboard.section.footer.val = function()
        local stats = require("lazy").stats()
        return "Loaded "
          .. stats.loaded
          .. "/"
          .. stats.count
          .. " plugins in "
          .. math.floor(stats.startuptime * 100) / 100
          .. " ms"
      end

      dashboard.opts.opts.noautocmd = true

      alpha.setup(dashboard.opts)
    end,
  },
}
