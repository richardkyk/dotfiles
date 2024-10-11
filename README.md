# Config
## Create symlinks
```powershell
    # You may need to run this as an admin
    # Press tab to expand to the full paths
    cmd /c mklink /d ~\AppData\Local\nvim <location of dotfiles>\nvim
    cmd /c mklink /d ~\.config\wezterm <location of dotfiles>\wezterm

```

# Issues
## tailwind-tools.nvim

By default tailwind-tools.nvim doesn't automatically attach to the buffer when you open it.
This is because of the root_dir option in the config.

To fix this, you can add the following to your init.lua:
```lua
    -- Location on Windows:
    -- ~/AppData/Local/nvim-data/lazy/tailwind-tools/lua/tailwind-tools/lsp.lua
    root_dir = lspconfig.util.root_pattern(
      "tailwind.config.ts", -- <-- Add this line
      "tailwind.config.{js,cjs,mjs,ts}", -- <-- This syntax is supposedly not supported
      "assets/tailwind.config.{js,cjs,mjs,ts}",
      "theme/static_src/tailwind.config.{js,cjs,mjs,ts}"
    ),
```
