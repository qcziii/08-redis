package pl.kurs.sklep;

import java.math.BigDecimal;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

@Service
public class ProductService {

    private final ProductCatalog catalog;

    public ProductService(ProductCatalog catalog) {
        this.catalog = catalog;
    }

    @Cacheable("products")
    public Product getProduct(Long id) {
        return catalog.findById(id);
    }

    @CacheEvict(cacheNames = "product", key = "#id")
    public Product updatePrice(Long id, BigDecimal price) {
        return catalog.updatePrice(id, price);
    }
}
