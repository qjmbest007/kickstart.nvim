-- 1. 使用 vim.pack.add 声明 nvim-jdtls 插件
-- vim.pack 会自动处理插件的下载和安装
vim.pack.add({
	"https://github.com/mfussenegger/nvim-jdtls",
	-- "https://github.com/nvim-java/nvim-java",
})

-- 2. 配置 jdtls
local jdk21_home = "/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
local lombok_jar = "/Users/qiudali/.local/share/nvim/mason/share/jdtls/lombok.jar"
local mason_path = vim.fn.stdpath("data") .. "/mason/packages"

-- 收集 DAP 相关的 bundle jars
local function get_debug_bundles()
	local bundles = {}
	-- java-debug-adapter
	local debug_jar =
		vim.fn.glob(mason_path .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar")
	if debug_jar ~= "" then
		table.insert(bundles, debug_jar)
	end
	-- java-test
	local test_jars = vim.fn.glob(mason_path .. "/java-test/extension/server/*.jar", false, true)
	for _, jar in ipairs(test_jars) do
		table.insert(bundles, jar)
	end
	return bundles
end

-- 用于生成 jdtls 启动命令的函数
local function get_jdtls_cmd()
	local cmd = { vim.fn.exepath("jdtls") }
	if vim.fn.filereadable(lombok_jar) == 1 then
		table.insert(cmd, string.format("--jvm-arg=-javaagent:%s", lombok_jar))
	end

	table.insert(cmd, "--java-executable")
	table.insert(cmd, jdk21_home .. "/bin/java")

	return cmd
end

local jdtls_cmd = get_jdtls_cmd()
-- 创建 autocmd，当打开 .java 文件时，启动 jdtls
vim.api.nvim_create_autocmd("FileType", {
	pattern = "java",
	callback = function()
		local bundles = get_debug_bundles()
		-- 为当前的 Java 缓冲区启动或关联 jdtls 客户端
		require("jdtls").start_or_attach({
			cmd = jdtls_cmd,
			root_dir = vim.fs.root(vim.fn.getcwd(), { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
			settings = {
				java = {
					format = {
						enabled = true,
						settings = {
							url = "file://" .. vim.fn.expand("~/.config/nvim/lua/config/intellij-java-style.xml"),
							profile = "IntelliJ IDEA Default",
						},
					},
				},
			},
			init_options = {
				bundles = bundles,
			},
		})
	end,
})

-- 保存 Java 文件时自动整理导入
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.java",
	callback = function()
		local clients = vim.lsp.get_clients({ bufnr = 0, name = "jdtls" })
		if #clients > 0 then
			require("jdtls").organize_imports()
			-- 等待 organize_imports 生效
			vim.wait(100, function() end)
		end
	end,
})

-- Java DAP 调试：jdtls 启动后初始化 dap 和 Java 专用快捷键
vim.api.nvim_create_autocmd("LspAttach", {
	pattern = "*.java",
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client.name == "jdtls" then
			require("jdtls").setup_dap({ hotcodereplace = "auto" })
			require("jdtls.dap").setup_dap_main_class_configs()

			local buf = args.buf

			-- 整理导入（去除无用 + 排序）
			vim.keymap.set("n", "<leader>oi", function()
				require("jdtls").organize_imports()
			end, { buffer = buf, desc = "Organize Imports" })

			-- 添加缺失导入（通过 code action）
			vim.keymap.set("n", "<leader>ai", function()
				vim.lsp.buf.code_action({
					context = { diagnostics = vim.diagnostic.get(0), only = { "quickfix" } },
					filter = function(action)
						return action.title and action.title:match("Import")
					end,
					apply = true,
				})
			end, { buffer = buf, desc = "Add Missing Import" })

			vim.keymap.set("n", "<leader>ev", function()
				vim.lsp.buf.code_action({
					context = { diagnostics = {}, only = { "refactor.extract.variable" } },
					apply = true,
				})
			end, { buffer = buf, desc = "Extract Variable" })

			vim.keymap.set("n", "<leader>ea", function()
				vim.lsp.buf.code_action({
					context = { diagnostics = {}, only = { "refactor.extract.variable.all" } },
					apply = true,
				})
			end, { buffer = buf, desc = "Extract All Occurrences" })

			vim.keymap.set("n", "<leader>ec", function()
				vim.lsp.buf.code_action({
					context = { diagnostics = {}, only = { "refactor.extract.constant" } },
					apply = true,
				})
			end, { buffer = buf, desc = "Extract Constant" })

			vim.keymap.set("n", "<leader>em", function()
				vim.lsp.buf.code_action({
					context = { diagnostics = {}, only = { "refactor.extract.method" } },
					apply = true,
				})
			end, { buffer = buf, desc = "Extract Method" })
		end
	end,
})
