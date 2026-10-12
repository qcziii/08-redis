package pl.kurs.sklep;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
public class SklepApplication {

    public static void main(String[] args) {
        SpringApplication.run(SklepApplication.class, args);
    }
}
