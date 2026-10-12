# 11. Powiadomienia o zamówieniach nie dochodzą

Poziom: **średni**

## Uruchomienie

```bash
# raz, z katalogu głównego ćwiczeń (Redis na localhost:6379, hasło: kurs)
./scripts/start-redis.sh

# aplikacja z tego scenariusza (port 8080)
cd scenarios/11-powiadomienia-pubsub
mvn spring-boot:run

# w drugim terminalu, z katalogu głównego: automatyczne sprawdzenie
./scenarios/11-powiadomienia-pubsub/check.sh
```

## Zgłoszenie

Po złożeniu lub anulowaniu zamówienia sklep publikuje zdarzenie w Redisie (pub/sub), a `OrderEventsListener` ma na tej podstawie wysłać powiadomienie. Zamówienia się tworzą, ale żadne powiadomienie nie wychodzi. W logach nie ma błędów, listener po prostu nic nie dostaje.

```bash
curl -X POST http://localhost:8080/api/orders
# {"orderId":"3f2a9c1b","status":"utworzone"}
curl -X POST http://localhost:8080/api/orders/3f2a9c1b/cancel
curl http://localhost:8080/api/notifications
# []
```

**Oczekiwane:** listener odbiera zarówno `orders:created`, jak i `orders:cancelled` (oraz przyszłe zdarzenia `orders:...` bez zmiany kodu).

**Pytanie dodatkowe:** jak w redis-cli sprawdzić, kto i czego nasłuchuje? (`PUBSUB CHANNELS`, `PUBSUB NUMPAT`, `PUBSUB NUMSUB ...`) Co się stanie z wiadomością opublikowaną, gdy nikt jej nie słucha?

## Kiedy skończysz

`check.sh` ma wypisać `WYNIK: wszystkie sprawdzenia przeszły`. Omówienie rozwiązania przedstawi prowadzący po zajęciach.
