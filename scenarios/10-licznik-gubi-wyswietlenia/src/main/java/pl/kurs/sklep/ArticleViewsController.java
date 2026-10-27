package pl.kurs.sklep;

import java.util.Map;

import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** Licznik wyświetleń artykułów na blogu sklepu. W Redisie: views:article:{id} = liczba. */
@RestController
@RequestMapping("/api/articles")
public class ArticleViewsController {

    private final StringRedisTemplate redis;
    private final AuditLog auditLog;

    public ArticleViewsController(StringRedisTemplate redis, AuditLog auditLog) {
        this.redis = redis;
        this.auditLog = auditLog;
    }

    @PostMapping("/{id}/views")
    public Map<String, Object> registerView(@PathVariable Long id) {
        String key = "views:article:" + id;
        Long views = redis.opsForValue().increment(key);
        auditLog.record("artykuł " + id + " wyświetlony " + views + " raz");
        redis.opsForValue().set(key, String.valueOf(views));
        return Map.of("articleId", id, "views", views);
    }

    @GetMapping("/{id}/views")
    public Map<String, Object> getViews(@PathVariable Long id) {
        String current = redis.opsForValue().get("views:article:" + id);
        return Map.of("articleId", id, "views", current == null ? 0 : Long.parseLong(current));
    }
}
