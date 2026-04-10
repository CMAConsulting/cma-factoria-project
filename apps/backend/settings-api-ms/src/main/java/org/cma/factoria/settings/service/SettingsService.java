package org.cma.factoria.settings.service;

import jakarta.enterprise.context.ApplicationScoped;
import org.cma.factoria.settings.model.ApiSettings;
import org.cma.factoria.settings.model.GeneralSettings;
import org.cma.factoria.settings.model.NotificationSettings;
import org.cma.factoria.settings.model.SettingsResponse;
import java.net.URI;

@ApplicationScoped
public class SettingsService {

    // Estado en memoria con valores por defecto
    private GeneralSettings generalSettings = GeneralSettings.builder()
            .applicationName("CMA Factoria")
            .environment(GeneralSettings.EnvironmentEnum.DEVELOPMENT)
            .timezone("Europe/Madrid")
            .build();

    private ApiSettings apiSettings = ApiSettings.builder()
            .apiBaseUrl(URI.create("http://localhost:8080"))
            .apiTimeoutMs(30000)
            .enableApiCaching(true)
            .build();

    private NotificationSettings notificationSettings = NotificationSettings.builder()
            .emailOnCommandCompletion(true)
            .pushOnError(true)
            .weeklySummaryEnabled(false)
            .build();

    public SettingsResponse getAllSettings() {
        return SettingsResponse.builder()
                .general(generalSettings)
                .api(apiSettings)
                .notifications(notificationSettings)
                .build();
    }

    public GeneralSettings getGeneralSettings() {
        return generalSettings;
    }

    public GeneralSettings updateGeneralSettings(GeneralSettings update) {
        generalSettings = update;
        return generalSettings;
    }

    public ApiSettings getApiSettings() {
        return apiSettings;
    }

    public ApiSettings updateApiSettings(ApiSettings update) {
        apiSettings = update;
        return apiSettings;
    }

    public NotificationSettings getNotificationSettings() {
        return notificationSettings;
    }

    public NotificationSettings updateNotificationSettings(NotificationSettings update) {
        notificationSettings = update;
        return notificationSettings;
    }
}
