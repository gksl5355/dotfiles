# dotfiles

gksl5355의 개발환경 설정 모음.

## 구성

```
dotfiles/
├── tmux/
│   ├── tmux.conf          # oh-my-tmux base symlink용
│   └── tmux.conf.local    # Tokyo Night 테마 + HUD 설정
├── claude/
│   └── hud/
│       ├── team-hud.mjs   # Claude Code 팀 에이전트 상태 (status bar)
│       ├── pane-hud.sh    # tmux pane 프로세스 + listening 포트 (status bar)
│       └── hud-detail.sh  # 인터랙티브 팝업 HUD (fzf)
├── install.sh             # 자동 설치 스크립트
└── README.md
```

## 빠른 설치

```bash
git clone https://github.com/gksl5355/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash install.sh
```

## tmux 테마

Tokyo Night 기반 커스텀 테마.

- status bar 상단 고정
- 좌측: `session | uptime | loadavg + pane 프로세스 현황`
- 우측: `팀 에이전트 HUD (활성시) | 시간/날짜 | user@host`
- status bar 클릭 or `prefix + h` → 인터랙티브 팝업

## HUD 팝업 기능

status bar 클릭하면 fzf 기반 팝업 오픈:

- **서버 선택** → curl 헬스체크 / 브라우저 오픈
- **pane 선택** → 해당 pane으로 이동
- **Esc** → 닫기

## 의존성

- [oh-my-tmux](https://github.com/gpakosz/.tmux)
- fzf (install.sh가 자동 설치)
- node.js (team-hud.mjs용)
- python3 (pane-hud 포트 스캔용)
