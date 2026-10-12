# 14. Gdy Redis się zawiesił, cały sklep przestał działać

Poziom: **trudny**

## Uruchomienie

```bash
# raz, z katalogu głównego ćwiczeń (Redis na localhost:6379, hasło: kurs)
./scripts/start-redis.sh

# aplikacja z tego scenariusza (port 8080)
cd scenarios/14-redis-padl
mvn spring-boot:run

# w drugim terminalu, z katalogu głównego: automatyczne sprawdzenie
./scenarios/14-redis-padl/check.sh
```

## Zgłoszenie

W nocy Redis (używany wyłącznie jako cache produktów) się zawiesił: proces działał, ale nie odpowiadał. Przez ten czas każde żądanie o produkt wisiało ok. minuty i kończyło się 500. Cache ma przyspieszać sklep, a nie go wyłączać.

Zawieszenie Redisa zasymulujesz tak:
```bash
docker compose pause redis      # Redis przestaje odpowiadać, ale połączenia zostają otwarte
curl -i -w '\nczas: %{time_total}s\n' http://localhost:8080/api/products/2
docker compose unpause redis    # koniecznie odwieś Redisa po teście!
```

**Oczekiwane:** gdy Redis nie odpowiada, produkt wyświetla się prosto z bazy w mniej niż 4 sekundy (wolniej, ale działa). Gdy Redis wróci, cache znowu działa.

**Wskazówka:** w tym scenariuszu są dwa problemy. Po rozwiązaniu pierwszego objaw się zmieni.

`check.sh` sam wstrzymuje i wznawia Redisa (`docker compose pause/unpause`).

## Kiedy skończysz

`check.sh` ma wypisać `WYNIK: wszystkie sprawdzenia przeszły`. Omówienie rozwiązania przedstawi prowadzący po zajęciach.
