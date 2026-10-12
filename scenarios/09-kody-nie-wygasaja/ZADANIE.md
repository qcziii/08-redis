# 09. Kody SMS nie wygasają po 5 minutach

Poziom: **średni**

## Uruchomienie

```bash
# raz, z katalogu głównego ćwiczeń (Redis na localhost:6379, hasło: kurs)
./scripts/start-redis.sh

# aplikacja z tego scenariusza (port 8080)
cd scenarios/09-kody-nie-wygasaja
mvn spring-boot:run

# w drugim terminalu, z katalogu głównego: automatyczne sprawdzenie
./scenarios/09-kody-nie-wygasaja/check.sh
```

## Zgłoszenie

Logowanie kodem SMS: kod jest ważny 5 minut. Dział bezpieczeństwa znalazł w logach logowania kodami wygenerowanymi kilka godzin wcześniej. Nie dotyczy to wszystkich: większość kodów wygasa poprawnie. Podejrzenie pada na osoby, które przy logowaniu raz się pomyliły.

W środowisku deweloperskim kod wraca w odpowiedzi, zamiast iść SMS-em:

```bash
curl -X POST http://localhost:8080/api/codes/500100200
# {"phone":"500100200","code":"123456"}
curl -X POST 'http://localhost:8080/api/codes/500100200/verify?code=000000'
curl -X POST 'http://localhost:8080/api/codes/500100200/verify?code=123456'
```

**Oczekiwane:** kod wygasa 5 minut po wygenerowaniu, także po nieudanej próbie. Pomyłka nie przedłuża ważności kodu (nie wolno ustawiać nowych 5 minut przy każdej próbie).

**Pytanie dodatkowe:** jakie komendy Redisa zmieniają, a jakie zachowują TTL klucza? (`SET`, `INCR`, `HSET`, `APPEND`, `RENAME`...)

## Kiedy skończysz

`check.sh` ma wypisać `WYNIK: wszystkie sprawdzenia przeszły`. Omówienie rozwiązania przedstawi prowadzący po zajęciach.
