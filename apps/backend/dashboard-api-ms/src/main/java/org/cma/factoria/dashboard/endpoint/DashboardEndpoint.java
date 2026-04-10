package org.cma.factoria.dashboard.endpoint;

import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import org.cma.factoria.dashboard.model.ActivityItem;
import org.cma.factoria.dashboard.model.DashboardMetrics;
import org.cma.factoria.dashboard.service.DashboardService;

import java.util.List;

@Path("/api/dashboard")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class DashboardEndpoint {

    @Inject
    DashboardService dashboardService;

    @GET
    @Path("/metrics")
    public DashboardMetrics getMetrics() {
        return dashboardService.getMetrics();
    }

    @GET
    @Path("/activity")
    public List<ActivityItem> getActivity() {
        return dashboardService.getActivity();
    }
}
