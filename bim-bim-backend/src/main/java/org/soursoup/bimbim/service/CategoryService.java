package org.soursoup.bimbim.service;

import org.soursoup.bimbim.dto.request.CategoryCreateRequest;
import org.soursoup.bimbim.entity.Category;

import java.util.List;

public interface CategoryService {
    Category createCategory(CategoryCreateRequest categoryCreateRes);

    Category info(Long id);

    List<Category> all();

    void deleteCategory(Long id);
}
