#!/usr/bin/env bash
# Starts Redis from docker-compose.yml (localhost:6379, password "kurs") and waits until it answers.
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT" || exit 1

if ! docker info > /dev/null 2>&1; then
  echo "Docker nie odpowiada. Uruchom Docker Desktop, poczekaj, aż wystartuje, i uruchom ten skrypt ponownie."
  exit 1
fi

# Port 6379 may already be published by another container, most often egzamin-redis
# from the exam repo (same port, same password). Two containers cannot share it.
for name in $(docker ps --filter publish=6379 --format '{{.Names}}'); do
  [ "$name" = "kurs-redis" ] && continue
  if [ "$name" = "egzamin-redis" ]; then
    echo "Port 6379 zajmuje Redis z repo egzaminu (kontener egzamin-redis). Zatrzymuję go."
    docker stop egzamin-redis > /dev/null || exit 1
  else
    echo "Port 6379 zajmuje inny kontener: $name"
    echo "Zatrzymaj go (docker stop $name) i uruchom ten skrypt ponownie."
    exit 1
  fi
done

if ! out=$(docker compose up -d 2>&1); then
  echo "$out"
  echo
  echo "docker compose up -d nie powiódł się."
  if echo "$out" | grep -qiE 'port is already allocated|address already in use|only one usage|forbidden by its access permissions'; then
    echo "Port 6379 jest zajęty albo zablokowany przez Windows. Zobacz sekcję 'Port 6379 zajęty' w README."
  fi
  exit 1
fi

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
