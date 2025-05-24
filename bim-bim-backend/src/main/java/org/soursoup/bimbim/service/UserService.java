package org.soursoup.bimbim.service;

import org.soursoup.bimbim.dto.JwtDto;
import org.soursoup.bimbim.dto.request.UpdateImageRequest;
import org.soursoup.bimbim.dto.request.UserLoginRequest;
import org.soursoup.bimbim.dto.request.UserRegisterRequest;
import org.soursoup.bimbim.entity.User;

import java.util.List;

public interface UserService {
    void registerUser(UserRegisterRequest userRegisterRequest);

    JwtDto loginUser(UserLoginRequest userLoginRequest);

    void updateAvatar(Long id, UpdateImageRequest updateAvatarReq);

    User getUser(Long id);

    void answerQuestion(Long userId, Long questionId, Long result);

    List<User> getUsers();

    void updateDescription(Long userId, String description);
}
