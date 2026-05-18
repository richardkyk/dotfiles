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
