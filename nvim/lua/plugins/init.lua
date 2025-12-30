return {
  { lazy = true, "nvim-lua/plenary.nvim" },

  { "nvim-tree/nvim-web-devicons", opts = {} },
  { "echasnovski/mini.statusline", opts = {} },
  { "lewis6991/gitsigns.nvim", opts = {} },

  "EdenEast/nightfox.nvim",
  "sainnhe/gruvbox-material",
  "habamax/vim-polar",

  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    opts = {},
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require "plugins.configs.treesitter"
    end,
  },

  {
    "akinsho/bufferline.nvim",
    opts = require "plugins.configs.bufferline",
  },

  -- we use blink plugin only when in insert mode
  -- so lets lazyload it at InsertEnter event
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    dependencies = {
      "rafamadriz/friendly-snippets",

      -- snippets engine
      {
        "L3MON4D3/LuaSnip",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },

      -- autopairs , autocompletes ()[] etc
      { "windwp/nvim-autopairs", opts = {} },
    },
    -- made opts a function cuz cmp config calls cmp module
    -- and we lazyloaded cmp so we dont want that file to be read on startup!
    opts = function()
      return require "plugins.configs.blink"
    end,
  },

  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = { "Mason", "MasonInstall" },
    opts = {},
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
    end,
  },

  {
    "stevearc/conform.nvim",
    opts = require "plugins.configs.conform",
  },

  -- {
  --   "nvimdev/indentmini.nvim",
  --   event = { "BufReadPre", "BufNewFile" },
  --   opts = {},
  -- },

  -- files finder etc
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    opts = require "plugins.configs.telescope",
  },

  {
    'Julian/lean.nvim',
    event = { 'BufReadPre *.lean', 'BufNewFile *.lean' },

    dependencies = {
      'neovim/nvim-lspconfig',
      'nvim-lua/plenary.nvim',

      -- optional dependencies:

      -- a completion engine
      --    hrsh7th/nvim-cmp or Saghen/blink.cmp are popular choices

      -- 'nvim-telescope/telescope.nvim', -- for 2 Lean-specific pickers
      'andymass/vim-matchup',          -- for enhanced % motion behavior
      -- 'andrewradev/switch.vim',        -- for switch support
      -- 'tomtom/tcomment_vim',           -- for commenting
    },

    ---@type lean.Config
    opts = { -- see below for full configuration options
      mappings = true,
    }
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = true})
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
  {
      "rachartier/tiny-code-action.nvim",
      dependencies = {
          {"nvim-lua/plenary.nvim"},
          -- optional picker via telescope
          {"nvim-telescope/telescope.nvim"},
      },
      event = "LspAttach",
      opts = {},
  },
  "tpope/vim-surround",
  "lambdalisue/suda.vim",
  "scrooloose/nerdcommenter",
  "tpope/vim-fugitive",
  "szw/vim-maximizer",
}
