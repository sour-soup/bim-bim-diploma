package org.soursoup.bimbim.client.properties;


import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Data
@Configuration
@ConfigurationProperties(prefix = "rest.client.matching", ignoreUnknownFields = false)
public class MatchingClientProperties {
    private String baseUrl;
}
