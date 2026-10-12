# 07. Pierwsze żądanie działa, każde kolejne zwraca 500

Poziom: **trudny**

## Uruchomienie

```bash
# raz, z katalogu głównego ćwiczeń (Redis na localhost:6379, hasło: kurs)
./scripts/start-redis.sh

# aplikacja z tego scenariusza (port 8080)
cd scenarios/07-drugie-zadanie-500
mvn spring-boot:run

# w drugim terminalu, z katalogu głównego: automatyczne sprawdzenie
./scenarios/07-drugie-zadanie-500/check.sh
```

## Zgłoszenie

Żeby wpisy w cache dało się czytać w redis-cli, przestawiliśmy serializację wartości na JSON (`CacheConfig`). Teraz dzieje się coś dziwnego: pierwsze żądanie o produkt działa, każde kolejne o ten sam produkt zwraca 500. Po `FLUSHALL` znowu działa dokładnie jedno żądanie.

```bash
curl -i http://localhost:8080/api/products/1
curl -i http://localhost:8080/api/products/1
./scripts/redis-cli.sh GET products::1
```

**Oczekiwane:** wszystkie żądania zwracają produkt, kolejne idą z cache, a wartość w Redisie jest czytelnym JSON-em.

**Pytanie dodatkowe:** skąd serializer ma wiedzieć, na jaki typ zamienić JSON przy odczycie? Jakie są możliwe rozwiązania i czym się różnią?

## Kiedy skończysz

`check.sh` ma wypisać `WYNIK: wszystkie sprawdzenia przeszły`. Omówienie rozwiązania przedstawi prowadzący po zajęciach.
