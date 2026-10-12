package pl.kurs.sklep;

import java.security.SecureRandom;
import java.time.Duration;
import java.util.Map;

import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * Jednorazowe kody SMS do logowania. Kod jest ważny 5 minut, można się pomylić 3 razy.
 * W Redisie: sms-code:{telefon} = "{kod}:{liczba_nieudanych_prób}".
 */
@RestController
@RequestMapping("/api/codes")
public class VerificationCodeController {

    private static final Duration VALIDITY = Duration.ofMinutes(5);
    private static final int MAX_ATTEMPTS = 3;

    private final StringRedisTemplate redis;
    private final SecureRandom random = new SecureRandom();

    public VerificationCodeController(StringRedisTemplate redis) {
        this.redis = redis;
    }

    @PostMapping("/{phone}")
    public Map<String, String> send(@PathVariable String phone) {
        String code = String.format("%06d", random.nextInt(1_000_000));
        redis.opsForValue().set(key(phone), code + ":0", VALIDITY);
        // Środowisko deweloperskie: zamiast wysyłać SMS zwracamy kod w odpowiedzi
        return Map.of("phone", phone, "code", code);
    }

    @PostMapping("/{phone}/verify")
    public ResponseEntity<Map<String, Object>> verify(@PathVariable String phone, @RequestParam String code) {
        String key = key(phone);
        String value = redis.opsForValue().get(key);
        if (value == null) {
            return ResponseEntity.status(HttpStatus.GONE).body(Map.of("result", "kod wygasł lub nie istnieje"));
        }
        String[] parts = value.split(":");
        String expected = parts[0];
        int failedAttempts = Integer.parseInt(parts[1]);

        if (expected.equals(code)) {
            redis.delete(key);
            return ResponseEntity.ok(Map.of("result", "zalogowano"));
        }
        failedAttempts++;
        if (failedAttempts >= MAX_ATTEMPTS) {
            redis.delete(key);
            return ResponseEntity.status(HttpStatus.TOO_MANY_REQUESTS).body(Map.of("result", "za dużo prób, wygeneruj nowy kod"));
        }
        redis.opsForValue().set(key, expected + ":" + failedAttempts);
        return ResponseEntity.badRequest().body(Map.of("result", "zły kod", "attemptsLeft", MAX_ATTEMPTS - failedAttempts));
    }

    private static String key(String phone) {
        return "sms-code:" + phone;
    }
}
