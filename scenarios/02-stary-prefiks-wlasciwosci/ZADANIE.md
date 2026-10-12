# 02. Po migracji Spring Boota każde żądanie zwraca 500

Poziom: **łatwy**

## Uruchomienie

```bash
# raz, z katalogu głównego ćwiczeń (Redis na localhost:6379, hasło: kurs)
./scripts/start-redis.sh

# aplikacja z tego scenariusza (port 8080)
cd scenarios/02-stary-prefiks-wlasciwosci
mvn spring-boot:run

# w drugim terminalu, z katalogu głównego: automatyczne sprawdzenie
./scenarios/02-stary-prefiks-wlasciwosci/check.sh
```

## Zgłoszenie

Sklep przeniesiony ze Spring Boot 2.7 na 4.0. Kod się kompiluje, aplikacja startuje, ale każde żądanie o produkt zwraca 500. Redis na pewno działa i hasło jest dobre, bo to działa:

```bash
./scripts/redis-cli.sh PING
# PONG
```

```bash
curl -i http://localhost:8080/api/products/1
```

**Oczekiwane:** produkt się wyświetla, a kolejne żądania idą z cache.

**Pytanie dodatkowe:** jak sprawdzić, jakie ustawienia połączenia z Redisem aplikacja **naprawdę** wczytała? (podpowiedź: `/actuator/configprops`)

## Kiedy skończysz

`check.sh` ma wypisać `WYNIK: wszystkie sprawdzenia przeszły`. Omówienie rozwiązania przedstawi prowadzący po zajęciach.
