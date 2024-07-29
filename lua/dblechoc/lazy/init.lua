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
	{
		"wakatime/vim-wakatime",
		lazy = false,
		setup = function()
			vim.cmd([[packadd wakatime/vim-wakatime]])
		end,
	},
}
