package pl.kurs.sklep;

import java.util.Map;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.serializer.StringRedisSerializer;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

/**
 * Aktualne ceny trzymamy w Redisie pod kluczami price:{id}, np. price:7 = "249.99".
 * Z tych samych kluczy korzysta wyszukiwarka napisana w Pythonie.
 */
@RestController
@RequestMapping("/api/prices")
public class PriceController {

    private final StringRedisTemplate redisTemplate;

    public PriceController(StringRedisTemplate redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    @PutMapping("/{productId}")
    public Map<String, Object> setPrice(@PathVariable Long productId, @RequestBody String price) {
        redisTemplate.opsForValue().set("price:" + productId, price);
        return Map.of("productId", productId, "price", price);
    }

    @GetMapping("/{productId}")
    public Map<String, Object> getPrice(@PathVariable Long productId) {
        String price = redisTemplate.opsForValue().get("price:" + productId);
        if (price == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Brak ceny produktu " + productId);
        }
        return Map.of("productId", productId, "price", price);
    }
}
