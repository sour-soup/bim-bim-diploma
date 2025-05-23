package org.soursoup.bimbim.config;

import org.soursoup.bimbim.client.MatchingClient;
import org.soursoup.bimbim.client.properties.MatchingClientProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.support.RestClientAdapter;
import org.springframework.web.service.invoker.HttpServiceProxyFactory;

@Configuration
public class RestClientConfig {

    @Bean
    public MatchingClient matchingClient(RestClient.Builder builder, MatchingClientProperties properties) {
        RestClient restClient = builder.baseUrl(properties.getBaseUrl()).build();

        RestClientAdapter adapter = RestClientAdapter.create(restClient);
        HttpServiceProxyFactory factory =
                HttpServiceProxyFactory.builderFor(adapter).build();

        return factory.createClient(MatchingClient.class);
    }

    private RestClient.Builder buildBaseRestClient(RestClient.Builder builder, MatchingClientProperties properties) {

        return builder.baseUrl(properties.getBaseUrl());
    }
}
