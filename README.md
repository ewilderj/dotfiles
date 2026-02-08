# @ewilderj dotfiles

Personal shell and terminal configuration.

## What's here

- **zsh/zshrc** — main zsh config (history, completion, editor, aliases)
- **zsh/ghostty-colors.zsh** — auto-tints Ghostty tabs by project directory
  or SSH host using deterministic color hashing
- **ghostty/config** — Ghostty terminal config (Dracula theme, FiraCode Nerd Font)

## Install

```bash
cd ~/git/dotfiles
bash install.sh
```

This symlinks configs into place (backs up any existing files to `*.bak`).
Put machine-specific config in `~/.zshrc-local` (not tracked).

## Tab coloring

Tabs are automatically colored when you work in Ghostty:

- **`~/git/<project>`** — cool-toned tints (blue, teal, green, purple…),
  tab title shows `📁 project-name`
- **SSH sessions** — warm-toned tints (red, amber, copper…),
  tab title shows `🖥 hostname`
- **Elsewhere** — default Dracula background

Colors are deterministic — the same project/host always gets the same color.
