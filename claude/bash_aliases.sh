alias cc='tmux attach -t claude-session 2>/dev/null || tmux new-session -s claude-session "claude"'
alias ccn='tmux new-session -s "claude-$(date +%Y%m%d-%H%M%S)" "claude"'
alias ccl='tmux ls'
# attach only (must exist)
cca() {
  [ -n "$1" ] || { echo "usage: cca <session-name>"; return 1; }
  tmux attach -t "$1"
}
# attach or create (custom name)
ccs() {
  [ -n "$1" ] || { echo "usage: ccs <session-name>"; return 1; }
  tmux attach -t "$1" 2>/dev/null || tmux new-session -s "$1" "claude"
}

