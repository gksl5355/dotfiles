#!/bin/bash
# Wrapper for team agents: strips any --model flag appended by the system,
# then forces claude-sonnet-4-6.
args=()
skip_next=false
for arg in "$@"; do
    if $skip_next; then
        skip_next=false
        continue
    fi
    if [[ "$arg" == "--model" ]]; then
        skip_next=true
        continue
    fi
    if [[ "$arg" == --model=* ]]; then
        continue
    fi
    args+=("$arg")
done
exec claude "${args[@]}" --model claude-sonnet-4-6
