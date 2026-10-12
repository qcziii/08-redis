# 05. Cache ustawiony na 10 minut, a żądania dalej są wolne

Poziom: **średni**

## Uruchomienie

```bash
# raz, z katalogu głównego ćwiczeń (Redis na localhost:6379, hasło: kurs)
./scripts/start-redis.sh

# aplikacja z tego scenariusza (port 8080)
cd scenarios/05-ttl-cache
mvn spring-boot:run

# w drugim terminalu, z katalogu głównego: automatyczne sprawdzenie
./scenarios/05-ttl-cache/check.sh
```

## Zgłoszenie

Ustawiliśmy cache produktów w Redisie z czasem życia 10 minut (`spring.cache.redis.time-to-live`). Aplikacja działa, nie ma błędów w logach, ale prawie każde żądanie trwa ok. 1 s, jakby cache nie istniał. W Redisie zwykle nic nie ma:

```bash
curl -w '\nczas: %{time_total}s\n' http://localhost:8080/api/products/1
curl -w '\nczas: %{time_total}s\n' http://localhost:8080/api/products/1
./scripts/redis-cli.sh KEYS '*'
```

**Oczekiwane:** wpisy w cache żyją 10 minut, drugie żądanie o ten sam produkt jest szybkie.

**Pytanie dodatkowe:** jaka jest różnica między komendami `TTL` i `PTTL`? Którą lepiej zobaczyć ten problem?

## Kiedy skończysz

`check.sh` ma wypisać `WYNIK: wszystkie sprawdzenia przeszły`. Omówienie rozwiązania przedstawi prowadzący po zajęciach.
