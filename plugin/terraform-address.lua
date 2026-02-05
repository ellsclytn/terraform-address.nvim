-- Prevent loading the plugin twice
if vim.g.loaded_terraform_address then
	return
end
vim.g.loaded_terraform_address = true

-- Create the user command with register support
vim.api.nvim_create_user_command("TerraformAddress", function()
	require("terraform-address").get_terraform_address()
end, {
	desc = "Get Terraform address at cursor and copy to register",
	register = true,
})
