# My NeoVim config

Modified from [Neovim-from-scratch](https://github.com/LunarVim/Neovim-from-scratch)

## Try out this config

Make sure to remove or move your current `nvim` directory

### MacOS/Linux

```bash
git clone git@github.com:trevorgjohnson/nvim-config.git ~/.config/nvim
```

### Windows

```bash
git clone https://github.com/trevorgjohnson/nvim-config.git ~/Appdata/Local/nvim
```

Then go to `lua/user/plugins.lua (line 6,9)` and `lua/user/dashboard.lua (line 208,211)` and comment/uncomment the relevant lines

_e.g._
```lua
-- uncomment below for MacOS/Linux
--[[ local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim" ]]

--uncomment below for Windows
local install_path = fn.stdpath('data') .. "\\site\\pack\\packer\\start\\packer.nvim"

```

---

### Alacritty
if you would like to try out the alacritty config as well, use this command:
```bash
# MacOS/Linux
cp -r ~/nvim/alacritty ~/alacritty 

# Windows
cp -r /Appdata/Local/nvim/alacritty ~/Appdata/Local/ 
```

---

Run `nvim` and wait for the plugins to be installed

Also run `npm i solidity-ls -g` for a working solidity lsp (_until the solc lsp works better_)

**NOTE** (You will notice treesitter pulling in a bunch of parsers the next time you open Neovim)

### Plugin List

_See [lua/user/plugins.lua]_
