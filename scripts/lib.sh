#!/usr/bin/env bash
# Shared functions for the check.sh scripts in the scenarios.
# They need bash, curl and docker (redis-cli runs in the container).

# Git Bash on Windows: do not turn arguments starting with / into Windows paths
export MSYS_NO_PATHCONV=1
APP=${APP:-http://localhost:8080}
LIB_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
PASS=0
FAIL=0
BODY_FILE=$(mktemp)
trap 'rm -f "$BODY_FILE"' EXIT

ok()  { echo "  [OK]   $1"; PASS=$((PASS+1)); }
bad() { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }

# redis-cli command in the container; output without \r characters.
rcli() { "$LIB_ROOT/scripts/redis-cli.sh" "$@" | tr -d '\r'; }

# Sends a request; sets CODE, BODY and MS (time in milliseconds). Arguments as for curl.
call() {
  local out
  : > "$BODY_FILE"
  out=$(curl -s -o "$BODY_FILE" -w '%{http_code} %{time_total}' --max-time "${MAX_TIME:-15}" "$@")
  CODE=${out% *}
  MS=$(echo "${out#* }" | awk '{printf "%d", $1 * 1000}')
  BODY=$(cat "$BODY_FILE")
}

require_redis() {
  if ! rcli PING 2>/dev/null | grep -q PONG; then
    echo "  [FAIL] Redis nie odpowiada. Uruchom go: ./scripts/start-redis.sh"
    exit 1
  fi
}

require_app() {
  if [ "$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$APP/")" = "000" ]; then
    echo "  [FAIL] Aplikacja nie odpowiada pod $APP. Czy wystartowała? Sprawdź logi aplikacji."
    exit 1
  fi
}

# Flushes Redis so that every check.sh run starts from scratch.
reset_redis() { rcli FLUSHALL > /dev/null; }

# expect_status "description" 200 <curl arguments>
expect_status() {
  local desc=$1 expected=$2; shift 2
  call "$@"
  if [ "$CODE" = "$expected" ]; then ok "$desc (HTTP $CODE)"; else bad "$desc: oczekiwano HTTP $expected, jest HTTP $CODE. Body: ${BODY:0:300}"; fi
}

# expect_body "description" 'fragment' <curl arguments>  (also checks for HTTP 2xx)
expect_body() {
  local desc=$1 fragment=$2; shift 2
  call "$@"
  if [[ "$CODE" == 2* ]] && grep -qF -- "$fragment" "$BODY_FILE"; then
    ok "$desc"
  else
    bad "$desc: oczekiwano HTTP 2xx i fragmentu $fragment, jest HTTP $CODE. Body: ${BODY:0:300}"
  fi
}

# expect_fast "description" 400 <curl arguments>  (HTTP 2xx in less than the given number of ms)
expect_fast() {
  local desc=$1 limit=$2; shift 2
  call "$@"
  if [[ "$CODE" == 2* ]] && [ "$MS" -lt "$limit" ]; then
    ok "$desc (${MS} ms)"
  else
    bad "$desc: oczekiwano HTTP 2xx poniżej $limit ms, jest HTTP $CODE po ${MS} ms. Body: ${BODY:0:300}"
  fi
}

# expect_redis "description" 'expected output' <redis-cli command>
expect_redis() {
  local desc=$1 expected=$2; shift 2
  local actual
  actual=$(rcli "$@")
  if [ "$actual" = "$expected" ]; then ok "$desc"; else bad "$desc: redis-cli $* zwraca '${actual:0:200}', oczekiwano '$expected'"; fi
}

# expect_ttl_between "description" min max key  (key TTL in seconds within [min, max])
expect_ttl_between() {
  local desc=$1 min=$2 max=$3 key=$4
  local ttl
  ttl=$(rcli TTL "$key")
  if [[ "$ttl" =~ ^-?[0-9]+$ ]] && [ "$ttl" -ge "$min" ] && [ "$ttl" -le "$max" ]; then
    ok "$desc (TTL $ttl s)"
  else
    bad "$desc: TTL $key = '$ttl', oczekiwano od $min do $max s (-1: brak wygasania, -2: klucz nie istnieje)"
  fi
}

# Simulates a hung Redis: the process is running, connections are open, but nothing answers.
# Redis is resumed even when check.sh is interrupted (Ctrl+C).
pause_redis() {
  (cd "$LIB_ROOT" && docker compose pause redis > /dev/null 2>&1) || echo "  (nie udało się wstrzymać Redisa: docker compose pause redis)"
  trap 'rm -f "$BODY_FILE"; (cd "$LIB_ROOT" && docker compose unpause redis > /dev/null 2>&1)' EXIT
  trap 'exit 130' INT TERM
}
unpause_redis() {
  (cd "$LIB_ROOT" && docker compose unpause redis > /dev/null 2>&1) || echo "  (nie udało się wznowić Redisa, zrób to ręcznie: docker compose unpause redis)"
  trap 'rm -f "$BODY_FILE"' EXIT
}

summary() {
  echo
  if [ "$FAIL" = 0 ]; then
    echo "WYNIK: wszystkie sprawdzenia przeszły ($PASS). Scenariusz naprawiony!"
    exit 0
  else
    echo "WYNIK: $FAIL nie przeszło, $PASS przeszło. Szukaj dalej."
    exit 1
  fi
}
