package org.soursoup.bimbim.mapper;

import org.soursoup.bimbim.dto.request.CategoryCreateRequest;
import org.soursoup.bimbim.entity.Category;
import org.mapstruct.*;

@Mapper(unmappedTargetPolicy = ReportingPolicy.IGNORE, componentModel = MappingConstants.ComponentModel.SPRING)
public interface CategoryCreateMapper {
    Category toEntity(CategoryCreateRequest categoryCreateRequest);

    CategoryCreateRequest toDto(Category category);

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    Category partialUpdate(CategoryCreateRequest categoryCreateRequest, @MappingTarget Category category);
}
