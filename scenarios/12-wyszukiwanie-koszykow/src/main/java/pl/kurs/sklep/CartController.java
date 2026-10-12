package pl.kurs.sklep;

import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/carts")
public class CartController {

    private final CartRepository carts;

    public CartController(CartRepository carts) {
        this.carts = carts;
    }

    @PostMapping
    public Cart create(@RequestParam String user, @RequestParam List<String> item) {
        return carts.save(new Cart(UUID.randomUUID().toString(), user, item));
    }

    @GetMapping("/{id}")
    public Cart get(@PathVariable String id) {
        return carts.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Brak koszyka " + id));
    }

    @GetMapping
    public List<Cart> byUser(@RequestParam String user) {
        return carts.findByUserId(user);
    }
}
