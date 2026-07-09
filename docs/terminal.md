# Terminal

This repository includes a terminal profile because the terminal workflow is
part of the desktop experience.

## Kitty

Files:

```text
config/kitty/kitty.conf
config/kitty/theme.conf
```

`kitty.conf` sets:

- Zsh as the shell;
- JetBrainsMono Nerd Font;
- compact padding;
- transparent dark background;
- theme include file;
- optional local override include.

`theme.conf` imports generated palette colors from:

```text
~/.config/theme/colors-kitty.conf
```

## Zsh

Files:

```text
config/zsh/.zshrc
config/zsh/modules/
```

The `.zshrc` is small and loads ordered module files:

- environment setup;
- optional Oh My Zsh compatibility;
- completion;
- plugins;
- aliases;
- Fastfetch startup;
- local machine overrides.

The config expects pacman packages for:

- `zsh-autosuggestions`;
- `zsh-syntax-highlighting`;
- `fzf`;
- `eza`.

## Fastfetch

Files:

```text
config/fastfetch/config.jsonc
config/fastfetch/logo.txt
```

The Fastfetch profile is intentionally compact: system, kernel, uptime, packages,
shell, terminal, WM, theme, icons, CPU/GPU, memory, disk, and colors.

## Local Changes

For private machine-specific shell changes, copy the example:

```bash
cp ~/.config/zsh/modules/90-local.zsh.example ~/.config/zsh/modules/90-local.zsh
```

Keep private aliases, tokens, or host-specific exports out of the public repo.
