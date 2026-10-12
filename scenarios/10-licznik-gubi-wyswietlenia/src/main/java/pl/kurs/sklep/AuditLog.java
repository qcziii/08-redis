package pl.kurs.sklep;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/** Udaje zapis do zewnętrznego systemu audytu (trwa ok. 20 ms). Nie zmieniaj tej klasy. */
@Component
public class AuditLog {

    private static final Logger log = LoggerFactory.getLogger(AuditLog.class);

    public void record(String event) {
        try {
            Thread.sleep(20);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        log.debug("audyt: {}", event);
    }
}
