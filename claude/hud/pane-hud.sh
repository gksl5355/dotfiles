#!/bin/bash
# tmux 전체 pane 프로세스 + 실행중인 서버 포트 출력

# 1) pane 프로세스 현황
proc=$(tmux list-panes -a -F '#{pane_current_command}' 2>/dev/null \
  | grep -v '^$' \
  | grep -v '^[0-9]' \
  | sort | uniq -c | sort -rn \
  | head -5 \
  | awk '{name=$2; if(length(name)>10) name=substr(name,1,10); printf "%s×%d\n", name, $1}' \
  | paste -sd ' · ')

# 2) listening 포트 (1024~40000, 임시포트 제외)
ports=$(ss -tlnp 2>/dev/null \
  | awk '/LISTEN/ {match($4, /:([0-9]+)$/, m); p=m[1]+0; if(p>1024 && p<40000) print p}' \
  | sort -n | uniq)

port_count=$(echo "$ports" | grep -c '[0-9]' 2>/dev/null || echo 0)

if [ "$port_count" -gt 0 ]; then
  if [ "$port_count" -le 5 ]; then
    srv=$(echo "$ports" | paste -sd ',')
    srv_str="srv:${srv}"
  else
    srv_str="srv×${port_count}"
  fi
fi

# 조합 출력
parts=()
[ -n "$proc" ]    && parts+=("$proc")
[ -n "$srv_str" ] && parts+=("$srv_str")

if [ ${#parts[@]} -gt 0 ]; then
  printf '%s' "$(IFS=' · '; echo "${parts[*]}")"
fi
