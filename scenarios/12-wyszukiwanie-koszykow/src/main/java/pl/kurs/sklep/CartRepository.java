package pl.kurs.sklep;

import java.util.List;

import org.springframework.data.repository.CrudRepository;

public interface CartRepository extends CrudRepository<Cart, String> {

    List<Cart> findByUserId(String userId);
}
