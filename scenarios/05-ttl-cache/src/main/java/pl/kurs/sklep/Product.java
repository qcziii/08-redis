package pl.kurs.sklep;

import java.io.Serializable;
import java.math.BigDecimal;

public record Product(Long id, String name, BigDecimal price) implements Serializable {
}
