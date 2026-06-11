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

      local function cmd_output(cmd)
        local handle = io.popen(cmd)
        if handle == nil then
          return ""
        end

        local result = handle:read("*a") or ""
        handle:close()

        return result:gsub("%s+$", "")
      end

      local function git_branch()
        local branch = cmd_output("git branch --show-current 2>/dev/null")
        if branch == "" then
          return "no git repo"
        end
        return branch
      end

      local function git_state()
        local dirty = cmd_output("git status --porcelain 2>/dev/null")
        if dirty == "" then
          return "clean"
        end
        return "dirty"
      end

      local function hostname()
        return cmd_output("hostname")
      end

      local function cwd()
        return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
      end

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
        dashboard.button("z", "Lazygit", "<cmd>silent !tmux display-popup -E -w 90% -h 90% lazygit<CR>"),
        dashboard.button("p", "Plugins", "<cmd>Lazy<CR>"),
        dashboard.button("h", "Healthcheck", "<cmd>checkhealth<CR>"),
        dashboard.button("q", "Quit", "<cmd>qa<CR>"),
      }

      dashboard.section.footer.val = function()
        local stats = require("lazy").stats()

        return {
          "host    |" .. hostname(),
          "cwd     |" .. cwd(),
          "git     |" .. git_branch() .. " [" .. git_state() .. "]",
          "plugins |" .. stats.loaded .. "/" .. stats.count
            .. " loaded in " .. math.floor(stats.startuptime * 100) / 100 .. " ms",
          "time    |" .. os.date("%Y-%m-%d %H:%M"),
        }
      end

      -- Catppuccin-style dashboard colors.
      vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#89b4fa" })
      vim.api.nvim_set_hl(0, "AlphaButtons", { fg = "#cdd6f4" })
      vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = "#cba6f7", bold = true })
      vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#f38ba8" })

      dashboard.section.header.opts.hl = "AlphaHeader"
      dashboard.section.buttons.opts.hl = "AlphaButtons"
      dashboard.section.buttons.opts.hl_shortcut = "AlphaShortcut"
      dashboard.section.footer.opts.hl = "AlphaFooter"

      dashboard.opts.opts.noautocmd = true

      alpha.setup(dashboard.opts)
    end,
  },
}
