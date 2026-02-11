return {
	"stevearc/conform.nvim",
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				javascript = { "oxfmt", "prettier", stop_after_first = true },
				javascriptreact = { "oxfmt", "prettier", stop_after_first = true },
				typescript = { "oxfmt", "prettier", stop_after_first = true },
				typescriptreact = { "oxfmt", "prettier", stop_after_first = true },
				svelte = { "oxfmt", "prettier", stop_after_first = true },
				vue = { "oxfmt", "prettier", stop_after_first = true },
				css = { "oxfmt", "prettier", stop_after_first = true },
				scss = { "oxfmt", "prettier", stop_after_first = true },
				less = { "oxfmt", "prettier", stop_after_first = true },
				html = { "oxfmt", "prettier", stop_after_first = true },
				json = { "oxfmt", "prettier", stop_after_first = true },
				jsonc = { "oxfmt", "prettier", stop_after_first = true },
				yaml = { "oxfmt", "prettier", stop_after_first = true },
				markdown = { "oxfmt", "prettier", stop_after_first = true },
				["markdown.mdxv"] = { "oxfmt", "prettier", stop_after_first = true },
				graphql = { "oxfmt", "prettier", stop_after_first = true },
				handlebars = { "oxfmt", "prettier", stop_after_first = true },
				lua = { "stylua" },
				go = { "goimports", "gofmt" },
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			},
		})

		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

		vim.keymap.set("n", "<leader>f", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end)
	end,
}
