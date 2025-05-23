package org.soursoup.bimbim.service;

import org.soursoup.bimbim.dto.response.MatchingResponse;

import java.util.List;

public interface MatchingService {
    List<MatchingResponse> getMatching(Long userId, Long categoryId);
}
