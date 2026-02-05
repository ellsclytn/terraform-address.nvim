# terraform-address.nvim

A Neovim plugin that extracts Terraform resource addresses from your cursor position and copies them to a register. Useful for quickly grabbing resource addresses for referencing in other Terraform blocks, or for using in external commands (e.g. `terraform apply -target $address`).

## Features

- Extract Terraform addresses from various block types:
  - Resources: `aws_instance.example`
  - Data sources: `data.aws_ami.ubuntu`
  - Modules: `module.vpc`
  - Variables: `var.region`
  - Outputs: `output.instance_ip`
- Provides visual feedback via notifications

## Requirements

- Neovim >= 0.9.0 (for Tree-sitter support)
- Tree-sitter HCL parser installed

### Installing Tree-sitter HCL Parser

```vim
:TSInstall hcl
```

Or if using `nvim-treesitter` in your config:

```lua
require('nvim-treesitter.configs').setup {
  ensure_installed = { "hcl", "terraform" },
}
```

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "ellsclytn/terraform-address.nvim",
  ft = { "terraform", "hcl" },
  config = function()
    -- Optional: Add a keybinding
    vim.keymap.set("n", "<leader>ta", ":TerraformAddress<CR>", {
      desc = "Get Terraform address",
      silent = true,
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "ellsclytn/terraform-address.nvim",
  ft = { "terraform", "hcl" },
  config = function()
    vim.keymap.set("n", "<leader>ta", ":TerraformAddress<CR>", {
      desc = "Get Terraform address",
      silent = true,
    })
  end,
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'ellsclytn/terraform-address.nvim'
```

## Usage

### Command

Place your cursor anywhere inside a Terraform block and run:

```vim
:TerraformAddress
```

The address will be copied to the unnamed register by default. You'll see a notification with the copied address and which register was used.

#### Using Named Registers

Just like yanking in Vim, you can specify a register to copy to:

```vim
"a:TerraformAddress    " Copy to register 'a'
"+:TerraformAddress    " Copy to system clipboard
"*:TerraformAddress    " Copy to selection clipboard
```

### Keybinding

Add a keybinding in your Neovim config:

```lua
vim.keymap.set("n", "<leader>ta", ":TerraformAddress<CR>", {
  desc = "Get Terraform address",
  silent = true,
})
```

The keybinding respects register prefixes, so you can use:

- `"a<leader>ta` to copy to register 'a'
- `"+<leader>ta` to copy to system clipboard

### Example

Given this Terraform code:

```hcl
resource "aws_instance" "web_server" {
  ami           = "ami-123456789"
  instance_type = "t2.micro"
}
```

With your cursor anywhere inside the block, running `:TerraformAddress` will copy:

```
aws_instance.web_server
```

## Supported Block Types

| Block Type  | Example Input                   | Output                |
| ----------- | ------------------------------- | --------------------- |
| Resource    | `resource "aws_instance" "web"` | `aws_instance.web`    |
| Data Source | `data "aws_ami" "ubuntu"`       | `data.aws_ami.ubuntu` |
| Module      | `module "vpc"`                  | `module.vpc`          |
| Variable    | `variable "region"`             | `var.region`          |
| Output      | `output "instance_ip"`          | `output.instance_ip`  |

## How It Works

The plugin uses Neovim's Tree-sitter integration to parse the HCL/Terraform syntax tree. When you invoke the command:

1. It finds the Tree-sitter node at your cursor position
2. Traverses up the syntax tree to find the nearest block
3. Extracts the block identifier and labels
4. Constructs the appropriate Terraform address format
5. Copies it to the specified register (or unnamed register if none specified)
