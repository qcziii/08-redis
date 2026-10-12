#!/usr/bin/env bash
# Scenariusz 14-redis-padl: Gdy Redis się zawiesił, cały sklep przestał działać
# Uruchom: najpierw scripts/start-redis.sh, potem aplikację z tego katalogu (mvn spring-boot:run), potem ./check.sh
source "$(dirname "$0")/../../scripts/lib.sh"
echo "Scenariusz 14-redis-padl: Gdy Redis się zawiesił, cały sklep przestał działać"
require_redis
require_app
reset_redis
expect_body "Produkt 1 się wyświetla" '"name":"Klawiatura mechaniczna"' "$APP/api/products/1"
expect_fast "Drugie żądanie o produkt 1 idzie z cache" 400 "$APP/api/products/1"
echo "  ...wstrzymuję Redisa (docker compose pause redis)"
pause_redis
MAX_TIME=10 expect_fast "Produkt 2 przy zawieszonym Redisie wyświetla się w mniej niż 4 s" 4000 "$APP/api/products/2"
MAX_TIME=10 expect_fast "Produkt 1 przy zawieszonym Redisie też" 4000 "$APP/api/products/1"
echo "  ...wznawiam Redisa (docker compose unpause redis)"
unpause_redis
sleep 1
expect_body "Po powrocie Redisa produkt 3 się wyświetla" '"name":"Monitor 27 cali"' "$APP/api/products/3"
expect_fast "Po powrocie Redisa cache znowu działa" 400 "$APP/api/products/3"
summary
