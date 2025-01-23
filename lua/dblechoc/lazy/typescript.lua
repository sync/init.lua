return {
	"pmizio/typescript-tools.nvim",
	dependencies = {
		"plenary",
		"neovim/nvim-lspconfig",
	},
	config = function()
		local lspconfig = require("lspconfig")
		-- local api = require("typescript-tools.api")

		-- local baseDefinitionHandler = vim.lsp.handlers["textDocument/definition"]

		-- local filter = function(arr, fn)
		-- 	if type(arr) ~= "table" then
		-- 		return arr
		-- 	end

		-- 	local filtered = {}
		-- 	for k, v in pairs(arr) do
		-- 		if fn(v, k, arr) then
		-- 			table.insert(filtered, v)
		-- 		end
		-- 	end

		-- 	return filtered
		-- end

		-- local filterReactDTS = function(value)
		-- 	if value.uri then
		-- 		return string.match(value.uri, "%.d.ts") == nil
		-- 	elseif value.targetUri then
		-- 		return string.match(value.targetUri, "%.d.ts") == nil
		-- 	end
		-- end

		local capabilities = vim.tbl_deep_extend(
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			require("cmp_nvim_lsp").default_capabilities()
		)

		require("typescript-tools").setup({
			capabilities = capabilities,
			handlers = {
				-- ["textDocument/definition"] = function(err, result, method, ...)
				-- 	if vim.tbl_islist(result) and #result > 1 then
				-- 		local filtered_result = filter(result, filterReactDTS)
				-- 		return baseDefinitionHandler(err, filtered_result, method, ...)
				-- 	end

				-- 	baseDefinitionHandler(err, result, method, ...)
				-- end,
				-- ["textDocument/publishDiagnostics"] = api.filter_diagnostics(
				-- 	-- Ignore 'File is a CommonJS module, it may be converted to an ES6 module.' diagnostics.
				-- 	-- Igngore 'X is deprecated.' diagnotics
				-- 	{ 80001, 6387 }
				-- ),
				["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
					if result.diagnostics ~= nil then
						local idx = 1
						while idx <= #result.diagnostics do
							local diagnostic = result.diagnostics[idx]
							-- React Navigation 6 -> 7 at spaceship (navigateDeprecated)
							if diagnostic.code == 80001 or string.match(diagnostic.message, "navigateDeprecated") then
								table.remove(result.diagnostics, idx)
							else
								idx = idx + 1
							end
						end
					end
					vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
				end,
			},
			root_dir = lspconfig.util.root_pattern("tsconfig.json", "jsconfig.json", "package.json", ".git"),
			single_file_support = true,
			settings = {
				expose_as_code_action = "all",
				jsx_close_tag = {
					enable = true,
					filetypes = { "javascriptreact", "typescriptreact" },
				},
			},
		})
	end,
}
