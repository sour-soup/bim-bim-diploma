package org.soursoup.bimbim.client;

import org.soursoup.bimbim.dto.request.MatchingRequest;
import org.soursoup.bimbim.dto.response.MatchingResponse;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.service.annotation.PostExchange;

import java.util.List;

public interface MatchingClient {

    @PostExchange("/api/matching")
    List<MatchingResponse> getMatching(@RequestBody MatchingRequest request);
}
