vim.pack.add({ "https://github.com/akinsho/bufferline.nvim" })
require("bufferline").setup({
	options = {
		-- 显示模式：buffers（显示所有缓冲区）或 tabs（显示标签页）
		mode = "buffers",
		-- 始终显示 bufferline
		always_show_bufferline = true,
		-- 显示缓冲区图标
		show_buffer_icons = true,
		-- 显示缓冲区关闭按钮
		show_buffer_close_icons = true,
		-- 显示关闭图标
		show_close_icon = true,
		-- 分隔符样式："slant", "slope", "thick", "thin" 等
		separator_style = "thin",
		-- 文件名的显示格式
		-- :t 表示只显示文件名，不显示路径
		name_formatter = function(buf)
			return vim.fn.fnamemodify(buf.name, ":t")
		end,
	},
})

--buffer 快捷键
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "关闭当前buffer" })
vim.keymap.set("n", "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", { desc = "关闭其他buffer" })
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "下一个buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "上一个buffer" })

vim.keymap.set("n", "<leader>bs", ":bprevious<CR>", { desc = "选择一个buffer" })
vim.keymap.set("n", "<leader>bg", ":BufferLinePick<CR>", { desc = "选择挑战buffer" })
