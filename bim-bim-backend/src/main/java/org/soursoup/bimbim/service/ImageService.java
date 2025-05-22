package org.soursoup.bimbim.service;

import lombok.SneakyThrows;
import org.soursoup.bimbim.dto.request.ImageRequest;

public interface ImageService {
    @SneakyThrows
    String upload(ImageRequest imageRequest);

    @SneakyThrows
    String getImage(String filename);
}
