package org.soursoup.bimbim.controller;

import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import lombok.RequiredArgsConstructor;
import org.soursoup.bimbim.dto.JwtDto;
import org.soursoup.bimbim.dto.request.CategoryCreateRequest;
import org.soursoup.bimbim.dto.request.CategoryIdRequest;
import org.soursoup.bimbim.dto.response.CategoryResponse;
import org.soursoup.bimbim.mapper.CategoryMapper;
import org.soursoup.bimbim.service.CategoryService;
import org.soursoup.bimbim.utils.JwtUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/category")
@RequiredArgsConstructor
public class CategoryController {
    private final JwtUtils jwtUtils;
    private final CategoryService categoryService;

    private final CategoryMapper categoryMapper;

    @PostMapping("/create")
    @SecurityRequirement(name = "bearerAuth")
    public CategoryResponse createCategory(@RequestBody CategoryCreateRequest categoryCreateRes) {
        JwtDto token = jwtUtils.getJwtToken();
        Long userId = jwtUtils.extractId(token);
        jwtUtils.forceAdminRole(token);
        return categoryMapper.toDto(categoryService.createCategory(categoryCreateRes));
    }

    @DeleteMapping("/delete")
    @SecurityRequirement(name = "bearerAuth")
    public void deleteCategory(@RequestBody CategoryIdRequest categoryIdRequest) {
        JwtDto token = jwtUtils.getJwtToken();
        Long userId = jwtUtils.extractId(token);
        jwtUtils.forceAdminRole(token);
        categoryService.deleteCategory(categoryIdRequest.id());
    }

    @GetMapping("/{categoryId}")
    public CategoryResponse getCategory(@PathVariable Long categoryId) {
        return categoryMapper.toDto(categoryService.info(categoryId));
    }

    @GetMapping("/all")
    public List<CategoryResponse> getCategories() {
        return categoryService.all().stream().map(categoryMapper::toDto).toList();
    }
}
