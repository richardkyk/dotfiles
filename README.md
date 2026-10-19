# Config
## Create symlinks
### Windows
```powershell
    # You may need to run this as an admin
    # Press tab to expand to the full paths
    cmd /c mklink /d ~\AppData\Local\nvim <location of dotfiles>\nvim
    cmd /c mklink /d ~\.config\wezterm <location of dotfiles>\wezterm

```

### WSL
```bash
ln -sf ~/Developer/dotfiles/starship/starship.toml ~/.config/starship.toml
ln -sf ~/Developer/dotfiles/nvim ~/.config/nvim
ln -sf ~/Developer/dotfiles/wezterm ~/.config/wezterm
ln -sf ~/Developer/dotfiles/.zshrc ~/.zshrc
```
This will create a symlinks from `~/.config` to the folder for the repo.

### macOS
```bash
link() {
    # move a real folder aside first, otherwise ln drops the link inside it
    if [ -e "$2" ] && [ ! -L "$2" ]; then mv "$2" "$2.old"; fi
    ln -sfn "$1" "$2"
}
mkdir -p ~/.config
link ~/Developer/dotfiles/hammerspoon ~/.hammerspoon
# link the whole directory, karabiner stops watching karabiner.json if the file itself is a symlink
link ~/Developer/dotfiles/karabiner ~/.config/karabiner
# bin/ isn't in git, carry it over from the old folder
[ -d ~/.hammerspoon.old/bin ] && cp -a ~/.hammerspoon.old/bin ~/Developer/dotfiles/hammerspoon/
```
Reload Hammerspoon, check everything works, then delete the `.old` folders.
