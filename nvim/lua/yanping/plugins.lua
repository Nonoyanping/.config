-- auto install packer if not installed
local ensure_packer = function()
  local fn = vim.fn
  local is_bootstrap = false
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    is_bootstrap = true
    fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end
local packer_bootstrap = ensure_packer() -- true if packer was just installed

-- autocommand that reloads neovim and installs/updates/removes plugins
-- when file is saved
vim.cmd([[ 
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- import packer safely
local status, packer = pcall(require, "packer")
if not status then
  return
end

-- add list of plugins to install
require('packer').startup(function(use)
  -- Package manager
  use 'wbthomason/packer.nvim'

  -- essential plugins
  use("tpope/vim-surround") -- add, delete, change surroundings (it's awesome)
  use("inkarkat/vim-ReplaceWithRegister") -- replace with register contents using motion (gr + motion)
  
  -- commenting with gc
  use("numToStr/Comment.nvim") -- "gc" to comment visual regions/lines

  -- colorscheme
  use 'navarasu/onedark.nvim' -- Theme inspired by Atom
  
  use { -- a file explorer
    'nvim-tree/nvim-tree.lua',
    requires = {
      'nvim-tree/nvim-web-devicons', -- optional, for file icons(vscode like icons)
    },
    tag = 'nightly' -- optional, updated every week. (see issue #1193)
  }

  -- statusline
  use("nvim-lualine/lualine.nvim")
  
  use 'lukas-reineke/indent-blankline.nvim' -- Add indentation guides even on blank lines
  use 'tpope/vim-sleuth' -- Detect tabstop and shiftwidth automatically
--
  use { -- LSP Configuration & Plugins
   'neovim/nvim-lspconfig',
   requires = {
     -- Automatically install LSPs to stdpath for neovim
     'williamboman/mason.nvim',
     'williamboman/mason-lspconfig.nvim',

     -- Useful status updates for LSP
     'j-hui/fidget.nvim',

     -- Additional lua configuration, makes nvim stuff amazing
     'folke/neodev.nvim',
   },
 }

  -- configuring lsp servers
  use("hrsh7th/cmp-nvim-lsp") --for autocompletion
  use({ "glepnir/lspsaga.nvim", branch = "main" }) -- enhanced lsp uis
  use("onsails/lspkind.nvim") -- vs-code like icons for autocompletion

  -- Autocompletion
  use("hrsh7th/nvim-cmp")
  use("hrsh7th/cmp-buffer")
  use("hrsh7th/cmp-path")

  -- snippets
  use("L3MON4D3/LuaSnip") -- snippet engine
  use("saadparwaiz1/cmp_luasnip") -- for autocompletion
  use("rafamadriz/friendly-snippets") -- useful snippets

 use { -- Highlight, edit, and navigate code
   'nvim-treesitter/nvim-treesitter',
   run = function()
     pcall(require('nvim-treesitter.install').update { with_sync = true })
   end,
 }
 use { -- Additional text objects via treesitter
   'nvim-treesitter/nvim-treesitter-textobjects',
   after = 'nvim-treesitter',
 }

--  -- Git related plugins
 use 'tpope/vim-fugitive'
 use 'tpope/vim-rhubarb'
 use 'lewis6991/gitsigns.nvim'
--
--
--  -- Fuzzy Finder (files, lsp, etc)
  use { 'nvim-telescope/telescope.nvim', branch = '0.1.x', requires = { 'nvim-lua/plenary.nvim' } }
--
--  -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', cond = vim.fn.executable 'make' == 1 }
--
--  -- Add custom plugins to packer from ~/.config/nvim/lua/custom/plugins.lua
--  local has_plugins, plugins = pcall(require, 'custom.plugins')
--  if has_plugins then
--    plugins(use)
--  end

  if is_bootstrap then
    require('packer').sync()
  end
end)

-- When we are bootstrapping a configuration, it doesn't
-- make sense to execute the rest of the init.lua.
--
-- You'll need to restart nvim, and then it will work.
if is_bootstrap then
  print '=================================='
  print '    Plugins are being installed'
  print '    Wait until Packer completes,'
  print '       then restart nvim'
  print '=================================='
  return
end

-- Automatically source and re-compile packer whenever you save this init.lua
local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
  command = 'source <afile> | silent! LspStop | silent! LspStart | PackerCompile',
  group = packer_group,
  pattern = vim.fn.expand '$MYVIMRC',
})
