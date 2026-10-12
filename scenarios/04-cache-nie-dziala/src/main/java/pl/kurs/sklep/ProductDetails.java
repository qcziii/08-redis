package pl.kurs.sklep;

import java.io.Serializable;

public record ProductDetails(Product product, String availability) implements Serializable {
}
