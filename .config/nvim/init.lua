-- ========================
-- init.lua
-- Configuración moderna con lazy.nvim + mason.nvim + mason-lspconfig
-- ========================

-- ========================
-- Bootstrap lazy.nvim
-- ========================

vim.loader.enable()
vim.opt.mouse = ""
vim.opt.lazyredraw = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- última versión estable
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- ========================
-- Plugins
-- ========================
require("lazy").setup({

	-- Temas / UI
	{ "folke/tokyonight.nvim",     lazy = false,                                    priority = 1000 },
	{ "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },

	-- LSP y autocompletado
	{ "neovim/nvim-lspconfig" },
	{ "williamboman/mason.nvim",   build = ":MasonUpdate",                          config = true },
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"bashls",
					"lua_ls",
					"gopls",
					"pyright",
					"ts_ls",
					"html",
					"cssls",
					"clangd",
					"jsonls",
					"jdtls",
				},
			})
		end
	},
	{ "hrsh7th/nvim-cmp" },
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "L3MON4D3/LuaSnip" },

	{ "jiangmiao/auto-pairs" },

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
	},
})

-- ========================
-- Opciones básicas
-- ========================
vim.o.number = true
vim.o.relativenumber = true
vim.o.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.cmd("colorscheme tokyonight")

-- ========================
-- Lualine
-- ========================
require("lualine").setup({
	options = { theme = "tokyonight" },
})

-- ========================
-- Autocompletado
-- ========================
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
	snippet = {
		expand = function(args) luasnip.lsp_expand(args.body) end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	}),
})

-- ========================
-- Configuración de LSP (MÉTODO MODERNO SIN DEPRECATION WARNINGS)
-- ========================

-- Capacidades de autocompletado
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Configurar servidores LSP
local servers = {
	bashls = {},
	lua_ls = {
		settings = {
			Lua = {
				runtime = { version = 'LuaJIT' },
				diagnostics = { globals = { 'vim' } },
				workspace = { library = vim.api.nvim_get_runtime_file("", true) },
				telemetry = { enable = false },
			}
		}
	},
	gopls = {},
	pyright = {},
	ts_ls = {},
	html = {},
	cssls = {},
	clangd = {},
	jsonls = {},
	jdtls = {},
}


local server_cmds = {
	bashls = { "bash-language-server", "start" },
	lua_ls = { "lua-language-server" },
	gopls = { "gopls" },
	pyright = { "pyright-langserver", "--stdio" },
	ts_ls = { "typescript-language-server", "--stdio" },
	html = { "vscode-html-language-server", "--stdio" },
	cssls = { "vscode-css-language-server", "--stdio" },
	clangd = { "clangd" },
	jsonls = { "vscode-json-language-server", "--stdio" },
	jdtls = { "jdtls" },
}

-- Configurar cada servidor LSP con el nuevo método
for server, config in pairs(servers) do
	local final_config = vim.tbl_deep_extend("force", {
		capabilities = capabilities,
	}, config or {})

	-- Usar vim.lsp.start en lugar de require('lspconfig') para evitar warnings
	vim.api.nvim_create_autocmd("FileType", {
		pattern = {
			"lua", "go", "python", "javascript", "typescript",
			"html", "css", "c", "cpp", "json", "bash", "sh",
			"java"
		},
		callback = function(args)
			local bufnr = args.buf
			local filetype = vim.bo[bufnr].filetype

			if filetype == "sql" then return end

			-- Mapear filetypes a servidores LSP
			local ft_to_server = {
				lua = "lua_ls",
				go = "gopls",
				python = "pyright",
				javascript = "typescript-language-server",
				typescript = "typescript-language-server",
				html = "html",
				css = "cssls",
				c = "clangd",
				cpp = "clangd",
				json = "jsonls",
				bash = "bashls",
				sh = "bashls",
				java = "jdtls",
			}

			local server_for_ft = ft_to_server[filetype]
			if server_for_ft and server_for_ft == server then
				local root_dir = vim.fs.dirname(vim.fs.find({ '.git', 'package.json', 'Makefile' },
					{ upward = true })[1])

				if server == 'jdtls' then
					root_dir = vim.fs.dirname(vim.fs.find({ 'pom.xml', 'build.gradle' },
						{ upward = true })[1])
				end

				vim.lsp.start({
					name = server,
					cmd = server_cmds[server],
					capabilities = capabilities,
					settings = config and config.settings or nil,
					root_dir = root_dir, -- Usamos la variable definida o modificada
				})
			end
		end,
	})
end

-- ========================
-- Keymaps para LSP (método moderno)
-- ========================
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		local bufnr = ev.buf
		local client = vim.lsp.get_client_by_id(ev.data.client_id)

		if not client then return end

		local opts = { buffer = bufnr }
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
		vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
		vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
	end,
})

-- ========================
-- Treesitter
-- ========================
require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"lua", "go", "python", "javascript", "typescript",
		"html", "css", "sql", "json", "bash", "c", "cpp"
	},
	highlight = { enable = true },
	indent = { enable = true },
})

-- ========================
-- Configuración adicional
-- ========================

-- Formateo automático al guardar
vim.api.nvim_create_autocmd('BufWritePre', {
	pattern = { '*.lua', '*.py', '*.js', '*.ts', '*.go', '*.json', '*.c', '*.cpp', '*.java' },
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})

-- Mejorar diagnósticos
vim.diagnostic.config({
	virtual_text = { spacing = 4, prefix = '●' },
	signs = true,
	underline = true,
	update_in_insert = false,
})
