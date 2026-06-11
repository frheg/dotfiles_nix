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

      vim.api.nvim_create_user_command("LazyGitPopup", function()
        vim.fn.system({
          "tmux",
          "display-popup",
          "-E",
          "-w",
          "90%",
          "-h",
          "90%",
          "lazygit",
        })
      end, {})

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

      local function footer_line(label, value, label_hl, value_hl)
        local line = string.format("%-8s │ %s", label, value)

        return {
          type = "text",
          val = line,
          opts = {
            position = "center",
            hl = {
              { label_hl, 0, 8 },
              { "AlphaFooterPipe", 9, 10 },
              { value_hl, 12, -1 },
            },
          },
        }
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
        dashboard.button("z", "Lazygit", "<cmd>LazyGitPopup<CR>"),
        dashboard.button("p", "Plugins", "<cmd>Lazy<CR>"),
        dashboard.button("h", "Healthcheck", "<cmd>checkhealth<CR>"),
        dashboard.button("q", "Quit", "<cmd>qa<CR>"),
      }

      local stats = require("lazy").stats()
      local startup = math.floor(stats.startuptime * 100) / 100

      local footer_host = footer_line("host", hostname(), "AlphaFooterHostLabel", "AlphaFooterHostValue")
      local footer_cwd = footer_line("cwd", cwd(), "AlphaFooterCwdLabel", "AlphaFooterCwdValue")
      local footer_git = footer_line("git", git_branch() .. " [" .. git_state() .. "]", "AlphaFooterGitLabel", "AlphaFooterGitValue")
      local footer_plugins = footer_line("plugins", stats.loaded .. "/" .. stats.count .. " loaded in " .. startup .. " ms", "AlphaFooterPluginsLabel", "AlphaFooterPluginsValue")
      local footer_time = footer_line("time", os.date("%d.%m.%Y %H:%M"), "AlphaFooterTimeLabel", "AlphaFooterTimeValue")

      vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#89b4fa" })
      vim.api.nvim_set_hl(0, "AlphaButtons", { fg = "#cdd6f4" })
      vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = "#cba6f7", bold = true })

      vim.api.nvim_set_hl(0, "AlphaFooterPipe", { fg = "#45475a" })

      vim.api.nvim_set_hl(0, "AlphaFooterHostLabel", { fg = "#89b4fa" })
      vim.api.nvim_set_hl(0, "AlphaFooterHostValue", { fg = "#a6adc8" })
      vim.api.nvim_set_hl(0, "AlphaFooterCwdLabel", { fg = "#94e2d5" })
      vim.api.nvim_set_hl(0, "AlphaFooterCwdValue", { fg = "#a6adc8" })
      vim.api.nvim_set_hl(0, "AlphaFooterGitLabel", { fg = "#b4befe" })
      vim.api.nvim_set_hl(0, "AlphaFooterGitValue", { fg = "#a6adc8" })
      vim.api.nvim_set_hl(0, "AlphaFooterPluginsLabel", { fg = "#f5c2e7" })
      vim.api.nvim_set_hl(0, "AlphaFooterPluginsValue", { fg = "#a6adc8" })
      vim.api.nvim_set_hl(0, "AlphaFooterTimeLabel", { fg = "#fab387" })
      vim.api.nvim_set_hl(0, "AlphaFooterTimeValue", { fg = "#a6adc8" })

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
