package pl.kurs.sklep;

import org.springframework.data.redis.core.Cursor;
import org.springframework.data.redis.core.ScanOptions;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.Duration;
import java.util.Map;
import java.util.UUID;

/** Sesje zalogowanych klientów: session:{id} = login, wygasają po 30 minutach. */
@RestController
@RequestMapping("/api/sessions")
public class SessionController {

    private final StringRedisTemplate redis;

    public SessionController(StringRedisTemplate redis) {
        this.redis = redis;
    }

    @PostMapping
    public Map<String, String> login(@RequestParam String user) {
        String sessionId = UUID.randomUUID().toString();
        redis.opsForValue().set("session:" + sessionId, user, Duration.ofMinutes(30));
        return Map.of("sessionId", sessionId, "user", user);
    }

    /** Wywoływane co minutę przez dashboard działu obsługi klienta. */
    @GetMapping("/active")
    public Map<String, Object> activeSessions() {

        long count = 0;

        ScanOptions options = ScanOptions.scanOptions()
                .match("session:*")
                .count(1000)
                .build();

        try (Cursor<String> cursor = redis.scan(options)) {
            while (cursor.hasNext()) {
                cursor.next();
                count++;
            }
        }

        return Map.of("active", count);
    }
}
