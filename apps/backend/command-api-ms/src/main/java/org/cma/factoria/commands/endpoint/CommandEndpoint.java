package org.cma.factoria.commands.endpoint;

import io.smallrye.mutiny.Uni;
import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.apache.commons.lang3.StringUtils;
import org.cma.factoria.commands.model.*;
import org.cma.factoria.commands.service.CommandService;

@Path("/api/commands")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class CommandEndpoint {

    @Inject
    CommandService commandService;

    @POST
    public Uni<Response> executeCommand(CommandRequest request) {
        if (request == null || StringUtils.isBlank(request.getCommand())) {
            var err = new org.cma.factoria.commands.model.Error();
            err.setError("INVALID_REQUEST");
            err.setMessage("El campo 'command' es requerido");
            return Uni.createFrom().item(Response.status(Response.Status.BAD_REQUEST).entity(err).build());
        }
        return commandService.executeCommand(request)
            .map(response -> Response.status(Response.Status.CREATED).entity(response).build());
    }

    @GET
    public Uni<Response> listCommands(
            @QueryParam("status") String status,
            @QueryParam("source") String source,
            @QueryParam("limit") Integer limit,
            @QueryParam("offset") Integer offset) {
        return commandService.listCommands(status, source, limit, offset)
            .map(resp -> Response.ok(resp).build());
    }

    @GET
    @Path("/{id}")
    public Uni<Response> getCommand(@PathParam("id") String id) {
        return commandService.getCommand(id)
            .map(entity -> entity != null 
                ? Response.ok(entity).build() 
                : Response.status(Response.Status.NOT_FOUND).build());
    }

    @GET
    @Path("/{id}/result")
    public Uni<Response> getCommandResult(@PathParam("id") String id) {
        return commandService.getCommandResult(id)
            .map(result -> result != null 
                ? Response.ok(result).build() 
                : Response.status(Response.Status.NOT_FOUND).build());
    }
}