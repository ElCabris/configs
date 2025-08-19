-- Tema
vim.cmd.colorscheme("vim")

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
      { out,                            "WarningMsg" },
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
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = function()
        require("nvim-autopairs").setup({ check_ts = true })
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        local cmp = require("cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end,
    },
  },
  install = { colorscheme = { "habamax" } },
  checker = { enabled = true },
})

-- Función on_attach
local function on_attach(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, opts)

  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  if filetype == "python" then
    vim.keymap.set("n", "<leader>f", function()
      vim.cmd("!black %")
      vim.cmd("edit!")
    end, opts)
  elseif client.supports_method("textDocument/formatting") then
    vim.keymap.set('n', '<leader>f', function()
      vim.lsp.buf.format({ async = true })
    end, opts)
  end
end

local lspconfig = require('lspconfig')

-- Configuración de LSPs
local capabilities = require('cmp_nvim_lsp').default_capabilities()


lspconfig.sqls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

lspconfig.bashls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

lspconfig.lua_ls.setup({
  cmd = { vim.fn.expand("~/tools/lua-language-server/bin/lua-language-server") },
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})


lspconfig.jdtls.setup {
  cmd = { 'jdtls', "-data", vim.fn.expand("~/cache/jdtls-workspace"), "--jvm-arg=--enable-native-access=ALL-UNNAMED" },
  root_dir = lspconfig.util.root_pattern('pom.xml', 'gradle.build', '.git'),
  on_attach = on_attach,
  settings = {
    java = {
      signatureHelp = { enabled = true },
      contentProvider = { preferred = 'fernflower' },

      imports = {
        gradle = {
          wrapper = {
            checksums = {
              {
                sha256 = "7d3a4ac4de1c32b59bc6a4eb8ecb8e612ccd0cf1ae1e99f66902da64df296172",
                allowed = true
              }
            }
          }
        }
      }
    }
  }
}

lspconfig.gopls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        unreachable = true,
      },
      staticcheck = true,
    },
  },
})

lspconfig.html.setup {
  capabilities = capabilities,
  on_attach = on_attach,
}

lspconfig.cssls.setup {
  capabilities = capabilities,
  on_attach = on_attach,
}

lspconfig.clangd.setup({
  capabilities = capabilities,
  cmd = { "clangd" },
  filetype = { "c", "cpp", "objc", "objcpp" },
  root_dir = lspconfig.util.root_pattern(".git", "compile_commands.json", "CMakeLists.txt"),
  on_attach = on_attach,
})

lspconfig.pyright.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

lspconfig.r_language_server.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

lspconfig.ts_ls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
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
