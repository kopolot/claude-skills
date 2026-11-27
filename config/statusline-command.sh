#!/bin/bash
# Approximation of the Oh My Zsh "candy" theme (single line, no trailing prompt char)
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
[ -z "$cwd" ] && cwd=$(pwd)
case "$cwd" in
  "$HOME") dir="~" ;;
  "$HOME"/*) dir="~${cwd#$HOME}" ;;
  *) dir="$cwd" ;;
esac

user=$(whoami)
host=$(hostname -s)
now=$(date +%H:%M:%S)

out=$(printf '\033[1;32m%s@%s \033[0;34m[%s] \033[0m\033[0;37m[%s]\033[0m' "$user" "$host" "$now" "$dir")

if branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null) || \
   branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null); then
  dirty=""
  if [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null | head -n1)" ]; then
    dirty=$(printf ' \033[0;31m*\033[0;32m')
  fi
  out="$out $(printf '\033[0;32m[%s' "$branch")$dirty$(printf ']\033[0m')"
fi

model=$(echo "$input" | jq -r '.model.display_name // .model.id // empty')
ctx=$(echo "$input" | jq -r '.context_window.used_percentage // empty | if type=="number" then round else . end')
if [ -n "$model" ]; then
  out="$out $(printf '\033[0;35m[%s]\033[0m' "$model")"
fi
effort=$(echo "$input" | jq -r '(.effort.level // .effort) // empty | if type=="string" then . else empty end')
if [ -n "$effort" ]; then
  out="$out $(printf '\033[0;33m[effort: %s]\033[0m' "$effort")"
fi
if [ -n "$ctx" ]; then
  pct=$ctx
  if [ "$pct" -ge 80 ]; then col='0;31'; elif [ "$pct" -ge 50 ]; then col='0;33'; else col='0;36'; fi
  out="$out $(printf '\033[%sm[ctx %s%%]\033[0m' "$col" "$pct")"
fi

# Rate limits (Claude.ai subscribers only; fields absent before the first API response)
color_pct() {
  if [ "$1" -ge 80 ]; then printf '0;31'; elif [ "$1" -ge 50 ]; then printf '0;33'; else printf '0;36'; fi
}
# Time left until a reset (epoch seconds) as "45m", "2h13m" or "3d4h"
fmt_remaining() {
  local left=$(( $1 - $(date +%s) ))
  [ "$left" -lt 0 ] && left=0
  local d=$(( left / 86400 )) h=$(( left % 86400 / 3600 )) m=$(( left % 3600 / 60 ))
  if [ "$d" -gt 0 ]; then printf '%sd%sh' "$d" "$h"
  elif [ "$h" -gt 0 ]; then printf '%sh%02dm' "$h" "$m"
  else printf '%sm' "$m"; fi
}
for spec in "five_hour:5h" "seven_day:7d"; do
  key=${spec%%:*}; label=${spec##*:}
  val=$(echo "$input" | jq -r ".rate_limits.${key}.used_percentage // empty | if type==\"number\" then round else empty end")
  reset=$(echo "$input" | jq -r ".rate_limits.${key}.resets_at // empty | if type==\"number\" then floor else empty end")
  if [ -n "$val" ]; then
    # Show time until reset instead of the window name when the reset time is known
    [ -n "$reset" ] && label=$(fmt_remaining "$reset")
    out="$out $(printf '\033[%sm[%s %s%%]\033[0m' "$(color_pct "$val")" "$label" "$val")"
  fi
done

printf '%s' "$out"
