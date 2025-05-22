package org.soursoup.bimbim.mapper;

import org.soursoup.bimbim.dto.response.CategoryResponse;
import org.soursoup.bimbim.entity.Category;
import org.mapstruct.*;

@Mapper(unmappedTargetPolicy = ReportingPolicy.IGNORE, componentModel = MappingConstants.ComponentModel.SPRING)
public interface CategoryMapper {
    Category toEntity(CategoryResponse categoryResponse);

    CategoryResponse toDto(Category category);

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    Category partialUpdate(CategoryResponse categoryResponse, @MappingTarget Category category);
}
