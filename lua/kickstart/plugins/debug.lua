-- 最简单好用的 DAP 配置 - 适合新手

-- 1. 安装插件
vim.pack.add({
	"https://github.com/mfussenegger/nvim-dap",
	"https://github.com/rcarriga/nvim-dap-ui",
	"https://github.com/nvim-neotest/nvim-nio", -- dap-ui 的依赖
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/jay-babu/mason-nvim-dap.nvim",
})

-- 2. 设置快捷键（最简单的方式）
-- F5: 开始/继续调试
vim.keymap.set("n", "<F5>", function()
	require("dap").continue()
end)
-- F1: 进入函数内部
vim.keymap.set("n", "<F1>", function()
	require("dap").step_into()
end)
-- F2: 跳过当前行
vim.keymap.set("n", "<F2>", function()
	require("dap").step_over()
end)
-- F3: 跳出当前函数
vim.keymap.set("n", "<F3>", function()
	require("dap").step_out()
end)
-- F9: 设置/取消断点（最常用）
vim.keymap.set("n", "<F9>", function()
	require("dap").toggle_breakpoint()
end)
-- F10: 显示调试界面
vim.keymap.set("n", "<F10>", function()
	require("dapui").toggle()
end)
-- F6: 停止调试并关闭界面
vim.keymap.set("n", "<F6>", function()
	require("dap").terminate()
	require("dapui").close()
end)

-- 3. 基础配置
local dap = require("dap")
local dapui = require("dapui")

-- 安装 Mason（管理调试器）
require("mason").setup()

-- 配置 mason-nvim-dap
require("mason-nvim-dap").setup({
	automatic_installation = true,
	ensure_installed = {
		"java-debug-adapter",
		"java-test",
	},
})

-- 4. 配置 dap-ui 界面
dapui.setup({
	-- 简单的图标设置
	icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
	-- 侧边栏布局
	layouts = {
		{
			elements = { "scopes", "breakpoints", "stacks", "watches" },
			size = 40,
			position = "left",
		},
		{
			elements = { "repl", "console" },
			size = 10,
			position = "bottom",
		},
	},
})

-- 自动打开/关闭调试界面
dap.listeners.after.event_initialized["dapui_config"] = dapui.open
dap.listeners.before.event_terminated["dapui_config"] = dapui.close
dap.listeners.before.event_exited["dapui_config"] = dapui.close

-- Java 调试配置已移至 java.lua（通过 nvim-jdtls 集成）
