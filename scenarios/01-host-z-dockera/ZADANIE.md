# 01. Aplikacja nie łączy się z Redisem po przeniesieniu z dockera

Poziom: **łatwy**

## Uruchomienie

```bash
# raz, z katalogu głównego ćwiczeń (Redis na localhost:6379, hasło: kurs)
./scripts/start-redis.sh

# aplikacja z tego scenariusza (port 8080)
cd scenarios/01-host-z-dockera
mvn spring-boot:run

# w drugim terminalu, z katalogu głównego: automatyczne sprawdzenie
./scenarios/01-host-z-dockera/check.sh
```

## Zgłoszenie

Do tej pory cały zespół uruchamiał sklep w docker compose, razem z Redisem. Przeszedłem na uruchamianie aplikacji z IntelliJ (`mvn spring-boot:run`), a Redisa zostawiłem w dockerze. Aplikacja startuje bez błędów, ale każde żądanie o produkt kończy się 500. U kolegi, który dalej odpala wszystko w dockerze, działa.

```bash
curl -i http://localhost:8080/api/products/1
```

**Oczekiwane:** produkt się wyświetla, a kolejne żądania o ten sam produkt idą z cache (szybko).

**Pytanie dodatkowe:** dlaczego aplikacja wystartowała bez błędu, skoro Redis był nieosiągalny? Co pokazuje `/actuator/health`?

## Kiedy skończysz

`check.sh` ma wypisać `WYNIK: wszystkie sprawdzenia przeszły`. Omówienie rozwiązania przedstawi prowadzący po zajęciach.
