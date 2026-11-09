#!/usr/bin/env bash
# Check for scenario 07-drugie-zadanie-500 (the description is printed below)
# Run: first scripts/start-redis.sh, then the application from this directory (mvn spring-boot:run), then ./check.sh
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
