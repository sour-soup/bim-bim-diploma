package org.soursoup.bimbim.service.impl;

import lombok.RequiredArgsConstructor;
import org.soursoup.bimbim.client.MatchingClient;
import org.soursoup.bimbim.dto.request.MatchingRequest;
import org.soursoup.bimbim.dto.response.MatchingResponse;
import org.soursoup.bimbim.entity.Answer;
import org.soursoup.bimbim.entity.Category;
import org.soursoup.bimbim.entity.Question;
import org.soursoup.bimbim.entity.User;
import org.soursoup.bimbim.exception.NotFoundException;
import org.soursoup.bimbim.repository.*;
import org.soursoup.bimbim.service.MatchingService;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Service
@RequiredArgsConstructor
public class MatchingServiceImpl implements MatchingService {

    private final CategoryRepository categoryRepository;
    private final QuestionRepository questionRepository;
    private final AnswerRepository answerRepository;
    private final UserRepository userRepository;
    private final ChatRepository chatRepository;
    private final MatchingClient matchingClient;

    @Override
    public List<MatchingResponse> getMatching(Long userId, Long categoryId) {
        Category category = categoryRepository.findById(categoryId)
                .orElseThrow(() -> new NotFoundException("Category not found"));

        List<Question> questions = questionRepository.findAllByCategory(category);

        User currentUser = userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("User not found"));

        List<User> connectedUserIds = chatRepository.findAllByFromUserOrToUser(currentUser, currentUser).stream()
                .flatMap(chat -> Stream.of(chat.getFromUser(), chat.getToUser()))
                .filter(user -> !user.equals(currentUser))
                .distinct().toList();

        List<User> users = userRepository.findAll().stream()
                .filter(user -> !connectedUserIds.contains(user))
                //.filter(user -> !user.equals(currentUser))
                .toList();

        Map<Long, Map<Long, Long>> answerMap = buildAnswerMap(users, questions);

        List<MatchingRequest.UserMatching> userMatchings = users.stream()
                .map(user -> buildUserMatching(user, answerMap))
                .toList();

        MatchingRequest matchingRequest = new MatchingRequest(userId, userMatchings);

        return matchingClient.getMatching(matchingRequest);
    }

    private Map<Long, Map<Long, Long>> buildAnswerMap(List<User> users, List<Question> questions) {
        return users.stream()
                .collect(Collectors.toMap(User::getId, user -> buildAnswers(user, questions)));
    }

    private Map<Long, Long> buildAnswers(User user, List<Question> questions) {
        List<Answer> answers = answerRepository.findAllByUser(user);

        return answers.stream()
                .filter(answer -> questions.stream().anyMatch(q -> q.getId().equals(answer.getQuestion().getId())))
                .collect(Collectors.toMap(Answer::getId, Answer::getAnswer));
    }

    private MatchingRequest.UserMatching buildUserMatching(User user, Map<Long, Map<Long, Long>> answerMap) {
        return new MatchingRequest.UserMatching(
                user.getId(),
                user.getGender(),
                user.getDescription(),
                answerMap.get(user.getId())
        );
    }
}
