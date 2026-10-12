package pl.kurs.sklep;

import java.util.List;

import org.springframework.data.annotation.Id;
import org.springframework.data.redis.core.RedisHash;

@RedisHash(value = "carts", timeToLive = 3600)
public record Cart(@Id String id, String userId, List<String> items) {
}
