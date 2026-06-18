vim.pack.add({
	"https://github.com/tpope/vim-fugitive",
	"https://github.com/aaronhallaert/advanced-git-search.nvim",
})
require("telescope").load_extension("advanced_git_search")
