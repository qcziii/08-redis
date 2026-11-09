#!/usr/bin/env bash
# Check for scenario 11-powiadomienia-pubsub (the description is printed below)
# Run: first scripts/start-redis.sh, then the application from this directory (mvn spring-boot:run), then ./check.sh
source "$(dirname "$0")/../../scripts/lib.sh"
echo "Scenariusz 11-powiadomienia-pubsub: Powiadomienia o zamówieniach nie dochodzą"
require_redis
require_app
reset_redis
call -X POST "$APP/api/orders"
ORDER=$(echo "$BODY" | sed -n 's/.*"orderId":"\([^"]*\)".*/\1/p')
if [ -n "$ORDER" ]; then ok "Zamówienie utworzone ($ORDER)"; else bad "Nie udało się utworzyć zamówienia: HTTP $CODE $BODY"; fi
sleep 1
expect_body "Przyszło powiadomienie o utworzeniu" "orders:created $ORDER" "$APP/api/notifications"
expect_body "Anulowanie zamówienia" '"status":"anulowane"' -X POST "$APP/api/orders/$ORDER/cancel"
sleep 1
expect_body "Przyszło powiadomienie o anulowaniu" "orders:cancelled $ORDER" "$APP/api/notifications"
rcli PUBLISH orders:shipped "$ORDER" > /dev/null
sleep 1
expect_body "Nowy typ zdarzenia (orders:shipped) też dociera" "orders:shipped $ORDER" "$APP/api/notifications"
summary
