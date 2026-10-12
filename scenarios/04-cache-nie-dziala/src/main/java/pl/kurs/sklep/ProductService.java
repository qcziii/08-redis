package pl.kurs.sklep;

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

    public ProductDetails getDetails(Long id) {
        Product product = getProduct(id);
        return new ProductDetails(product, product.price().signum() > 0 ? "dostępny" : "niedostępny");
    }
}
