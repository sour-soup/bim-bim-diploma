package org.soursoup.bimbim.repository;

import org.soursoup.bimbim.entity.Category;
import org.soursoup.bimbim.entity.Question;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface QuestionRepository extends JpaRepository<Question, Long> {
    List<Question> findAllByCategory(Category category);

    List<Question> findAllByCategoryId(Long categoryId);

}
