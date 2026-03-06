#!/bin/bash
set -e
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "==> dotfiles install"

# ── oh-my-tmux ──────────────────────────────────────
if [ ! -f ~/.config/tmux/tmux.conf ]; then
  echo "--> installing oh-my-tmux..."
  git clone https://github.com/gpakosz/.tmux.git ~/.local/share/tmux/oh-my-tmux
  mkdir -p ~/.config/tmux
  ln -sf ~/.local/share/tmux/oh-my-tmux/.tmux.conf ~/.config/tmux/tmux.conf
fi

# ── tmux config ─────────────────────────────────────
echo "--> linking tmux config..."
mkdir -p ~/.config/tmux
ln -sf "$DOTFILES/tmux/tmux.conf.local" ~/.config/tmux/tmux.conf.local
# clipboard/terminal 설정 (oh-my-tmux base는 건드리지 않음)
cp "$DOTFILES/tmux/tmux.conf.extra" ~/.tmux.conf

# ── claude hud ──────────────────────────────────────
echo "--> linking claude hud..."
mkdir -p ~/.claude/hud
ln -sf "$DOTFILES/claude/hud/team-hud.mjs"  ~/.claude/hud/team-hud.mjs
ln -sf "$DOTFILES/claude/hud/pane-hud.sh"   ~/.claude/hud/pane-hud.sh
ln -sf "$DOTFILES/claude/hud/hud-detail.sh" ~/.claude/hud/hud-detail.sh
chmod +x "$DOTFILES/claude/hud/pane-hud.sh" "$DOTFILES/claude/hud/hud-detail.sh"

# ── claude settings ─────────────────────────────────
echo "--> linking claude settings..."
mkdir -p ~/.claude
ln -sf "$DOTFILES/claude/settings.json"       ~/.claude/settings.json
ln -sf "$DOTFILES/claude/teammate-sonnet.sh"  ~/.claude/teammate-sonnet.sh
chmod +x "$DOTFILES/claude/teammate-sonnet.sh"

# ── claude skills ───────────────────────────────────
echo "--> linking claude skills..."
mkdir -p ~/.claude/skills/{spawn-team,ralph,debate}
ln -sf "$DOTFILES/claude/skills/spawn-team/SKILL.md"   ~/.claude/skills/spawn-team/SKILL.md
ln -sf "$DOTFILES/claude/skills/spawn-team/prompts.md" ~/.claude/skills/spawn-team/prompts.md
ln -sf "$DOTFILES/claude/skills/ralph/SKILL.md"        ~/.claude/skills/ralph/SKILL.md
ln -sf "$DOTFILES/claude/skills/debate/SKILL.md"       ~/.claude/skills/debate/SKILL.md

# ── bash aliases ────────────────────────────────────
echo "--> adding bash aliases..."
MARKER="# dotfiles: claude aliases"
if ! grep -q "$MARKER" ~/.bashrc 2>/dev/null; then
  echo "" >> ~/.bashrc
  echo "$MARKER" >> ~/.bashrc
  cat "$DOTFILES/claude/bash_aliases.sh" >> ~/.bashrc
  echo "    → added to ~/.bashrc (source it or re-login)"
fi

# ── fzf ─────────────────────────────────────────────
if ! command -v fzf &>/dev/null && [ ! -f ~/.fzf/bin/fzf ]; then
  echo "--> installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all --no-bash --no-zsh --no-fish
fi

echo ""
echo "✓ done."
echo "  tmux reload : tmux source ~/.config/tmux/tmux.conf"
echo "  bash reload : source ~/.bashrc"
