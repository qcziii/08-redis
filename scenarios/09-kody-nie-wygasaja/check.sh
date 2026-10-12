#!/usr/bin/env bash
# Scenariusz 09-kody-nie-wygasaja: Kody SMS nie wygasają po 5 minutach
# Uruchom: najpierw scripts/start-redis.sh, potem aplikację z tego katalogu (mvn spring-boot:run), potem ./check.sh
source "$(dirname "$0")/../../scripts/lib.sh"
echo "Scenariusz 09-kody-nie-wygasaja: Kody SMS nie wygasają po 5 minutach"
require_redis
require_app
reset_redis
PHONE="5001$((RANDOM % 90000 + 10000))"
call -X POST "$APP/api/codes/$PHONE"
CODE_SMS=$(echo "$BODY" | sed -n 's/.*"code":"\([0-9]*\)".*/\1/p')
if [ -n "$CODE_SMS" ]; then ok "Kod wygenerowany ($CODE_SMS)"; else bad "Nie udało się wygenerować kodu: HTTP $CODE $BODY"; fi
expect_ttl_between "Nowy kod wygasa po 5 minutach" 1 300 "sms-code:$PHONE"
WRONG=$([ "$CODE_SMS" = "000000" ] && echo 111111 || echo 000000)
expect_status "Pomyłka w kodzie" 400 -X POST "$APP/api/codes/$PHONE/verify?code=$WRONG"
expect_ttl_between "Po pomyłce kod dalej wygasa w ciągu 5 minut" 1 300 "sms-code:$PHONE"
rcli EXPIRE "sms-code:$PHONE" 2 > /dev/null
expect_status "Druga pomyłka" 400 -X POST "$APP/api/codes/$PHONE/verify?code=$WRONG"
sleep 3
expect_status "Kod, któremu minął czas, już nie działa" 410 -X POST "$APP/api/codes/$PHONE/verify?code=$CODE_SMS"
call -X POST "$APP/api/codes/$PHONE"
CODE_SMS=$(echo "$BODY" | sed -n 's/.*"code":"\([0-9]*\)".*/\1/p')
expect_body "Świeży kod działa" '"result":"zalogowano"' -X POST "$APP/api/codes/$PHONE/verify?code=$CODE_SMS"
summary
