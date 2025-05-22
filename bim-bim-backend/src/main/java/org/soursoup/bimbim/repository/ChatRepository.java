package org.soursoup.bimbim.repository;

import org.soursoup.bimbim.entity.Chat;
import org.soursoup.bimbim.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ChatRepository extends JpaRepository<Chat, Long> {
    List<Chat> findAllByFromUserAndToUserConfirmedFalse(User fromUser);

    List<Chat> findAllByToUserAndToUserConfirmedFalse(User toUser);

    boolean existsByFromUserAndToUser(User fromUser, User toUser);

    List<Chat> findAllByFromUserAndToUserConfirmedTrueOrToUserAndToUserConfirmedTrue(User fromUser, User toUser);

    List<Chat> findAllByFromUserOrToUser(User fromUser, User toUser);
}

