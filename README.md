# Redis w Spring Boot: warsztat z troubleshootingu

Masz przed sobą 14 aplikacji sklepu, które źle współpracują z Redisem. Każda to osobny projekt z opisem zgłoszenia od użytkownika i testem, który przejdzie dopiero po naprawie. Twoim zadaniem jest znaleźć przyczynę, poprawić konfigurację lub kod i umieć wyjaśnić, **jak** do przyczyny doszedłeś.

## Wymagania

- Java 21
- Maven 3.9+
- Docker z Docker Compose (na Windows: Docker Desktop)
- `bash` i `curl` (na Windows: Git Bash)
- wolne porty 8080 i 6379

**Windows / Git Bash:** Git Bash zamienia argumenty zaczynające się od `/` na ścieżki Windows (`/api` staje się `C:/Program Files/Git/api`). Skrypty z repo są na to odporne. Jeśli uruchamiasz coś ręcznie i widzisz w wyniku `C:/Program Files/Git/...`, poprzedź polecenie `MSYS_NO_PATHCONV=1`. W redis-cli gwiazdkę zawsze bierz w apostrofy: `KEYS '*'`, inaczej bash zamieni ją na listę plików.

Stos: Spring Boot 4.0, Spring Data Redis 4.0 (klient Lettuce), Redis 7.4.

## Architektura

```
klient (curl) ──> aplikacja sklepu :8080 ──> Redis :6379 (docker, hasło: kurs)
```

Redis jest jeden dla wszystkich scenariuszy i działa w kontenerze. Każdy scenariusz to osobna aplikacja sklepu startująca na porcie 8080. W scenariuszach z cache produkty pochodzą z "wolnej bazy danych" (`ProductCatalog`), której każdy odczyt trwa ok. 1 s. Po tym łatwo poznać, czy cache działa.

## Jak pracować

```bash
# 1. Raz na całe zajęcia: uruchom Redisa
./scripts/start-redis.sh

# 2. Uruchom aplikację z wybranego scenariusza
cd scenarios/01-host-z-dockera
mvn spring-boot:run

# 3. W drugim terminalu (z katalogu głównego repo): sprawdź
./scenarios/01-host-z-dockera/check.sh

# Na koniec
./scripts/stop-redis.sh
```

Przeczytaj `ZADANIE.md` w katalogu scenariusza, odtwórz problem curlem, znajdź przyczynę, popraw i uruchom aplikację ponownie. Scenariusz jest rozwiązany, gdy `check.sh` wypisze `WYNIK: wszystkie sprawdzenia przeszły`.

`check.sh` na początku czyści Redisa (`FLUSHALL`), żeby każde sprawdzenie zaczynało od zera.

## Narzędzia

**redis-cli** (działa w kontenerze, hasło jest już podane):
```bash
./scripts/redis-cli.sh                    # tryb interaktywny
./scripts/redis-cli.sh KEYS '*'           # jakie klucze są w Redisie
./scripts/redis-cli.sh GET products::1    # wartość klucza
./scripts/redis-cli.sh TTL products::1    # ile sekund zostało do wygaśnięcia (-1: nigdy, -2: brak klucza)
./scripts/redis-cli.sh MONITOR            # wszystkie komendy wysyłane do Redisa, na żywo (Ctrl+C kończy)
```

`MONITOR` w osobnym terminalu to najlepszy sposób, żeby zobaczyć, co aplikacja **naprawdę** robi z Redisem.

Jeśli `./scripts/redis-cli.sh` bez argumentów nie działa w Twoim terminalu, użyj `docker compose exec redis redis-cli -a kurs` albo zakładki *Exec* kontenera `kurs-redis` w Docker Desktop.

**Actuator** (w każdym scenariuszu):
- `/actuator/health`: czy aplikacja łączy się z Redisem (i jeśli nie, to dlaczego),
- `/actuator/configprops`: z jakimi ustawieniami aplikacja faktycznie wystartowała,
- `/actuator/env`: skąd pochodzą wartości właściwości,
- `/actuator/caches`: jakie cache zna aplikacja.

## Port 6379 zajęty

Jeśli `start-redis.sh` zgłasza zajęty port, na komputerze działa już inny Redis (np. zainstalowany lokalnie albo kontener z innego projektu). Zatrzymaj go albo sprawdź `docker ps`. Na Windows w PowerShellu:

```powershell
Get-NetTCPConnection -LocalPort 6379,8080 -State Listen | Select-Object LocalPort, OwningProcess, @{n='Name';e={(Get-Process -Id $_.OwningProcess).ProcessName}}
```

Jeśli port 8080 jest zajęty, zwykle działa jeszcze aplikacja z poprzedniego scenariusza. Zatrzymaj ją (Ctrl+C w jej terminalu).

## Scenariusze

| # | Zgłoszenie | Poziom |
|---|---|---|
| 01 | Aplikacja nie łączy się z Redisem po przeniesieniu z dockera | łatwy |
| 02 | Po migracji Spring Boota każde żądanie zwraca 500 | łatwy |
| 03 | Po włączeniu cache produkt zwraca 500 | łatwy |
| 04 | Cache nie działa, każde żądanie trwa sekundę | średni |
| 05 | Cache ustawiony na 10 minut, a żądania dalej są wolne | średni |
| 06 | Po zmianie ceny sklep dalej pokazuje starą | średni |
| 07 | Pierwsze żądanie działa, każde kolejne zwraca 500 | trudny |
| 08 | Wyszukiwarka nie widzi cen zapisanych przez sklep | średni |
| 09 | Kody SMS nie wygasają po 5 minutach | średni |
| 10 | Licznik wyświetleń gubi odsłony | średni |
| 11 | Powiadomienia o zamówieniach nie dochodzą | średni |
| 12 | Wyszukiwanie koszyków użytkownika zwraca pustą listę | średni |
| 13 | Redis na produkcji regularnie zamiera | średni |
| 14 | Gdy Redis się zawiesił, cały sklep przestał działać | trudny |

## Zasady

- Nie zmieniaj skryptów, `check.sh`, `docker-compose.yml` ani klas oznaczonych komentarzem "Nie zmieniaj tej klasy". Naprawiasz wyłącznie aplikację w katalogu scenariusza.
- Zanim cokolwiek zmienisz, odpowiedz sobie na pytanie: **czy aplikacja w ogóle rozmawia z Redisem, a jeśli tak, to co dokładnie mu wysyła?** (`MONITOR`)
- Czytaj logi od dołu: najważniejsza jest ostatnia przyczyna (`Caused by:` / `root cause`).
- Przy pracy w repo zrób własną gałąź, żeby łatwo wrócić do zepsutej wersji (`git checkout -- scenarios/NN-...`).

Wszystkie scenariusze buduje naraz `mvn package -DskipTests` w katalogu głównym.
