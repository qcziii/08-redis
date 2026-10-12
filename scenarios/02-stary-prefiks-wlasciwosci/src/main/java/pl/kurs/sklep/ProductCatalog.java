package pl.kurs.sklep;

import java.math.BigDecimal;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

/**
 * Udaje wolną bazę danych: każdy odczyt trwa ok. 1 s.
 * Nie zmieniaj tej klasy, to ona jest powodem, dla którego potrzebujemy cache.
 */
@Component
public class ProductCatalog {

    private final Map<Long, Product> products = new ConcurrentHashMap<>(Map.of(
            1L, new Product(1L, "Klawiatura mechaniczna", new BigDecimal("349.99")),
            2L, new Product(2L, "Mysz bezprzewodowa", new BigDecimal("129.00")),
            3L, new Product(3L, "Monitor 27 cali", new BigDecimal("1199.00"))));

    public Product findById(Long id) {
        slowDatabase();
        Product product = products.get(id);
        if (product == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Brak produktu " + id);
        }
        return product;
    }

    public Product updatePrice(Long id, BigDecimal price) {
        Product current = findById(id);
        Product updated = new Product(current.id(), current.name(), price);
        products.put(id, updated);
        return updated;
    }

    private static void slowDatabase() {
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
