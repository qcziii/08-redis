# 13. Redis na produkcji regularnie zamiera

Poziom: **średni**

## Uruchomienie

```bash
# raz, z katalogu głównego ćwiczeń (Redis na localhost:6379, hasło: kurs)
./scripts/start-redis.sh

# aplikacja z tego scenariusza (port 8080)
cd scenarios/13-redis-zamiera
mvn spring-boot:run

# w drugim terminalu, z katalogu głównego: automatyczne sprawdzenie
./scenarios/13-redis-zamiera/check.sh
```

## Zgłoszenie

Zgłoszenie od zespołu utrzymania: na produkcji (ok. 4 mln kluczy) Redis mniej więcej co minutę przestaje odpowiadać na kilkaset milisekund. Wtedy wszystkie serwisy korzystające z Redisa dostają timeouty. W `SLOWLOG` widać jedną komendę, zawsze wysłaną z adresu serwera sklepu. Nie podali, jaką. Znajdź, która część sklepu za to odpowiada, i popraw ją tak, żeby wynik dla użytkownika się nie zmienił.

Lokalnie danych jest mało, więc nic nie zamiera. Komendy, które aplikacja wysyła do Redisa, możesz za to podejrzeć:

```bash
./scripts/redis-cli.sh MONITOR        # w osobnym terminalu, Ctrl+C kończy
./scripts/redis-cli.sh INFO commandstats
./scripts/redis-cli.sh SLOWLOG GET 10
```

Endpointy sklepu korzystające z Redisa: `POST /api/sessions?user=...` (logowanie) i `GET /api/sessions/active` (liczba zalogowanych, odpytywana co minutę przez dashboard obsługi klienta).

**Oczekiwane:** sklep nie wysyła do Redisa komendy, która blokuje go na czas proporcjonalny do liczby **wszystkich** kluczy w bazie. Wyniki endpointów się nie zmieniają.

**Pytanie dodatkowe:** czy Twoje rozwiązanie zwróci poprawny wynik, gdy kluczy będzie więcej niż jedna "porcja" przeglądania? Jakie są inne sposoby liczenia aktywnych sesji, które w ogóle nie wymagają przeglądania kluczy?

## Kiedy skończysz

`check.sh` ma wypisać `WYNIK: wszystkie sprawdzenia przeszły`. Omówienie rozwiązania przedstawi prowadzący po zajęciach.
