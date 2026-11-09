#!/usr/bin/env bash
# redis-cli run in the container, with the password. Examples:
#   ./scripts/redis-cli.sh                  # interactive mode
#   ./scripts/redis-cli.sh KEYS '*'         # single command (put the asterisk in single quotes!)
#   ./scripts/redis-cli.sh MONITOR          # live view of all commands (Ctrl+C stops it)
# Git Bash on Windows: do not turn arguments starting with / into paths C:/Program Files/Git/...
export MSYS_NO_PATHCONV=1
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT" || exit 1
if [ $# -eq 0 ] && [ -t 0 ]; then
  # Interactive mode needs a terminal. Older Git Bash (mintty) needs winpty for that.
  case "$(uname -s)" in
    MINGW*|MSYS*) command -v winpty >/dev/null && exec winpty docker compose exec redis redis-cli -a kurs --no-auth-warning ;;
  esac
  exec docker compose exec redis redis-cli -a kurs --no-auth-warning
fi
exec docker compose exec -T redis redis-cli -a kurs --no-auth-warning "$@"
