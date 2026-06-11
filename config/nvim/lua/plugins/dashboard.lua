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

      local stats = require("lazy").stats()
      local startup = math.floor(stats.startuptime * 100) / 100

      local footer_host = {
        type = "text",
        val = "host    " .. hostname(),
        opts = {
          position = "center",
          hl = "AlphaFooterHost",
        },
      }

      local footer_cwd = {
        type = "text",
        val = "cwd     " .. cwd(),
        opts = {
          position = "center",
          hl = "AlphaFooterCwd",
        },
      }

      local footer_git = {
        type = "text",
        val = "git     " .. git_branch() .. " [" .. git_state() .. "]",
        opts = {
          position = "center",
          hl = "AlphaFooterGit",
        },
      }

      local footer_plugins = {
        type = "text",
        val = "plugins " .. stats.loaded .. "/" .. stats.count .. " loaded in " .. startup .. " ms",
        opts = {
          position = "center",
          hl = "AlphaFooterPlugins",
        },
      }

      local footer_time = {
        type = "text",
        val = "time    " .. os.date("%Y-%m-%d %H:%M"),
        opts = {
          position = "center",
          hl = "AlphaFooterTime",
        },
      }

      -- Catppuccin/tmux-style dashboard colors.
      vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#89b4fa" })
      vim.api.nvim_set_hl(0, "AlphaButtons", { fg = "#cdd6f4" })
      vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = "#cba6f7", bold = true })

      vim.api.nvim_set_hl(0, "AlphaFooterHost", { fg = "#89b4fa" })
      vim.api.nvim_set_hl(0, "AlphaFooterCwd", { fg = "#94e2d5" })
      vim.api.nvim_set_hl(0, "AlphaFooterGit", { fg = "#b4befe" })
      vim.api.nvim_set_hl(0, "AlphaFooterPlugins", { fg = "#f5c2e7" })
      vim.api.nvim_set_hl(0, "AlphaFooterTime", { fg = "#fab387" })

      dashboard.section.header.opts.hl = "AlphaHeader"
      dashboard.section.buttons.opts.hl = "AlphaButtons"
      dashboard.section.buttons.opts.hl_shortcut = "AlphaShortcut"

      local opts = dashboard.opts

      opts.layout = {
        { type = "padding", val = 2 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 1 },
        footer_host,
        footer_cwd,
        footer_git,
        footer_plugins,
        footer_time,
      }

      opts.opts.noautocmd = true

      alpha.setup(opts)
    end,
  },
}
