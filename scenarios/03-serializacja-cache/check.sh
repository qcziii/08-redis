#!/usr/bin/env bash
# Scenariusz 03-serializacja-cache: Po włączeniu cache produkt zwraca 500
# Uruchom: najpierw scripts/start-redis.sh, potem aplikację z tego katalogu (mvn spring-boot:run), potem ./check.sh
source "$(dirname "$0")/../../scripts/lib.sh"
echo "Scenariusz 03-serializacja-cache: Po włączeniu cache produkt zwraca 500"
require_redis
require_app
reset_redis
expect_body "Produkt 1 się wyświetla" '"name":"Klawiatura mechaniczna"' "$APP/api/products/1"
expect_fast "Drugie żądanie o produkt 1 idzie z cache" 400 "$APP/api/products/1"
expect_redis "W Redisie jest wpis cache products::1" 1 EXISTS products::1
summary
