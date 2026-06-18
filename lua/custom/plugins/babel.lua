vim.pack.add({
	"https://github.com/acidsugarx/babel.nvim",
})

-- 替换 google provider 为 MyMemory（国内可用，免费无需注册）
local mymemory = {}

local function url_encode(str)
	if vim.uri_encode then
		return vim.uri_encode(str)
	end
	return string.gsub(str, "([^%w%-_.~])", function(c)
		return string.format("%%%02X", string.byte(c))
	end)
end

function mymemory.translate(text, source, target, callback)
	local config = require("babel.config")
	local curl = require("babel.providers.curl")
	local network_opts = config.options.network or {}
	local timeout_args, _, request_timeout = curl.timeout_args(network_opts)

	local langpair = (source == "auto" and "autodetect" or source) .. "|" .. target
	local encoded_text = url_encode(text)
	local url = string.format(
		"https://api.mymemory.translated.net/get?q=%s&langpair=%s",
		encoded_text,
		url_encode(langpair)
	)

	local cmd = { "curl", "-sS" }
	vim.list_extend(cmd, timeout_args)
	table.insert(cmd, url)

	curl.run(cmd, { provider = "google", request_timeout = request_timeout }, function(response, err)
		if err then
			callback(nil, err)
			return
		end

		if not response or response == "" then
			callback(nil, {
				code = "empty_response",
				provider = "google",
				message = "empty response from MyMemory API",
			})
			return
		end

		local ok, json = pcall(vim.json.decode, response)
		if not ok or type(json) ~= "table" then
			callback(nil, {
				code = "invalid_json",
				provider = "google",
				message = "invalid JSON from MyMemory API",
			})
			return
		end

		if json.responseStatus ~= 200 or not json.responseData then
			callback(nil, {
				code = "api_error",
				provider = "google",
				message = "MyMemory API error: " .. (json.responseDetails or "unknown"),
			})
			return
		end

		local translated = json.responseData.translatedText or ""
		if translated == "" then
			callback(nil, {
				code = "invalid_response",
				provider = "google",
				message = "empty translation from MyMemory API",
			})
			return
		end

		callback(translated, nil)
	end)
end

package.loaded["babel.providers.google"] = mymemory

require("babel").setup({
	target = "zh",
	provider = "google",
})

vim.keymap.set("v", "<leader>tr", function()
	require("babel").translate_selection()
end, { desc = "翻译选中的文本" })

vim.keymap.set("n", "<leader>tw", function()
	require("babel").translate_word()
end, { desc = "翻译光标下的单词" })
