-- Python development plugins

-- uv.nvim: uv package manager integration
vim.pack.add({ "https://github.com/benomahony/uv.nvim" })
require("uv").setup({})

-- Python 快捷键
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function(ev)
		vim.keymap.set("n", "<leader>i", function()
			vim.lsp.buf.code_action({
				context = { only = { "quickfix" } },
				filter = function(action)
					return action.title and action.title:find("[Ii]mport")
				end,
				apply = true,
			})
		end, { buffer = ev.buf, desc = "自动导入光标下的符号" })

		vim.keymap.set("n", "<leader>I", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" } },
				apply = true,
			})
		end, { buffer = ev.buf, desc = "整理导入 (organize imports)" })
	end,
})
