# US-001 — Canal de Comandos Remotos

## Metadata

| Campo        | Valor                          |
|--------------|--------------------------------|
| ID           | US-001                         |
| Estado       | Implementado                   |
| ADR asociado | ADR-001                        |
| Fecha        | 2026-04-09                     |
| Módulo       | MFE Commands + command-service |

## Historia de usuario

**Como** operador del sistema,  
**quiero** enviar comandos remotos desde la interfaz web y consultar su estado,  
**para** orquestar operaciones (deploys, scripts, jobs) sin acceso directo al servidor.

## Criterios de aceptación

- [ ] El usuario puede escribir el nombre de un comando y enviarlo con un clic.
- [ ] El sistema responde con un ID único y estado `pending` de forma inmediata (202 Accepted).
- [ ] El usuario puede listar los comandos enviados con su estado actual.
- [ ] El usuario puede consultar el estado de un comando individual por su ID.
- [ ] El usuario puede obtener el resultado de un comando completado.
- [ ] Los estados posibles son: `pending`, `processing`, `completed`, `failed`.
- [ ] Un comando fallido muestra el mensaje de error.
- [ ] El listado soporta filtrado por estado y paginación.

## Flujo principal

1. Usuario abre el MFE Commands en la shell.
2. Introduce el nombre del comando (ej. `deploy`) y datos del payload.
3. Pulsa "Execute" — se llama `POST /api/commands`.
4. La UI muestra el comando recién creado con estado `pending`.
5. El usuario refresca o consulta `GET /api/commands/{id}` para ver el progreso.
6. Cuando el estado llega a `completed`, el usuario puede ver el resultado.

## Contrato API

Definido en `contracts/openapi/commands.yaml`.

Endpoints utilizados:

| Método | Endpoint                  | Operación         |
|--------|---------------------------|-------------------|
| POST   | `/api/commands`           | `executeCommand`  |
| GET    | `/api/commands`           | `listCommands`    |
| GET    | `/api/commands/{id}`      | `getCommand`      |
| GET    | `/api/commands/{id}/result` | `getCommandResult` |

## Notas de implementación

- Backend: `CommandResource.java` en `apps/backend/command-service/`.
- Almacenamiento en memoria (`ConcurrentHashMap`) — sin base de datos.
- Frontend: `apps/frontend/mfe-commands/` — remote MFE en puerto 3001.
- Tipos TypeScript generados desde el contrato OpenAPI via `shared-api`.
- El cliente HTTP usa `body:` como parámetro en `executeCommand` (no `data:`).
