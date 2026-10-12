#!/usr/bin/env bash
# Scenariusz 08-klucze-nieczytelne: Wyszukiwarka nie widzi cen zapisanych przez sklep
# Uruchom: najpierw scripts/start-redis.sh, potem aplikację z tego katalogu (mvn spring-boot:run), potem ./check.sh
source "$(dirname "$0")/../../scripts/lib.sh"
echo "Scenariusz 08-klucze-nieczytelne: Wyszukiwarka nie widzi cen zapisanych przez sklep"
require_redis
require_app
reset_redis
expect_body "Sklep zapisuje cenę produktu 7" '249.99' -X PUT -H 'Content-Type: text/plain' -d '249.99' "$APP/api/prices/7"
expect_redis "Wyszukiwarka widzi cenę w Redisie (GET price:7)" '249.99' GET price:7
rcli SET price:8 15.50 > /dev/null
expect_body "Sklep widzi cenę wpisaną przez wyszukiwarkę (price:8)" '"price":"15.50"' "$APP/api/prices/8"
summary
