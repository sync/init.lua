return {
	"williamboman/mason-lspconfig.nvim",
	dependencies = {
		"williamboman/mason.nvim",
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
	},
	config = function()
		local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
		end

		local cmp = require("cmp")
		local cmp_select = { behavior = cmp.SelectBehavior.Select }

		local capabilities = vim.tbl_deep_extend(
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			require("cmp_nvim_lsp").default_capabilities()
		)

		local baseDefinitionHandler = vim.lsp.handlers["textDocument/definition"]

		local filter = function(arr, fn)
			if type(arr) ~= "table" then
				return arr
			end

			local filtered = {}
			for k, v in pairs(arr) do
				if fn(v, k, arr) then
					table.insert(filtered, v)
				end
			end

			return filtered
		end

		require("fidget").setup()
		require("mason").setup()
		require("mason-tool-installer").setup({
			ensure_installed = {
				"eslint",
				"gopls",
				"lua_ls",
				"rust_analyzer",
				"tailwindcss",
				"ts_ls",
				"yamlls",
				-- formatter
				"prettier",
				"stylua",
				"goimports",
			},
			auto_update = false,
		})
		require("mason-lspconfig").setup({
			automatic_installation = true,
			handlers = {
				function(server_name)
					require("lspconfig")[server_name].setup({
						capabilities = capabilities,
						-- on_attach = on_attach,
					})
				end,

				["ts_ls"] = function()
					local lspconfig = require("lspconfig")

					local filterReactDTS = function(value)
						if value.uri then
							return string.match(value.uri, "%.d.ts") == nil
						elseif value.targetUri then
							return string.match(value.targetUri, "%.d.ts") == nil
						end
					end

					local handlers = {
						["textDocument/definition"] = function(err, result, method, ...)
							if vim.tbl_islist(result) and #result > 1 then
								local filtered_result = filter(result, filterReactDTS)
								return baseDefinitionHandler(err, filtered_result, method, ...)
							end

							baseDefinitionHandler(err, result, method, ...)
						end,
						["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
							if result.diagnostics ~= nil then
								local idx = 1
								while idx <= #result.diagnostics do
									if result.diagnostics[idx].code == 80001 then
										table.remove(result.diagnostics, idx)
									else
										idx = idx + 1
									end
								end
							end
							vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
						end,
					}

					lspconfig.ts_ls.setup({
						capabilities = capabilities,
						on_attach = function(client, bufnr)
							vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
						end,
						handlers = handlers,
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
					})
				end,

				["eslint"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.eslint.setup({
						capabilities = capabilities,
						settings = {
							workingDirectories = { mode = "auto" },
							experimental = {
								useFlatConfig = false,
							},
						},
						on_attach = function(client, bufnr)
							vim.api.nvim_create_autocmd("BufWritePre", {
								buffer = bufnr,
								command = "EslintFixAll",
							})
						end,
					})
				end,
				["lua_ls"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.lua_ls.setup({
						capabilities = capabilities,
						settings = {
							Lua = {
								diagnostics = {
									globals = { "vim" },
								},
							},
						},
					})
				end,
				["rust_analyzer"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.rust_analyzer.setup({
						capabilities = capabilities,
						on_attach = function(client, bufnr)
							vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
						end,
						settings = {
							["rust-analyzer"] = {
								checkOnSave = {
									command = "clippy",
								},
							},
						},
					})
				end,
			},
		})

		cmp.setup({
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

		vim.diagnostic.config({
			update_in_insert = true,
			float = {
				focusable = false,
				border = "rounded",
			},
		})
	end,
}
