# dotfiles

gksl5355의 WSL2 개발환경 설정.

---

## 구성 파일

```
tmux/
  tmux.conf.local       # 핵심 — oh-my-tmux 커스텀 설정 (Tokyo Night 테마 + HUD)
  tmux.conf.extra       # 부가 — clipboard/terminal 설정 (~/.tmux.conf 용)

claude/
  settings.json         # Claude Code 설정 (모델, 권한, 팀 에이전트)
  teammate-sonnet.sh    # 팀 에이전트 모델 강제 래퍼
  bash_aliases.sh       # cc / ccn / cca / ccs 단축 명령
  hud/
    team-hud.mjs        # status bar — 팀 에이전트 상태
    pane-hud.sh         # status bar — pane 프로세스 + listening 포트
    hud-detail.sh       # prefix+h 팝업 — fzf 인터랙티브 HUD
  skills/
    spawn-team/         # 팀 병렬 개발 스킬
    ralph/              # PRD 루프 스킬
    debate/             # 아키텍처 리뷰 스킬
```

---

## 새 PC 세팅 순서

### 1. oh-my-tmux 설치 (필수 전제조건)

```bash
git clone https://github.com/gpakosz/.tmux.git ~/.local/share/tmux/oh-my-tmux
mkdir -p ~/.config/tmux
ln -sf ~/.local/share/tmux/oh-my-tmux/.tmux.conf ~/.config/tmux/tmux.conf
```

### 2. dotfiles clone

```bash
git clone https://github.com/gksl5355/dotfiles.git ~/dotfiles
```

### 3. tmux 설정

```bash
# 핵심 파일 — oh-my-tmux 커스텀 (테마/HUD/단축키)
ln -sf ~/dotfiles/tmux/tmux.conf.local ~/.config/tmux/tmux.conf.local

# clipboard/terminal 부가 설정
cp ~/dotfiles/tmux/tmux.conf.extra ~/.tmux.conf
```

### 4. Claude Code HUD

```bash
mkdir -p ~/.claude/hud
ln -sf ~/dotfiles/claude/hud/team-hud.mjs  ~/.claude/hud/team-hud.mjs
ln -sf ~/dotfiles/claude/hud/pane-hud.sh   ~/.claude/hud/pane-hud.sh
ln -sf ~/dotfiles/claude/hud/hud-detail.sh ~/.claude/hud/hud-detail.sh
chmod +x ~/dotfiles/claude/hud/*.sh
```

fzf 없으면 설치:
```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all --no-bash --no-zsh --no-fish
```

### 5. Claude Code 설정

```bash
cp ~/dotfiles/claude/settings.json ~/.claude/settings.json
cp ~/dotfiles/claude/teammate-sonnet.sh ~/.claude/teammate-sonnet.sh
chmod +x ~/.claude/teammate-sonnet.sh

mkdir -p ~/.claude/skills
cp -r ~/dotfiles/claude/skills/* ~/.claude/skills/
```

### 6. bash aliases

```bash
cat ~/dotfiles/claude/bash_aliases.sh >> ~/.bashrc
source ~/.bashrc
```

### 7. tmux 리로드

```bash
tmux source ~/.config/tmux/tmux.conf
```

---

## 세팅 상세

→ [SETUP.md](./SETUP.md) 참고
