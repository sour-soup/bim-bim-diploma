package org.soursoup.bimbim.service;

import org.soursoup.bimbim.entity.Question;

import java.util.List;

public interface QuestionService {
    Question addQuestion(String questionContent, String answerLeft, String answerRight, Long categoryId);

    void deleteQuestion(Long questionId);

    List<Question> getQuestions();

    List<Question> getQuestionsByCategory(Long categoryId);

    List<Question> getRemainderQuestions(Long userId, Long categoryId);
}
