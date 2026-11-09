package pl.kurs.shop;

import java.time.Duration;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** Sessions of logged-in customers: session:{id} = login, they expire after 30 minutes. */
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

    /** Called every minute by the customer service dashboard. */
    @GetMapping("/active")
    public Map<String, Object> activeSessions() {
        Set<String> keys = redis.keys("session:*");
        return Map.of("active", keys.size());
    }
}
