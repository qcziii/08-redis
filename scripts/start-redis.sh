#!/usr/bin/env bash
# Startuje Redisa z docker-compose.yml (localhost:6379, hasło "kurs") i czeka, aż odpowie.
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
docker compose up -d
for i in $(seq 1 30); do
  if docker compose exec -T redis redis-cli -a kurs --no-auth-warning PING 2>/dev/null | grep -q PONG; then
    echo "Redis działa: localhost:6379, hasło: kurs"
    exit 0
  fi
  sleep 1
done
echo "Redis nie odpowiada po 30 s. Sprawdź: docker compose logs redis"
echo "Jeśli port 6379 jest zajęty, zobacz sekcję 'Port 6379 zajęty' w README."
exit 1
