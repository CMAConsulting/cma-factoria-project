package org.cma.factoria.settings.endpoint;

import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.apache.commons.lang3.StringUtils;
import org.cma.factoria.settings.model.ApiSettings;
import org.cma.factoria.settings.model.GeneralSettings;
import org.cma.factoria.settings.model.NotificationSettings;
import org.cma.factoria.settings.model.SettingsResponse;
import org.cma.factoria.settings.model.Error;
import org.cma.factoria.settings.service.SettingsService;

@Path("/api/settings")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class SettingsEndpoint {

    @Inject
    SettingsService settingsService;

    @GET
    public Response getAllSettings() {
        return Response.ok(settingsService.getAllSettings()).build();
    }

    @GET
    @Path("/general")
    public Response getGeneralSettings() {
        return Response.ok(settingsService.getGeneralSettings()).build();
    }

    @PATCH
    @Path("/general")
    public Response updateGeneralSettings(GeneralSettings request) {
        if (request == null || StringUtils.isBlank(request.getApplicationName())) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity(Error.builder()
                            .error("INVALID_REQUEST")
                            .message("El campo 'applicationName' es requerido")
                            .build())
                    .build();
        }
        if (request.getEnvironment() == null) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity(Error.builder()
                            .error("INVALID_REQUEST")
                            .message("El campo 'environment' es requerido")
                            .build())
                    .build();
        }
        if (StringUtils.isBlank(request.getTimezone())) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity(Error.builder()
                            .error("INVALID_REQUEST")
                            .message("El campo 'timezone' es requerido")
                            .build())
                    .build();
        }
        return Response.ok(settingsService.updateGeneralSettings(request)).build();
    }

    @GET
    @Path("/api")
    public Response getApiSettings() {
        return Response.ok(settingsService.getApiSettings()).build();
    }

    @PATCH
    @Path("/api")
    public Response updateApiSettings(ApiSettings request) {
        if (request == null || request.getApiBaseUrl() == null) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity(Error.builder()
                            .error("INVALID_REQUEST")
                            .message("El campo 'apiBaseUrl' es requerido")
                            .build())
                    .build();
        }
        if (request.getApiTimeoutMs() == null) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity(Error.builder()
                            .error("INVALID_REQUEST")
                            .message("El campo 'apiTimeoutMs' es requerido")
                            .build())
                    .build();
        }
        if (request.getEnableApiCaching() == null) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity(Error.builder()
                            .error("INVALID_REQUEST")
                            .message("El campo 'enableApiCaching' es requerido")
                            .build())
                    .build();
        }
        return Response.ok(settingsService.updateApiSettings(request)).build();
    }

    @GET
    @Path("/notifications")
    public Response getNotificationSettings() {
        return Response.ok(settingsService.getNotificationSettings()).build();
    }

    @PATCH
    @Path("/notifications")
    public Response updateNotificationSettings(NotificationSettings request) {
        if (request == null
                || request.getEmailOnCommandCompletion() == null
                || request.getPushOnError() == null
                || request.getWeeklySummaryEnabled() == null) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity(Error.builder()
                            .error("INVALID_REQUEST")
                            .message("Los campos de notificación son requeridos")
                            .build())
                    .build();
        }
        return Response.ok(settingsService.updateNotificationSettings(request)).build();
    }
}
