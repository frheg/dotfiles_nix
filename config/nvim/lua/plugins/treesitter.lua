
return {

  {

    "nvim-treesitter/nvim-treesitter",

    branch = "main",

    build = ":TSUpdate",

    config = function()

      local parsers = {

        "bash",

        "c",

        "lua",

        "vim",

        "vimdoc",

        "python",

        "javascript",

        "typescript",

        "tsx",

        "json",

        "yaml",

        "toml",

        "markdown",

        "markdown_inline",

        "nix",

      }

      local ok_config, ts_config = pcall(require, "nvim-treesitter.config")

      local ok_ts, ts = pcall(require, "nvim-treesitter")

      if ok_config and ok_ts then

        local installed = ts_config.get_installed()

        local missing = {}

        for _, parser in ipairs(parsers) do

          if not vim.tbl_contains(installed, parser) then

            table.insert(missing, parser)

          end

        end

        if #missing > 0 then

          ts.install(missing)

        end

      end

      vim.api.nvim_create_autocmd("FileType", {

        callback = function()

          pcall(vim.treesitter.start)

        end,

      })

    end,

  },

}

