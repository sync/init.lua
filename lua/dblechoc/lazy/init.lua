return {
	{
		"nvim-lua/plenary.nvim",
		name = "plenary",
	},
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("trouble").setup({})
		end,
	},
	"github/copilot.vim",
	"eandrju/cellular-automaton.nvim",
}
