# 08. Wyszukiwarka nie widzi cen zapisanych przez sklep

Poziom: **średni**

## Uruchomienie

```bash
# raz, z katalogu głównego ćwiczeń (Redis na localhost:6379, hasło: kurs)
./scripts/start-redis.sh

# aplikacja z tego scenariusza (port 8080)
cd scenarios/08-klucze-nieczytelne
mvn spring-boot:run

# w drugim terminalu, z katalogu głównego: automatyczne sprawdzenie
./scenarios/08-klucze-nieczytelne/check.sh
```

## Zgłoszenie

Sklep zapisuje aktualne ceny w Redisie pod kluczami `price:{id}`. Zespół wyszukiwarki (Python) czyta je stamtąd i zgłasza, że nasze ceny "nie istnieją". W drugą stronę też nie działa: ceny, które wyszukiwarka wpisuje do Redisa, sklep zwraca jako 404. Sam sklep twierdzi, że zapisuje poprawnie:

```bash
curl -X PUT -H 'Content-Type: text/plain' -d '249.99' http://localhost:8080/api/prices/7
curl http://localhost:8080/api/prices/7
./scripts/redis-cli.sh GET price:7
# (nil)  <- tak to widzi wyszukiwarka

./scripts/redis-cli.sh SET price:8 15.50   # tak zapisuje wyszukiwarka
curl -i http://localhost:8080/api/prices/8
```

**Oczekiwane:** `GET price:7` w redis-cli zwraca `249.99`, a cena wpisana przez wyszukiwarkę jest widoczna w sklepie. Format kluczy i wartości ustaliły oba zespoły, nie zmieniaj go.

**Pytanie dodatkowe:** co zobaczysz po `./scripts/redis-cli.sh KEYS '*'`? Skąd się biorą dziwne znaki przed nazwą klucza?

## Kiedy skończysz

`check.sh` ma wypisać `WYNIK: wszystkie sprawdzenia przeszły`. Omówienie rozwiązania przedstawi prowadzący po zajęciach.
