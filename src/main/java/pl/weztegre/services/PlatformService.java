package pl.weztegre.services;

import pl.weztegre.models.Platform;
import pl.weztegre.models.Role;

import java.util.List;

public interface PlatformService {
        List<Platform> findAll();
        Platform findByPlatform(final String platform);
        void createPlatform(final String platform);
}
