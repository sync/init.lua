return {
	{
		"zbirenbaum/copilot.lua",
		dependencies = {
			"zbirenbaum/copilot-cmp",
		},
		build = ":Copilot auth",
		config = function()
			require("copilot").setup({
				suggestion = { enabled = false },
				panel = { enabled = false },
                -- copilot_model = "gpt-4o-copilot",
			})
			require("copilot_cmp").setup()
		end,
	},
}
