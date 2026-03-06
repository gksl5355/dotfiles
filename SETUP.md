# 개발환경 전체 세팅 가이드

> gksl5355의 WSL2 기반 Claude Code + tmux 개발환경

---

## 전체 구성 개요

```
OS:       Ubuntu on WSL2 (Windows 11)
Shell:    bash
Terminal: Windows Terminal
Tmux:     oh-my-tmux + Tokyo Night 커스텀 테마
AI:       Claude Code (claude-sonnet-4-6)
```

---

## 1. tmux 세팅

### oh-my-tmux 설치

```bash
git clone https://github.com/gpakosz/.tmux.git ~/.local/share/tmux/oh-my-tmux
mkdir -p ~/.config/tmux
ln -sf ~/.local/share/tmux/oh-my-tmux/.tmux.conf ~/.config/tmux/tmux.conf
```

### 테마: Tokyo Night

`tmux/tmux.conf.local` 파일을 `~/.config/tmux/tmux.conf.local`로 링크.

**색상 팔레트:**

| 변수 | 색상 | 용도 |
|------|------|------|
| colour_1 | `#1a1b26` | 메인 배경 |
| colour_2 | `#414868` | 비활성 보더 |
| colour_3 | `#9aa5ce` | 비활성 탭 텍스트 |
| colour_4 | `#7aa2f7` | 활성 보더/탭 (iris blue) |
| colour_5 | `#e0af68` | 하이라이트 (gold) |
| colour_9 | `#7aa2f7` | 좌측 섹션1 bg (session) |
| colour_10 | `#9ece6a` | 좌측 섹션2 bg (uptime, pine green) |
| colour_11 | `#24283b` | 좌측 섹션3 bg (loadavg) |
| colour_16 | `#bb9af7` | 우측 섹션2 bg (시간, purple) |
| colour_17 | `#7aa2f7` | 우측 섹션3 bg (user@host) |

**Status bar 레이아웃:**

```
좌측: [ ❐ session ] > [ ↑ uptime ] > [ ≈ loadavg  pane프로세스 ]
우측: [ 팀HUD(활성시) ] > [ %H:%M · %d %b ] > [ user @ host ]
```

**주요 설정:**

```
status-position top          # 상단 고정
status-interval 5            # 5초 갱신
mouse on                     # 마우스 지원
history-limit 50000
```

**HUD 단축키:**

| 키 | 동작 |
|----|------|
| status bar 클릭 | 인터랙티브 HUD 팝업 |
| `prefix + h` | 인터랙티브 HUD 팝업 |
| `prefix + m` | 마우스 모드 토글 |

---

## 2. Claude Code 세팅

### settings.json 주요 설정

```json
{
  "model": "sonnet",
  "effortLevel": "high",
  "language": "Korean",
  "teammateMode": "tmux",
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1",
    "CLAUDE_CODE_SUBAGENT_MODEL": "haiku",
    "CLAUDE_CODE_TEAMMATE_COMMAND": "~/.claude/teammate-sonnet.sh"
  }
}
```

- 팀 에이전트: Leader(Sonnet) + Subagents(Haiku) 구조
- 언어: 한국어 응답
- 팀 에이전트는 tmux 새 pane에서 실행

### teammate-sonnet.sh

팀 에이전트가 항상 sonnet 모델로 강제 실행되도록 `--model` 플래그를 오버라이드하는 래퍼.

### 스킬 (Skills)

| 스킬 | 기능 |
|------|------|
| `spawn-team` | 프로젝트 분석 후 최적 팀 구성 및 병렬 개발 |
| `ralph` | PRD 기반 persistence 루프 (완료까지 반복) |
| `debate` | 아키텍처 리뷰 (적대적 방식) |
| `andrej-karpathy-skills` | 코딩 가이드라인 (과도한 추상화 방지 등) |

### 권한 설정 (permissions.allow)

```
Bash(*), Read(*), Edit(*), Write(*), Glob(*), Grep(*)
WebFetch(*), WebSearch(*)
Skill(spawn-team), Skill(debate)
mcp__pencil
```

---

## 3. HUD 시스템

`~/.claude/hud/` 에 위치.

### team-hud.mjs
tmux status bar 좌측 statusline용. Claude Code 팀 에이전트 활성 시 표시:
```
❐ teamname · 3/10 (30%) · ▶ 2 · ⚡4 agents
```
팀 없을 때: 빈 문자열 출력.

### pane-hud.sh
tmux status bar 좌측 섹션3용. 실시간 프로세스 + 서버 현황:
```
claude×2 · bash×1 · srv:3000,5173,8000
```
- 1024~40000 포트 중 listening 포트 표시
- 5개 이상이면 `srv×N` 으로 축약

### hud-detail.sh (인터랙티브)
status bar 클릭 또는 `prefix + h`로 fzf 팝업:
- **서버 선택** → `curl` 헬스체크 or `wslview`로 브라우저 오픈
- **pane 선택** → 해당 pane으로 이동
- **Esc** → 닫기

의존성: `fzf` (`~/.fzf/bin/fzf`)

---

## 4. bash aliases (Claude Code 관련)

```bash
alias cc='tmux attach -t claude-session 2>/dev/null || tmux new-session -s claude-session "claude"'
alias ccn='tmux new-session -s "claude-$(date +%Y%m%d-%H%M%S)" "claude"'
alias ccl='tmux ls'
cca() { tmux attach -t "$1"; }
ccs() { tmux attach -t "$1" 2>/dev/null || tmux new-session -s "$1" "claude"; }
```

---

## 5. 빠른 설치

```bash
git clone https://github.com/gksl5355/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash install.sh
```

`install.sh`가 처리하는 것:
1. oh-my-tmux 설치 (없을 때)
2. tmux 설정 심볼릭 링크
3. HUD 스크립트 링크
4. fzf 설치 (없을 때)
