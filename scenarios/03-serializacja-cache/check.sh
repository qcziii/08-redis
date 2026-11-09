#!/usr/bin/env bash
# Check for scenario 03-serializacja-cache (the description is printed below)
# Run: first scripts/start-redis.sh, then the application from this directory (mvn spring-boot:run), then ./check.sh
source "$(dirname "$0")/../../scripts/lib.sh"
echo "Scenariusz 03-serializacja-cache: Po włączeniu cache produkt zwraca 500"
require_redis
require_app
reset_redis
expect_body "Produkt 1 się wyświetla" '"name":"Klawiatura mechaniczna"' "$APP/api/products/1"
expect_fast "Drugie żądanie o produkt 1 idzie z cache" 400 "$APP/api/products/1"
expect_redis "W Redisie jest wpis cache products::1" 1 EXISTS products::1
summary
