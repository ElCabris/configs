-- Configuración para netrw
vim.opt.compatible = false -- set nocp
vim.cmd("filetype plugin on")

-- Establecer la identación a 2 espacios
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.softtabstop = 2

-- Mapeo de la tecla <leader>
vim.g.mapleader = " " -- Establece la tecla <leader> como la barra espaciadora

-- Configuración para copiar en el portapapeles
vim.opt.clipboard:append("unnamedplus")

-- Permitir buffers sin guardar
vim.opt.hidden = true

-- Habilitar numeración global
vim.opt.number = true

-- Habilitar numeración relativa
vim.opt.relativenumber = true

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { "neovim/nvim-lspconfig" },
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
  },
  install = { colorscheme = { "habamax" } },
  checker = { enabled = true },
})

-- Mapeos de teclas para LSP
vim.api.nvim_set_keymap('n', '<leader>gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gr', '<Cmd>lua vim.lsp.buf.references()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>f', '<Cmd>lua vim.lsp.buf.format()<CR>', { noremap = true, silent = true })

-- Configuración de LSP para C y C++ usando clangd
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

lspconfig.clangd.setup({
  capabilities = capabilities,
  cmd = { "clangd" },
  filetype = { "c", "cpp", "objc", "objcpp" },
  root_dir = lspconfig.util.root_pattern(".git", "compile_commands.json", "CMakeLists.txt")
})

lspconfig.pyright.setup({
  capabilities = capabilities,
})

-- Configuración nvim-cmp
local cmp = require('cmp')
cmp.setup({
  mapping = {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
})
