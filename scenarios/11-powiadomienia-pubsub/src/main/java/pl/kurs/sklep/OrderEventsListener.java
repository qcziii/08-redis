package pl.kurs.sklep;

import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.redis.connection.Message;
import org.springframework.data.redis.connection.MessageListener;
import org.springframework.stereotype.Component;

/** Odbiera zdarzenia zamówień i "wysyła powiadomienia" (tu: zapamiętuje je na liście). */
@Component
public class OrderEventsListener implements MessageListener {

    private static final Logger log = LoggerFactory.getLogger(OrderEventsListener.class);

    private final List<String> notifications = new CopyOnWriteArrayList<>();

    @Override
    public void onMessage(Message message, byte[] pattern) {
        String channel = new String(message.getChannel(), StandardCharsets.UTF_8);
        String body = new String(message.getBody(), StandardCharsets.UTF_8);
        log.info("Powiadomienie: {} {}", channel, body);
        notifications.add(channel + " " + body);
    }

    public List<String> notifications() {
        return notifications;
    }
}
