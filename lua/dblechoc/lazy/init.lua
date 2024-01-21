return {
	{
		"nvim-lua/plenary.nvim",
		name = "plenary",
	},
	{
		"tpope/vim-commentary",
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
	},
	"eandrju/cellular-automaton.nvim",
	{
		"wakatime/vim-wakatime",
		lazy = false,
		setup = function()
			vim.cmd([[packadd wakatime/vim-wakatime]])
		end,
	},
}
