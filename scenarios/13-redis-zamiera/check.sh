#!/usr/bin/env bash
# Scenariusz 13-redis-zamiera: Redis na produkcji regularnie zamiera
# Uruchom: najpierw scripts/start-redis.sh, potem aplikację z tego katalogu (mvn spring-boot:run), potem ./check.sh
source "$(dirname "$0")/../../scripts/lib.sh"
echo "Scenariusz 13-redis-zamiera: Redis na produkcji regularnie zamiera"
require_redis
require_app
reset_redis
echo "  ...zakładam 1500 sesji i 500 innych kluczy"
{ for i in $(seq 1 1500); do echo "SET session:test-$i klient-$i EX 1800"; done
  for i in $(seq 1 500); do echo "SET cart:test-$i x EX 1800"; done; } | rcli > /dev/null
expect_body "Logowanie tworzy sesję" '"user":"anna"' -X POST "$APP/api/sessions?user=anna"
rcli CONFIG RESETSTAT > /dev/null
expect_body "Liczba aktywnych sesji jest poprawna (1501)" '"active":1501' "$APP/api/sessions/active"
STATS=$(rcli INFO commandstats)
if echo "$STATS" | grep -q '^cmdstat_keys:'; then bad "Aplikacja dalej wysyła komendę, która przegląda wszystkie klucze naraz: $(echo "$STATS" | grep '^cmdstat_keys:')"; else ok "Aplikacja nie blokuje Redisa przeglądaniem wszystkich kluczy naraz"; fi
summary
