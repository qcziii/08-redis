# 03. Po włączeniu cache produkt zwraca 500

Poziom: **łatwy**

## Uruchomienie

```bash
# raz, z katalogu głównego ćwiczeń (Redis na localhost:6379, hasło: kurs)
./scripts/start-redis.sh

# aplikacja z tego scenariusza (port 8080)
cd scenarios/03-serializacja-cache
mvn spring-boot:run

# w drugim terminalu, z katalogu głównego: automatyczne sprawdzenie
./scenarios/03-serializacja-cache/check.sh
```

## Zgłoszenie

Strona produktu ładowała się ok. 1 s, więc dodaliśmy cache w Redisie: `@EnableCaching`, `@Cacheable("products")` i `spring.cache.type: redis`. Od tej pory endpoint produktu zawsze zwraca 500. W Redisie nic się nie pojawia:

```bash
curl -i http://localhost:8080/api/products/1
./scripts/redis-cli.sh KEYS '*'
```

**Oczekiwane:** produkt się wyświetla, a kolejne żądania idą z cache.

**Pytanie dodatkowe:** w jakim formacie Spring domyślnie zapisuje wartości w cache Redisa? Zajrzyj do wpisu w Redisie po naprawie (`./scripts/redis-cli.sh GET products::1`).

## Kiedy skończysz

`check.sh` ma wypisać `WYNIK: wszystkie sprawdzenia przeszły`. Omówienie rozwiązania przedstawi prowadzący po zajęciach.
