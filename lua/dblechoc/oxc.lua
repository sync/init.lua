local M = {}

local config_files = {
	oxfmt = { ".oxfmtrc.json", ".oxfmtrc.jsonc" },
	oxlint = { ".oxlintrc.json", ".oxlintrc.jsonc" },
}

for tool, files in pairs(config_files) do
	for _, extension in ipairs({ "ts", "mts", "cts", "js", "mjs", "cjs" }) do
		table.insert(files, tool .. ".config." .. extension)
	end
end

local function declares_tool(dir, tool)
	local ok, package = pcall(function()
		return vim.json.decode(table.concat(vim.fn.readfile(dir .. "/package.json"), "\n"))
	end)
	if not ok or type(package) ~= "table" then
		return false
	end
	for _, field in ipairs({ "dependencies", "devDependencies", "optionalDependencies" }) do
		if type(package[field]) == "table" and package[field][tool] then
			return true
		end
	end
	return false
end

-- Resolve from the buffer, including package configs inside a monorepo.
function M.root(filename, tool)
	for dir in vim.fs.parents(filename) do
		for _, name in ipairs(config_files[tool]) do
			local config = vim.fs.joinpath(dir, name)
			if vim.uv.fs_stat(config) then
				return dir, config
			end
		end
		if declares_tool(dir, tool) then
			return dir
		end
		if vim.uv.fs_stat(dir .. "/.git") then
			break
		end
	end
end

function M.command(root, tool)
	local dir = root
	while dir do
		local command = vim.fs.joinpath(dir, "node_modules", ".bin", tool)
		if vim.fn.executable(command) == 1 then
			return command
		end
		if vim.uv.fs_stat(dir .. "/.git") then
			break
		end
		local parent = vim.fs.dirname(dir)
		if parent == dir then
			break
		end
		dir = parent
	end
	return tool
end

return M
