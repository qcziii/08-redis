# 12. Wyszukiwanie koszyków użytkownika zwraca pustą listę

Poziom: **średni**

## Uruchomienie

```bash
# raz, z katalogu głównego ćwiczeń (Redis na localhost:6379, hasło: kurs)
./scripts/start-redis.sh

# aplikacja z tego scenariusza (port 8080)
cd scenarios/12-wyszukiwanie-koszykow
mvn spring-boot:run

# w drugim terminalu, z katalogu głównego: automatyczne sprawdzenie
./scenarios/12-wyszukiwanie-koszykow/check.sh
```

## Zgłoszenie

Koszyki trzymamy w Redisie przez repozytorium Spring Data (`@RedisHash`). Zapis i odczyt po id działają, ale lista koszyków użytkownika jest zawsze pusta, choć w Redisie widać hashe z poprawnym `userId`.

```bash
curl -X POST 'http://localhost:8080/api/carts?user=anna&item=klawiatura&item=mysz'
# {"id":"8c1f...","userId":"anna","items":["klawiatura","mysz"]}
curl http://localhost:8080/api/carts/8c1f...
curl 'http://localhost:8080/api/carts?user=anna'
# []
./scripts/redis-cli.sh KEYS 'carts*'
./scripts/redis-cli.sh HGETALL carts:8c1f...
```

**Oczekiwane:** `GET /api/carts?user=anna` zwraca koszyki Anny.

**Pytanie dodatkowe:** Redis nie ma zapytań typu `WHERE userId = 'anna'`. Jak w takim razie Spring Data znajduje koszyki po `userId`? Jakie klucze pojawiły się w Redisie po naprawie i co zawierają?

## Kiedy skończysz

`check.sh` ma wypisać `WYNIK: wszystkie sprawdzenia przeszły`. Omówienie rozwiązania przedstawi prowadzący po zajęciach.
