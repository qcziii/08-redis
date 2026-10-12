#!/usr/bin/env bash
# Scenariusz 10-licznik-gubi-wyswietlenia: Licznik wyświetleń gubi odsłony
# Uruchom: najpierw scripts/start-redis.sh, potem aplikację z tego katalogu (mvn spring-boot:run), potem ./check.sh
source "$(dirname "$0")/../../scripts/lib.sh"
echo "Scenariusz 10-licznik-gubi-wyswietlenia: Licznik wyświetleń gubi odsłony"
require_redis
require_app
reset_redis
expect_body "Pojedyncze wyświetlenie" '"views":1' -X POST "$APP/api/articles/42/views"
rcli DEL views:article:42 > /dev/null
echo "  ...wysyłam 100 wyświetleń, po 10 naraz"
seq 1 100 | xargs -P 10 -I{} curl -s -o /dev/null --max-time 15 -X POST "$APP/api/articles/42/views"
expect_body "Po 100 równoległych wyświetleniach licznik pokazuje 100" '"views":100' "$APP/api/articles/42/views"
summary
