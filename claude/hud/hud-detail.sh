#!/bin/bash

FZF=~/.fzf/bin/fzf
B='\033[38;2;122;162;247m'
G='\033[38;2;158;206;106m'
P='\033[38;2;187;154;247m'
O='\033[38;2;224;175;104m'
D='\033[38;2;86;95;137m'
BOLD='\033[1m'; R='\033[0m'

# ── 포트-프로세스 목록 수집 ──────────────────────────
get_servers() {
python3 - << 'PY'
import os
KNOWN = {
    3000:'node/dev',3001:'node/dev',3002:'node/dev',
    4000:'graphql',4200:'angular',5000:'flask',5173:'vite',
    5432:'postgres',6379:'redis',7474:'neo4j-http',7687:'neo4j-bolt',
    8000:'http-dev',8080:'http-alt',8888:'jupyter',
    9090:'prometheus',9187:'pg-exporter',27017:'mongodb',
}
def get_proc(pid):
    try:
        with open(f'/proc/{pid}/comm') as f: return f.read().strip()
    except: return None
def inode_map():
    m = {}
    for pid in os.listdir('/proc'):
        if not pid.isdigit(): continue
        try:
            for fd in os.listdir(f'/proc/{pid}/fd'):
                try:
                    lnk = os.readlink(f'/proc/{pid}/fd/{fd}')
                    if lnk.startswith('socket:['): m[lnk[8:-1]] = pid
                except: pass
        except: pass
    return m
imap = inode_map()
seen = set()
for tf in ['/proc/net/tcp','/proc/net/tcp6']:
    try:
        with open(tf) as f:
            for line in f.readlines()[1:]:
                p = line.split()
                if p[3] != '0A': continue
                port = int(p[1].split(':')[1], 16)
                if not (1024 < port < 40000) or port in seen: continue
                seen.add(port)
                pid = imap.get(p[9])
                name = get_proc(pid) if pid else None
                if not name: name = KNOWN.get(port, 'unknown')
                print(f'SRV|:{port}|{name}')
    except: pass
PY
}

# ── pane 목록 수집 ───────────────────────────────────
get_panes() {
  tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index}|#{pane_current_command}|#{pane_current_path}' 2>/dev/null \
    | while IFS='|' read -r id cmd path; do
        short=$(echo "$path" | sed "s|$HOME|~|")
        echo "PANE|$id|$cmd|$short"
      done
}

# ── fzf 메뉴 구성 ────────────────────────────────────
build_menu() {
  printf "${B}${BOLD}── SYSTEM HUD ─────────────────────────────────────${R}\n"
  printf "\n"

  printf "${G}${BOLD}  SERVERS${R}\n"
  get_servers | while IFS='|' read -r type port name; do
    printf "  srv  %-10s %s\n" "$port" "$name"
  done

  printf "\n${G}${BOLD}  TMUX PANES${R}\n"
  get_panes | while IFS='|' read -r type id cmd path; do
    printf "  pane %-28s %-12s %s\n" "$id" "$cmd" "$path"
  done

  team=$(node ~/.claude/hud/team-hud.mjs 2>/dev/null)
  if [ -n "$team" ]; then
    printf "\n${P}${BOLD}  TEAM AGENTS${R}\n"
    printf "  %s\n" "$team"
  fi
}

# ── fzf 실행 ─────────────────────────────────────────
selected=$(build_menu | $FZF \
  --ansi \
  --no-sort \
  --header=$'Enter: action  Esc: close\n' \
  --prompt='  > ' \
  --pointer='▶' \
  --color='bg:#1a1b26,bg+:#24283b,fg:#9aa5ce,fg+:#c0caf5,hl:#7aa2f7,hl+:#7aa2f7,prompt:#7aa2f7,pointer:#bb9af7,header:#565f89,border:#414868' \
  --border=rounded \
  --padding=1)

[ -z "$selected" ] && exit 0

# ── 액션 처리 ────────────────────────────────────────
if echo "$selected" | grep -q '^  srv'; then
  port=$(echo "$selected" | awk '{print $2}' | tr -d ':')
  action=$(printf 'curl health check\nopen in browser (wslview)\ncancel' \
    | $FZF --ansi --prompt="  :$port > " \
           --color='bg:#1a1b26,bg+:#24283b,fg:#9aa5ce,fg+:#c0caf5,prompt:#7aa2f7,pointer:#bb9af7,border:#414868' \
           --border=rounded --padding=1 --height=8)
  case "$action" in
    "curl health check")
      curl -s -o /dev/null -w "HTTP %{http_code} (%{time_total}s)\n" "http://localhost:$port" 2>&1
      echo "press any key..."; read -r -s -n1 ;;
    "open in browser"*)
      wslview "http://localhost:$port" 2>/dev/null || echo "wslview not found";;
  esac

elif echo "$selected" | grep -q '^  pane'; then
  pane_id=$(echo "$selected" | awk '{print $2}')
  tmux switch-client -t "$pane_id" 2>/dev/null || tmux select-pane -t "$pane_id" 2>/dev/null
fi
