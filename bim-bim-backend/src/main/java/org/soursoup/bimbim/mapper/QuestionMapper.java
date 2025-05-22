package org.soursoup.bimbim.mapper;

import org.soursoup.bimbim.dto.response.QuestionResponse;
import org.soursoup.bimbim.entity.Question;
import org.mapstruct.*;

@Mapper(unmappedTargetPolicy = ReportingPolicy.IGNORE, componentModel = MappingConstants.ComponentModel.SPRING)
public interface QuestionMapper {
    Question toEntity(QuestionResponse questionResponse);

    QuestionResponse toDto(Question question);

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    Question partialUpdate(QuestionResponse questionResponse, @MappingTarget Question question);
}
