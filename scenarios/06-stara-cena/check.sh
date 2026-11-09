#!/usr/bin/env bash
# Check for scenario 06-stara-cena (the description is printed below)
# Run: first scripts/start-redis.sh, then the application from this directory (mvn spring-boot:run), then ./check.sh
source "$(dirname "$0")/../../scripts/lib.sh"
echo "Scenariusz 06-stara-cena: Po zmianie ceny sklep dalej pokazuje starą"
require_redis
require_app
reset_redis
PRICE="$((RANDOM % 900 + 100)).00"
expect_body "Produkt 2 się wyświetla" '"name":"Mysz bezprzewodowa"' "$APP/api/products/2"
expect_fast "Drugie żądanie o produkt 2 idzie z cache" 400 "$APP/api/products/2"
expect_body "Zmiana ceny na $PRICE" "\"price\":$PRICE" -X PUT "$APP/api/products/2/price?value=$PRICE"
expect_body "Po zmianie GET zwraca nową cenę $PRICE" "\"price\":$PRICE" "$APP/api/products/2"
expect_fast "Kolejny GET znowu idzie z cache" 400 "$APP/api/products/2"
summary
