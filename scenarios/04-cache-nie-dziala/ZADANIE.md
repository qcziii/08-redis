# 04. Cache nie działa, każde żądanie trwa sekundę

Poziom: **średni**

## Uruchomienie

```bash
# raz, z katalogu głównego ćwiczeń (Redis na localhost:6379, hasło: kurs)
./scripts/start-redis.sh

# aplikacja z tego scenariusza (port 8080)
cd scenarios/04-cache-nie-dziala
mvn spring-boot:run

# w drugim terminalu, z katalogu głównego: automatyczne sprawdzenie
./scenarios/04-cache-nie-dziala/check.sh
```

## Zgłoszenie

Mamy `@Cacheable("products")` na pobieraniu produktu, Redis działa, `spring.cache.type: redis` ustawione. Mimo to każde żądanie trwa ok. 1 s, a w Redisie jest pusto. Dotyczy to zarówno samego produktu, jak i strony ze szczegółami:

```bash
curl -w '\nczas: %{time_total}s\n' http://localhost:8080/api/products/1
curl -w '\nczas: %{time_total}s\n' http://localhost:8080/api/products/1/details
./scripts/redis-cli.sh KEYS '*'
```

**Oczekiwane:** drugie i kolejne żądanie o ten sam produkt (i o jego szczegóły) jest szybkie.

**Wskazówka:** w tym scenariuszu są dwa błędy. Po naprawie pierwszego objaw zmieni się tylko częściowo.

## Kiedy skończysz

`check.sh` ma wypisać `WYNIK: wszystkie sprawdzenia przeszły`. Omówienie rozwiązania przedstawi prowadzący po zajęciach.
