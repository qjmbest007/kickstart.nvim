-- autopairs
-- https://github.com/windwp/nvim-autopairs

vim.pack.add({ "https://github.com/windwp/nvim-autopairs" })
require("nvim-autopairs").setup({
	-- 禁用 autopairs 的补全确认功能
	disable_filetype = { "TelescopePrompt" },
	check_ts = true,
	-- 关键：禁用自动确认补全
	disable_in_macro = false,
	-- 不自动处理补全确认，让 blink.cmp 处理
	disable_in_visualblock = false,
})
vim.keymap.del("i", "<CR>")
