#!/usr/bin/env bash
# Scenariusz 12-wyszukiwanie-koszykow: Wyszukiwanie koszyków użytkownika zwraca pustą listę
# Uruchom: najpierw scripts/start-redis.sh, potem aplikację z tego katalogu (mvn spring-boot:run), potem ./check.sh
source "$(dirname "$0")/../../scripts/lib.sh"
echo "Scenariusz 12-wyszukiwanie-koszykow: Wyszukiwanie koszyków użytkownika zwraca pustą listę"
require_redis
require_app
reset_redis
USER_ID="ola-$RANDOM"
call -X POST "$APP/api/carts?user=$USER_ID&item=klawiatura&item=mysz"
CART_ID=$(echo "$BODY" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')
if [ -n "$CART_ID" ]; then ok "Koszyk utworzony ($CART_ID)"; else bad "Nie udało się utworzyć koszyka: HTTP $CODE $BODY"; fi
expect_body "Odczyt koszyka po id" "\"userId\":\"$USER_ID\"" "$APP/api/carts/$CART_ID"
expect_body "Lista koszyków użytkownika zawiera nowy koszyk" "\"id\":\"$CART_ID\"" "$APP/api/carts?user=$USER_ID"
expect_body "Inny użytkownik nie widzi tego koszyka" '[]' "$APP/api/carts?user=ktos-inny"
summary
