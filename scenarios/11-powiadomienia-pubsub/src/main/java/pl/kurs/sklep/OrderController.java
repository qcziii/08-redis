package pl.kurs.sklep;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class OrderController {

    private final StringRedisTemplate redis;
    private final OrderEventsListener listener;

    public OrderController(StringRedisTemplate redis, OrderEventsListener listener) {
        this.redis = redis;
        this.listener = listener;
    }

    @PostMapping("/orders")
    public Map<String, String> create() {
        String orderId = UUID.randomUUID().toString().substring(0, 8);
        redis.convertAndSend("orders:created", orderId);
        return Map.of("orderId", orderId, "status", "utworzone");
    }

    @PostMapping("/orders/{orderId}/cancel")
    public Map<String, String> cancel(@PathVariable String orderId) {
        redis.convertAndSend("orders:cancelled", orderId);
        return Map.of("orderId", orderId, "status", "anulowane");
    }

    @GetMapping("/notifications")
    public List<String> notifications() {
        return listener.notifications();
    }
}
