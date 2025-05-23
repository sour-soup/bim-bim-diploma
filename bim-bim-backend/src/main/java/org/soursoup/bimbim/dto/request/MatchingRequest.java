package org.soursoup.bimbim.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;
import java.util.Map;

public record MatchingRequest(
        @JsonProperty Long userId,
        @JsonProperty List<UserMatching> users) {

    public record UserMatching(
            @JsonProperty Long id,
            @JsonProperty String gender,
            @JsonProperty String description,
            @JsonProperty Map<Long, Long> answers) {
    }
}
