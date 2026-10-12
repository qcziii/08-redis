#!/usr/bin/env bash
# Wspólne funkcje dla skryptów check.sh w scenariuszach.
# Wymagają bash, curl i dockera (redis-cli działa w kontenerze).

# Git Bash na Windows: nie zamieniaj argumentów zaczynających się od / na ścieżki Windows
export MSYS_NO_PATHCONV=1
APP=${APP:-http://localhost:8080}
LIB_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
PASS=0
FAIL=0
BODY_FILE=$(mktemp)
trap 'rm -f "$BODY_FILE"' EXIT

ok()  { echo "  [OK]   $1"; PASS=$((PASS+1)); }
bad() { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }

# Komenda redis-cli w kontenerze; wynik bez znaków \r.
rcli() { "$LIB_ROOT/scripts/redis-cli.sh" "$@" | tr -d '\r'; }

# Wykonuje żądanie; ustawia CODE, BODY i MS (czas w milisekundach). Argumenty jak dla curl.
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

# Czyści Redisa, żeby każde uruchomienie check.sh zaczynało od zera.
reset_redis() { rcli FLUSHALL > /dev/null; }

# expect_status "opis" 200 <argumenty curl>
expect_status() {
  local desc=$1 expected=$2; shift 2
  call "$@"
  if [ "$CODE" = "$expected" ]; then ok "$desc (HTTP $CODE)"; else bad "$desc: oczekiwano HTTP $expected, jest HTTP $CODE. Body: ${BODY:0:300}"; fi
}

# expect_body "opis" 'fragment' <argumenty curl>  (sprawdza też, że HTTP 2xx)
expect_body() {
  local desc=$1 fragment=$2; shift 2
  call "$@"
  if [[ "$CODE" == 2* ]] && grep -qF -- "$fragment" "$BODY_FILE"; then
    ok "$desc"
  else
    bad "$desc: oczekiwano HTTP 2xx i fragmentu $fragment, jest HTTP $CODE. Body: ${BODY:0:300}"
  fi
}

# expect_fast "opis" 400 <argumenty curl>  (HTTP 2xx w czasie poniżej podanej liczby ms)
expect_fast() {
  local desc=$1 limit=$2; shift 2
  call "$@"
  if [[ "$CODE" == 2* ]] && [ "$MS" -lt "$limit" ]; then
    ok "$desc (${MS} ms)"
  else
    bad "$desc: oczekiwano HTTP 2xx poniżej $limit ms, jest HTTP $CODE po ${MS} ms. Body: ${BODY:0:300}"
  fi
}

# expect_redis "opis" 'oczekiwany wynik' <komenda redis-cli>
expect_redis() {
  local desc=$1 expected=$2; shift 2
  local actual
  actual=$(rcli "$@")
  if [ "$actual" = "$expected" ]; then ok "$desc"; else bad "$desc: redis-cli $* zwraca '${actual:0:200}', oczekiwano '$expected'"; fi
}

# expect_ttl_between "opis" min max klucz  (TTL klucza w sekundach w przedziale [min, max])
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

# Symulacja zawieszonego Redisa: proces działa, połączenia są otwarte, ale nic nie odpowiada.
# Redis zostaje wznowiony także wtedy, gdy check.sh zostanie przerwany (Ctrl+C).
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
