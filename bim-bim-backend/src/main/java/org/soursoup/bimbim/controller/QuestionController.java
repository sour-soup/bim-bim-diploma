package org.soursoup.bimbim.controller;

import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import lombok.RequiredArgsConstructor;
import org.soursoup.bimbim.dto.JwtDto;
import org.soursoup.bimbim.dto.request.AddQuestionRequest;
import org.soursoup.bimbim.dto.response.QuestionResponse;
import org.soursoup.bimbim.mapper.QuestionMapper;
import org.soursoup.bimbim.service.QuestionService;
import org.soursoup.bimbim.service.UserService;
import org.soursoup.bimbim.utils.JwtUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/question")
public class QuestionController {
    private final JwtUtils jwtUtils;
    private final UserService userService;
    private final QuestionService questionService;

    private final QuestionMapper questionMapper;

    @GetMapping("/setAnswer")
    @SecurityRequirement(name = "bearerAuth")
    public void setQuestionForUser(Long questionId, Long result) {
        JwtDto token = jwtUtils.getJwtToken();
        Long userId = jwtUtils.extractId(token);
        userService.answerQuestion(userId, questionId, result);
    }


    @PostMapping(value = "/add")
    @SecurityRequirement(name = "bearerAuth")
    public QuestionResponse addQuestion(@RequestBody AddQuestionRequest addQuestionRequest) {
        JwtDto token = jwtUtils.getJwtToken();
        Long userId = jwtUtils.extractId(token);
        jwtUtils.forceAdminRole(token);
        return questionMapper.toDto(questionService.addQuestion(
                addQuestionRequest.questionContent(),
                addQuestionRequest.answerLeft(),
                addQuestionRequest.answerRight(),
                addQuestionRequest.categoryId()
        ));
    }

    @DeleteMapping("/delete/{id}")
    @SecurityRequirement(name = "bearerAuth")
    public void deleteQuestion(@PathVariable Long id) {
        JwtDto token = jwtUtils.getJwtToken();
        Long userId = jwtUtils.extractId(token);
        jwtUtils.forceAdminRole(token);
        questionService.deleteQuestion(id);
    }

    @GetMapping("/allByCategory")
    public List<QuestionResponse> all(Long categoryId) {
        return questionService.all(categoryId).stream().map(questionMapper::toDto).toList();
    }

    @GetMapping("/remainderByCategory")
    @SecurityRequirement(name = "bearerAuth")
    public List<QuestionResponse> remainderByCategory(Long categoryId) {
        JwtDto token = jwtUtils.getJwtToken();
        Long userId = jwtUtils.extractId(token);
        return questionService.remainder(userId, categoryId).stream().map(questionMapper::toDto).toList();
    }

    @GetMapping("/all")
    public List<QuestionResponse> all() {
        return questionService.all().stream().map(questionMapper::toDto).toList();
    }

}
