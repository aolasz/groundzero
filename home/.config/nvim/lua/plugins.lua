-- Bootstrapping {{{
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
-- }}}

-- Setup (plugin table) {{{
require('lazy').setup({
  {
    'williamboman/mason-lspconfig.nvim',
    config = require('configs.mason-lspconfig-nvim'),
    dependencies = { { 'williamboman/mason.nvim', config = true } },
  },
  {
    'hrsh7th/nvim-cmp',
    config = require('configs.nvim-cmp'),
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      { 'onsails/lspkind.nvim', event = 'VimEnter' },
    },
  },
  { 'neovim/nvim-lspconfig', config = require('configs.nvim-lspconfig') },
  {
    'nvim-treesitter/nvim-treesitter',
    config = require('configs.nvim-treesitter'),
    build = ':TSUpdate',
  },
  {
    'nvimtools/none-ls.nvim',
    ft = {},
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = require('configs.none-ls-nvim'),
  },
  { 'JoshPorterDev/nvim-base16', config = require('configs.base16-nvim') },
  { 'nvim-lualine/lualine.nvim', config = require('configs.lualine-nvim') },
  {
    'nvim-tree/nvim-tree.lua',
    config = require('configs.nvim-tree-lua'),
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
  {
    'folke/trouble.nvim',
    config = require('configs.trouble-nvim'),
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
  {
    'folke/todo-comments.nvim',
    config = require('configs.todo-comments-nvim'),
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
  'tpope/vim-commentary',
  'tpope/vim-obsession',
  'LnL7/vim-nix',
  { 'preservim/vim-markdown', ft = { 'markdown' } },
  {
      'iamcco/markdown-preview.nvim',
      cmd = {
        'MarkdownPreviewToggle',
        'MarkdownPreview',
        'MarkdownPreviewStop'
      },
      ft = { 'markdown' },
      build = function() vim.fn['mkdp#util#install']() end,
  },
  {
    'JuliaEditorSupport/julia-vim',
    config = require('configs.julia-vim'),
  }
  -- TODO: dasht
})
-- }}}

-- vim: ts=2:sw=2:et:fen:fdm=marker
