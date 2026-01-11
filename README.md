### Quick Start

### gtk

Make symbolic links from `gtk-3.0` and `gtk-4.0` folders under `~/.config/`

Next, make symbolic links from `catppuccin-mocha-mauve-standard+default` to the following locations:
  - `~/.local/share/themes/`
  - `/usr/share/themes`

Finally, run the following commands to set the themes:
```bash 
gsettings set org.gnome.desktop.interface gtk-theme catppuccin-mocha

# Ensure that GTK_THEME env var is set properly. Otherwise, check `~/.config/uwsm/env` and make sure you're running hyprland-uwsm
echo $GTK_THEME
# ^ 'catppuccin-mocha-mauve-standard+default'

