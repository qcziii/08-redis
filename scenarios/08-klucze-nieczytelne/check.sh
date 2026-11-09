#!/usr/bin/env bash
# Check for scenario 08-klucze-nieczytelne (the description is printed below)
# Run: first scripts/start-redis.sh, then the application from this directory (mvn spring-boot:run), then ./check.sh
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
