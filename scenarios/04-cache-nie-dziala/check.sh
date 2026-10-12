#!/usr/bin/env bash
# Scenariusz 04-cache-nie-dziala: Cache nie działa, każde żądanie trwa sekundę
# Uruchom: najpierw scripts/start-redis.sh, potem aplikację z tego katalogu (mvn spring-boot:run), potem ./check.sh
source "$(dirname "$0")/../../scripts/lib.sh"
echo "Scenariusz 04-cache-nie-dziala: Cache nie działa, każde żądanie trwa sekundę"
require_redis
require_app
reset_redis
expect_body "Produkt 1 się wyświetla" '"name":"Klawiatura mechaniczna"' "$APP/api/products/1"
expect_fast "Drugie żądanie o produkt 1 idzie z cache" 400 "$APP/api/products/1"
expect_body "Szczegóły produktu 2 się wyświetlają" '"availability":"dostępny"' "$APP/api/products/2/details"
expect_fast "Drugie żądanie o szczegóły produktu 2 jest szybkie" 400 "$APP/api/products/2/details"
summary
