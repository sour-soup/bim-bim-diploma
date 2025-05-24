package org.soursoup.bimbim.service;

import org.soursoup.bimbim.dto.request.CategoryCreateRequest;
import org.soursoup.bimbim.entity.Category;

import java.util.List;

public interface CategoryService {
    Category createCategory(CategoryCreateRequest categoryCreateRes);

    Category getCategory(Long id);

    List<Category> getCategories();

    void deleteCategory(Long id);
}
