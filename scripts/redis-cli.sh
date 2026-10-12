#!/usr/bin/env bash
# redis-cli uruchamiany w kontenerze, z hasłem. Przykłady:
#   ./scripts/redis-cli.sh                  # tryb interaktywny
#   ./scripts/redis-cli.sh KEYS '*'         # pojedyncza komenda (gwiazdkę bierz w apostrofy!)
#   ./scripts/redis-cli.sh MONITOR          # podgląd wszystkich komend na żywo (Ctrl+C kończy)
# Git Bash na Windows: nie zamieniaj argumentów zaczynających się od / na ścieżki C:/Program Files/Git/...
export MSYS_NO_PATHCONV=1
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT" || exit 1
if [ $# -eq 0 ] && [ -t 0 ]; then
  # Tryb interaktywny potrzebuje terminala. Starszy Git Bash (mintty) wymaga do tego winpty.
  case "$(uname -s)" in
    MINGW*|MSYS*) command -v winpty >/dev/null && exec winpty docker compose exec redis redis-cli -a kurs --no-auth-warning ;;
  esac
  exec docker compose exec redis redis-cli -a kurs --no-auth-warning
fi
exec docker compose exec -T redis redis-cli -a kurs --no-auth-warning "$@"
