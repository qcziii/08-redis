# 10. Licznik wyświetleń gubi odsłony

Poziom: **średni**

## Uruchomienie

```bash
# raz, z katalogu głównego ćwiczeń (Redis na localhost:6379, hasło: kurs)
./scripts/start-redis.sh

# aplikacja z tego scenariusza (port 8080)
cd scenarios/10-licznik-gubi-wyswietlenia
mvn spring-boot:run

# w drugim terminalu, z katalogu głównego: automatyczne sprawdzenie
./scenarios/10-licznik-gubi-wyswietlenia/check.sh
```

## Zgłoszenie

Marketing porównał nasz licznik wyświetleń artykułów z Google Analytics. Przy małym ruchu wszystko się zgadza, ale gdy artykuł trafia na stronę główną, licznik pokazuje kilka razy mniej odsłon, niż było naprawdę. W logach nie ma żadnych błędów.

Pojedyncze wyświetlenie:
```bash
curl -X POST http://localhost:8080/api/articles/42/views
```

Duży ruch (100 wyświetleń, 10 naraz):
```bash
./scripts/redis-cli.sh DEL views:article:42
seq 1 100 | xargs -P 10 -I{} curl -s -o /dev/null -X POST http://localhost:8080/api/articles/42/views
curl http://localhost:8080/api/articles/42/views
```

**Oczekiwane:** po 100 równoległych wyświetleniach licznik pokazuje dokładnie 100. Zapis do audytu (`AuditLog`) musi zostać.

**Pytanie dodatkowe:** czy dodanie `synchronized` do metody rozwiązałoby problem, gdy sklep działa na trzech serwerach naraz?

## Kiedy skończysz

`check.sh` ma wypisać `WYNIK: wszystkie sprawdzenia przeszły`. Omówienie rozwiązania przedstawi prowadzący po zajęciach.
