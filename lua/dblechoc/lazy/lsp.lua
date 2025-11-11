return {
	"mason-org/mason-lspconfig.nvim",
	dependencies = {
		"mason-org/mason.nvim",
		"neovim/nvim-lspconfig",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/nvim-cmp",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		"j-hui/fidget.nvim",
		"zbirenbaum/copilot-cmp",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"onsails/lspkind.nvim",
	},
	config = function()
		require("fidget").setup()

		vim.lsp.config("*", {
			capabilities = vim.tbl_deep_extend(
				"force",
				{},
				vim.lsp.protocol.make_client_capabilities(),
				require("cmp_nvim_lsp").default_capabilities()
			),
		})

		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
					},
					diagnostics = {
						globals = {
							"vim",
							"require",
						},
					},
				},
			},
		})

		vim.lsp.config("tailwindcssls", {
			settings = {
				tailwindCSS = {
					classAttributes = {
						"class",
						"className",
						"class:list",
						"classList",
						"ngClass",
					},
				},
			},
		})

		vim.lsp.config("ts_ls", {
			init_options = {
				preferences = {
					includeInlayParameterNameHints = "none",
					includeInlayParameterNameHintsWhenArgumentMatchesName = false,
					includeInlayFunctionParameterTypeHints = false,
					includeInlayVariableTypeHints = false,
					includeInlayVariableTypeHintsWhenTypeMatchesName = false,
					includeInlayPropertyDeclarationTypeHints = false,
					includeInlayFunctionLikeReturnTypeHints = true,
					includeInlayEnumMemberValueHints = true,
				},
			},
			on_attach = function(client, bufnr)
				vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
			end,
			handlers = {
				["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
					if err then
						vim.notify("[lsp] Error on publishDiagnostics: " .. vim.inspect(err), vim.log.levels.ERROR)
						return
					end
					if result == nil or result.diagnostics == nil then
						return
					end

					-- Filter out diagnostics matching the pattern by removing them in place
					for i = #result.diagnostics, 1, -1 do
						if string.find(result.diagnostics[i].message, "navigateDeprecated", 1, true) then
							table.remove(result.diagnostics, i)
						end
					end

					-- Call the default handler with filtered diagnostics
					vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
				end,
			},
		})

		local base_eslint_on_attach = vim.lsp.config.eslint.on_attach
		vim.lsp.config("eslint", {
			settings = {
				workingDirectories = { mode = "auto" },
				experimental = {
					useFlatConfig = false,
				},
			},
			on_attach = function(client, bufnr)
				if base_eslint_on_attach then
					base_eslint_on_attach(client, bufnr)
				end

				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = bufnr,
					command = "LspEslintFixAll",
				})
			end,
		})

		require("mason").setup()
		require("mason-tool-installer").setup({
			ensure_installed = {
				"eslint",
				"lua_ls",
				"tailwindcss",
				"ts_ls",
				"yamlls",
				-- formatter
				"prettier",
				"stylua",
			},
			auto_update = false,
		})

		require("mason-lspconfig").setup({
			ensure_installed = {},
			automatic_installation = false,
		})

		local lspkind = require("lspkind")
		local cmp = require("cmp")
		local cmp_select = { behavior = cmp.SelectBehavior.Select }

		cmp.setup({
			formatting = {
				format = lspkind.cmp_format({
					mode = "symbol", -- show only symbol annotations
					maxwidth = {
						-- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
						-- can also be a function to dynamically calculate max width such as
						-- menu = function() return math.floor(0.45 * vim.o.columns) end,
						menu = 50, -- leading text (labelDetails)
						abbr = 50, -- actual suggestion item
					},
					symbol_map = { Copilot = "" },
					ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
					show_labelDetails = true, -- show labelDetails in menu. Disabled by default

					-- The function below will be called before any actual modifications from lspkind
					-- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
					before = function(entry, vim_item)
						-- ...
						return vim_item
					end,
				}),
			},
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			mapping = cmp.mapping.preset.insert({
				["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
				["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
				["<CR>"] = cmp.mapping.confirm({
					behavior = cmp.ConfirmBehavior.Replace,
					select = false,
				}),
				["<C-Space>"] = cmp.mapping.complete(),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "copilot" },
				{ name = "luasnip" },
			}, {
				{ name = "buffer" },
			}),
		})

		local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }

		vim.diagnostic.config({
			virtual_lines = true,
			update_in_insert = true,
			float = {
				focusable = false,
				border = "rounded",
			},
			signs = {
				active = true,
				text = {
					[vim.diagnostic.severity.ERROR] = signs.Error,
					[vim.diagnostic.severity.WARN] = signs.warm,
					[vim.diagnostic.severity.INFO] = signs.info,
					[vim.diagnostic.severity.HINT] = signs.hint,
				},
				texthl = {
					[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
					[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
					[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
					[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
				},
			},
		})
	end,
}
