package pl.kurs.shop;

import java.io.Serializable;

public record ProductDetails(Product product, String availability) implements Serializable {
}
