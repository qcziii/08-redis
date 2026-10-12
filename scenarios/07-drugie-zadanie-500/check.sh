#!/usr/bin/env bash
# Scenariusz 07-drugie-zadanie-500: Pierwsze żądanie działa, każde kolejne zwraca 500
# Uruchom: najpierw scripts/start-redis.sh, potem aplikację z tego katalogu (mvn spring-boot:run), potem ./check.sh
source "$(dirname "$0")/../../scripts/lib.sh"
echo "Scenariusz 07-drugie-zadanie-500: Pierwsze żądanie działa, każde kolejne zwraca 500"
require_redis
require_app
reset_redis
expect_body "Pierwsze żądanie o produkt 1" '"name":"Klawiatura mechaniczna"' "$APP/api/products/1"
expect_body "Drugie żądanie o produkt 1" '"name":"Klawiatura mechaniczna"' "$APP/api/products/1"
expect_fast "Trzecie żądanie o produkt 1 idzie z cache" 400 "$APP/api/products/1"
VALUE=$(rcli GET products::1)
if [[ "$VALUE" == *'"name":"Klawiatura mechaniczna"'* ]]; then ok "Wpis w Redisie jest czytelnym JSON-em"; else bad "Wpis w Redisie nie jest JSON-em z nazwą produktu: ${VALUE:0:200}"; fi
summary
