package org.soursoup.bimbim.repository;

import org.soursoup.bimbim.entity.Chat;
import org.soursoup.bimbim.entity.Message;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MessageRepository extends JpaRepository<Message, Long> {
    List<Message> findAllByChatOrderBySentAt(Chat chat);
}
