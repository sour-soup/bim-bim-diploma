package org.soursoup.bimbim.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

public record MatchingRequest(
        @JsonProperty Long userId,
        @JsonProperty List<UserMatching> users) {

    public record UserMatching(
            @JsonProperty Long id,
            @JsonProperty String gender,
            @JsonProperty String description,
            @JsonProperty List<Long> answers) {
    }
}
