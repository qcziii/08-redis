# 06. Po zmianie ceny sklep dalej pokazuje starą

Poziom: **średni**

## Uruchomienie

```bash
# raz, z katalogu głównego ćwiczeń (Redis na localhost:6379, hasło: kurs)
./scripts/start-redis.sh

# aplikacja z tego scenariusza (port 8080)
cd scenarios/06-stara-cena
mvn spring-boot:run

# w drugim terminalu, z katalogu głównego: automatyczne sprawdzenie
./scenarios/06-stara-cena/check.sh
```

## Zgłoszenie

Dział handlowy zmienia ceny przez `PUT /api/products/{id}/price`. Odpowiedź na PUT zawiera nową cenę, ale klienci przez godzinę widzą na stronie starą. Programista przysięga, że "przecież jest `@CacheEvict`".

```bash
curl http://localhost:8080/api/products/2
curl -X PUT 'http://localhost:8080/api/products/2/price?value=99.00'
curl http://localhost:8080/api/products/2
```

**Oczekiwane:** zaraz po zmianie ceny `GET` zwraca nową cenę. Cache dalej działa (drugi `GET` jest szybki), nie wyłączaj go.

**Pytanie dodatkowe:** czym się różni `@CacheEvict` od `@CachePut`? Które lepiej pasuje tutaj?

## Kiedy skończysz

`check.sh` ma wypisać `WYNIK: wszystkie sprawdzenia przeszły`. Omówienie rozwiązania przedstawi prowadzący po zajęciach.
