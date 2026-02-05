local M = {}

function M.get_terraform_address()
	-- Get the parser for the current buffer
	local parser = vim.treesitter.get_parser(0, "hcl")
	if not parser then
		vim.notify("Treesitter parser not found for Terraform/HCL", vim.log.levels.ERROR)
		return
	end

	local tree = parser:parse()[1]
	local root = tree:root()

	-- Get cursor position
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row, col = cursor[1] - 1, cursor[2]

	-- Find the node at cursor
	local node = root:named_descendant_for_range(row, col, row, col)

	-- Traverse up to find a block
	while node do
		local node_type = node:type()

		if node_type == "block" then
			-- Get the block identifier (resource, data, module, etc.)
			local identifier_node = node:child(0)
			if not identifier_node then
				break
			end

			local identifier = vim.treesitter.get_node_text(identifier_node, 0)

			-- Get the labels (quoted strings after the identifier)
			local labels = {}
			local child_count = node:child_count()

			for i = 1, child_count - 1 do
				local child = node:child(i)
				if child and child:type() == "string_lit" then
					local label_text = vim.treesitter.get_node_text(child, 0)
					-- Remove quotes
					label_text = label_text:gsub('^"', ""):gsub('"$', "")
					table.insert(labels, label_text)
				end
			end

			-- Construct the address based on block type
			local address = M.construct_address(identifier, labels)

			if address then
				-- Use the register specified by the user (or unnamed by default)
				local register = vim.v.register
				vim.fn.setreg(register, address)

				local reg_display = register == '"' and '(unnamed)' or '"' .. register
				vim.notify(string.format("Copied to register %s: %s", reg_display, address), vim.log.levels.INFO)
				return address
			end
		end

		node = node:parent()
	end

	vim.notify("No Terraform block found at cursor", vim.log.levels.WARN)
end

function M.construct_address(identifier, labels)
	if identifier == "resource" and #labels == 2 then
		return labels[1] .. "." .. labels[2]
	elseif identifier == "data" and #labels == 2 then
		return "data." .. labels[1] .. "." .. labels[2]
	elseif identifier == "module" and #labels == 1 then
		return "module." .. labels[1]
	elseif identifier == "variable" and #labels == 1 then
		return "var." .. labels[1]
	elseif identifier == "output" and #labels == 1 then
		return "output." .. labels[1]
	elseif identifier == "locals" then
		-- TODO: For locals, we'd need to find the specific local being referenced
		return nil
	end

	return nil
end

return M
