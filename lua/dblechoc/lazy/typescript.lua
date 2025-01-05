return {
	"pmizio/typescript-tools.nvim",
	dependencies = {
		"plenary",
		"neovim/nvim-lspconfig",
	},
	config = function()
		local api = require("typescript-tools.api")

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

		require("typescript-tools").setup({
			handlers = {
				-- ["textDocument/definition"] = function(err, result, method, ...)
				-- 	if vim.tbl_islist(result) and #result > 1 then
				-- 		local filtered_result = filter(result, filterReactDTS)
				-- 		return baseDefinitionHandler(err, filtered_result, method, ...)
				-- 	end

				-- 	baseDefinitionHandler(err, result, method, ...)
				-- end,
				["textDocument/publishDiagnostics"] = api.filter_diagnostics(
					-- Ignore 'File is a CommonJS module, it may be converted to an ES6 module.' diagnostics.
					{ 80001 }
				),
			},
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
