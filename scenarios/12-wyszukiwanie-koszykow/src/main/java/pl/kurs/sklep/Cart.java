package pl.kurs.sklep;

import java.util.List;

import org.springframework.data.annotation.Id;
import org.springframework.data.redis.core.RedisHash;
import org.springframework.data.redis.core.index.Indexed;

@RedisHash(value = "carts", timeToLive = 3600)
public record Cart(@Id String id,
                   @Indexed String userId,
                   List<String> items) {
}
