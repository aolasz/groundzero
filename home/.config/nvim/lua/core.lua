local utils = require('utils')

-- GLOBALS {{{

vim.g.mapleader = ','

vim.g.loaded_netrw = 1 -- disable netrw in favor of nvim-tree
vim.g.loaded_netrwPlugin = 1

-- }}} GLOBALS

-- OPTIONS {{{

-- Misc {{{
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' } -- for cmp-nvim-lsp
vim.opt.mouse = '' -- disable mouse support
-- }}}

-- Colors {{{
if not utils.is_legacy_mode() then
  vim.opt.termguicolors = true
end
-- }}}

-- Lines {{{
vim.opt.textwidth = 79
vim.opt.formatexpr = '' -- expression to eval when doing gq or auto-formatting
-- }}}

-- Tabs {{{
vim.opt.tabstop = 4 -- number of visual spaces per tab
vim.opt.shiftwidth = 4 -- default number of inserted spaces on a tab
vim.opt.expandtab = true -- tabs are spaces
-- }}}

-- Folding {{{
vim.opt.foldenable = false -- no folding, enabled manually using :set fen
vim.opt.foldmethod = 'expr' -- fold based on tree-sitter
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
-- }}}

-- UI config {{{
vim.opt.splitright = true -- new vsplits to the right
vim.opt.splitbelow = true -- new hsplits below
vim.opt.number = true -- absolute line number for the cursor line
vim.opt.relativenumber = true -- and relative line number for other lines
vim.opt.colorcolumn = '+1' -- color the column at textwidth+1
-- Enable to conserve horizontal space
vim.opt.signcolumn = 'number' -- signs in the number col to conserve hspace
-- vim.opt.signcolumn = 'yes' -- always display the sign column
vim.opt.list = true -- show tabs, spaces, and line endings
vim.opt.listchars = { tab = '▸ ', trail = '·' } -- invisible char substitutes
vim.opt.updatetime = 250
-- }}}

-- Searching {{{
vim.opt.incsearch = true -- search as chars are entered
vim.opt.hlsearch = false -- do not highlight matches
vim.opt.ignorecase = true -- ignore case in searches by default
vim.opt.smartcase = true -- but case-sensitive if uppercase is entered
-- }}}

-- }}} OPTIONS

-- HIGHLIGHTS {{{

if utils.is_legacy_mode() then
  -- HACK: Get rid of the ugly Pmenu color
  vim.api.nvim_set_hl(0, 'PMenu', { link = 'FloatBorder' })
else
  -- Force italic comments
  -- Update highlight instead of replacing the definition, therefore use
  -- `vim.cmd.highlight`
  vim.cmd.highlight({ 'Comment', 'cterm=italic', 'gui=italic' })
  vim.cmd.highlight({ 'Todo', 'cterm=italic', 'gui=italic' })
end

-- }}} HIGHLIGHTS

-- AUTOCOMMANDS {{{

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = { '*.md' },
  callback = function()
    vim.opt_local.textwidth = 79
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = { '*.json', '*.nix' },
  callback = function()
    vim.opt_local.shiftwidth = 2
  end
})

-- }}} AUTOCOMMANDS

-- KEYMAPS {{{

-- Keymap options function with optional decription {{{
local function opts(description) return {
  noremap = true, -- non-recursive
  silent = true, -- do not show message
  desc = description or '',
}
end
-- }}}

-- Resize windows with arrows {{{
vim.keymap.set('n', '<C-w>Up', ':resize -2<CR>', opts())
vim.keymap.set('n', '<C-w>Down', ':resize +2<CR>', opts())
vim.keymap.set('n', '<C-w>Left', ':vertical resize -2<CR>', opts())
vim.keymap.set('n', '<C-w>Right', ':vertical resize +2<CR>', opts())
-- }}}

-- Clipboard handling {{{
-- Copy to clipboard
vim.keymap.set('v', '<leader>y', '"+y', opts())
vim.keymap.set('n', '<leader>Y', '"+yg_', opts())
vim.keymap.set('n', '<leader>y', '"+y', opts())
vim.keymap.set('n', '<leader>yy', '"+yy', opts())
-- Paste from clipboard
vim.keymap.set('n', '<leader>p', '"+p', opts())
vim.keymap.set('n', '<leader>P', '"+P', opts())
vim.keymap.set('v', '<leader>p', '"+p', opts())
vim.keymap.set('v', '<leader>P', '"+P', opts())
-- Re-copy after pasting from buffer to easily paste multiple times
-- https://stackoverflow.com/a/7164121
vim.keymap.set('v', 'p', 'pgvy', opts())
-- }}}

-- Move cursor by display lines (and not physical ones) {{{
vim.keymap.set('n', 'k', 'gk', opts())
vim.keymap.set('n', 'j', 'gj', opts())
vim.keymap.set('n', '0', 'g0', opts())
vim.keymap.set('n', '$', 'g$', opts())
-- }}}

-- Delete trailing white space {{{
-- https://stackoverflow.com/a/3475364
vim.keymap.set(
  'n',
  '<leader>w',
  function()
    vim.cmd([[exe 'normal mz']])
    vim.cmd([[%s/\s\+$//ge]])
    vim.cmd([[exe 'normal `z']])
  end,
  opts('Delete trailing white space')
)
-- }}}

-- nvim-tree.lua {{{
vim.keymap.set(
  'n', '<leader>e', [[:NvimTreeToggle<CR>]], opts('Toggle nvim-tree')
)
-- }}}

-- trouble.nvim {{{
vim.keymap.set('', '<leader>t', [[:TroubleToggle<CR>]], opts('Toggle trouble'))
-- }}}

-- todo-comments.nvim {{{
vim.keymap.set('n', ']t', function()
  require('todo-comments').jump_next()
end, opts('Next todo comment'))

vim.keymap.set('n', '[t', function()
  require('todo-comments').jump_prev()
end, opts('Previous todo comment'))
-- }}}

-- }}} KEYMAPS

-- vim: ts=2:sw=2:et:fen:fdm=marker
