package org.soursoup.bimbim.client;

import org.soursoup.bimbim.dto.response.MatchingResponse;
import org.springframework.web.service.annotation.PostExchange;

import java.util.List;

public interface MatchingClient {

    @PostExchange("/api/matching")
    List<MatchingResponse> getMatching();
}
