#!/bin/bash
set -e
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "==> dotfiles install"

# oh-my-tmux
if [ ! -f ~/.config/tmux/tmux.conf ]; then
  echo "--> installing oh-my-tmux..."
  git clone https://github.com/gpakosz/.tmux.git ~/.local/share/tmux/oh-my-tmux
  mkdir -p ~/.config/tmux
  ln -sf ~/.local/share/tmux/oh-my-tmux/.tmux.conf ~/.config/tmux/tmux.conf
fi

# tmux config
echo "--> linking tmux config..."
mkdir -p ~/.config/tmux
ln -sf "$DOTFILES/tmux/tmux.conf.local" ~/.config/tmux/tmux.conf.local
ln -sf "$DOTFILES/tmux/tmux.conf" ~/.tmux.conf

# claude hud
echo "--> linking claude hud..."
mkdir -p ~/.claude/hud
ln -sf "$DOTFILES/claude/hud/team-hud.mjs" ~/.claude/hud/team-hud.mjs
ln -sf "$DOTFILES/claude/hud/pane-hud.sh"  ~/.claude/hud/pane-hud.sh
chmod +x "$DOTFILES/claude/hud/pane-hud.sh"
ln -sf "$DOTFILES/claude/hud/hud-detail.sh" ~/.claude/hud/hud-detail.sh
chmod +x "$DOTFILES/claude/hud/hud-detail.sh"

# fzf (for interactive HUD)
if ! command -v fzf &>/dev/null && [ ! -f ~/.fzf/bin/fzf ]; then
  echo "--> installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all --no-bash --no-zsh --no-fish
fi

echo ""
echo "done. reload tmux: tmux source ~/.config/tmux/tmux.conf"
