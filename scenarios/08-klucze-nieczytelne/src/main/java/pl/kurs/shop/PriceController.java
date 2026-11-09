package pl.kurs.shop;

import java.util.Map;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

/**
 * Current prices are kept in Redis under the keys price:{id}, e.g. price:7 = "249.99".
 * The search service written in Python uses the same keys.
 */
@RestController
@RequestMapping("/api/prices")
public class PriceController {

    private final RedisTemplate<Object, Object> redisTemplate;

    public PriceController(RedisTemplate<Object, Object> redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    @PutMapping("/{productId}")
    public Map<String, Object> setPrice(@PathVariable Long productId, @RequestBody String price) {
        redisTemplate.opsForValue().set("price:" + productId, price);
        return Map.of("productId", productId, "price", price);
    }

    @GetMapping("/{productId}")
    public Map<String, Object> getPrice(@PathVariable Long productId) {
        Object price = redisTemplate.opsForValue().get("price:" + productId);
        if (price == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Brak ceny produktu " + productId);
        }
        return Map.of("productId", productId, "price", price);
    }
}
