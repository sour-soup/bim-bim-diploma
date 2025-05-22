package org.soursoup.bimbim.controller;

import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import lombok.RequiredArgsConstructor;
import org.soursoup.bimbim.dto.JwtDto;
import org.soursoup.bimbim.dto.request.UpdateImageRequest;
import org.soursoup.bimbim.dto.request.UserLoginRequest;
import org.soursoup.bimbim.dto.request.UserRegisterRequest;
import org.soursoup.bimbim.dto.response.UserResponse;
import org.soursoup.bimbim.mapper.UserMapper;
import org.soursoup.bimbim.service.impl.UserServiceImpl;
import org.soursoup.bimbim.utils.JwtUtils;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/user")
public class UserController {
    private final UserServiceImpl userService;
    private final JwtUtils jwtUtils;

    private final UserMapper userMapper;

    @GetMapping("/isAdmin")
    @SecurityRequirement(name = "bearerAuth")
    public String isAdmin() {
        JwtDto token = jwtUtils.getJwtToken();
        return String.valueOf(jwtUtils.hasAdminRole(token));
    }

    @PostMapping("/register")
    public void registerUser(@RequestBody UserRegisterRequest userRegisterRequest) {
        userService.registerUser(userRegisterRequest);
    }

    @PostMapping("/login")
    public JwtDto loginUser(@RequestBody UserLoginRequest userLoginRequest) {
        return userService.loginUser(userLoginRequest);
    }

    @PostMapping(value = "/updateAvatar", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @SecurityRequirement(name = "bearerAuth")
    public void updateAvatar(
            @ModelAttribute UpdateImageRequest updateImageRequest) {
        JwtDto token = jwtUtils.getJwtToken();
        Long userId = jwtUtils.extractId(token);
        userService.updateAvatar(userId, updateImageRequest);
    }

    @GetMapping("/profile")
    @SecurityRequirement(name = "bearerAuth")
    public UserResponse getUserProfile() {
        JwtDto token = jwtUtils.getJwtToken();
        Long userId = jwtUtils.extractId(token);
        return userMapper.toDto(userService.getUser(userId));
    }

    @GetMapping("/{userId}")
    public UserResponse getUser(@PathVariable Long userId) {
        return userMapper.toDto(userService.getUser(userId));
    }

    @GetMapping("/all")
    public List<UserResponse> all() {
        return userService.all().stream().map(userMapper::toDto).toList();
    }

    @PostMapping("/setDescrioptin")
    public void setDescription(String description) {
        JwtDto token = jwtUtils.getJwtToken();
        Long userId = jwtUtils.extractId(token);
        userService.setDescription(userId, description);
    }
}

