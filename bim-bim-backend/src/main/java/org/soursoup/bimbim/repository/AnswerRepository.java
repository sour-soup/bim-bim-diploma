package org.soursoup.bimbim.repository;

import org.soursoup.bimbim.entity.Answer;
import org.soursoup.bimbim.entity.Question;
import org.soursoup.bimbim.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface AnswerRepository extends JpaRepository<Answer, Long> {
    Optional<Answer> findByUserAndQuestion(User user, Question question);

    List<Answer> findAllByUser(User user);
}
