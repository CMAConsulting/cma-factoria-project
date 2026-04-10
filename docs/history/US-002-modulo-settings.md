# US-002 — Módulo de Configuración (Settings)

## Metadata

| Campo        | Valor                           |
|--------------|---------------------------------|
| ID           | US-002                          |
| Estado       | Pendiente de implementación     |
| ADR asociado | ADR-002                         |
| Fecha        | 2026-04-10                      |
| Módulo       | MFE Settings + command-service  |

## Historia de usuario

**Como** administrador de la aplicación,  
**quiero** guardar y recuperar la configuración del sistema desde la interfaz web,  
**para** que los cambios persistan entre sesiones y sean coherentes para todos los usuarios.

## Criterios de aceptación

### General
- [ ] El usuario puede ver los valores actuales de `applicationName`, `environment` y `timezone`.
- [ ] El usuario puede modificarlos y guardarlos con "Save Changes".
- [ ] Al recargar la página, los valores guardados se mantienen.

### API
- [ ] El usuario puede ver y editar `apiBaseUrl`, `apiTimeoutMs` y `enableApiCaching`.
- [ ] El valor de `apiBaseUrl` se valida como URI bien formada antes de guardar.
- [ ] El `apiTimeoutMs` acepta valores entre 1 000 y 120 000 ms.

### Notifications
- [ ] El usuario puede activar/desactivar cada preferencia de notificación de forma independiente.
- [ ] Los cambios se reflejan inmediatamente tras guardar sin recargar la página.

### General
- [ ] Un mensaje de confirmación visible aparece tras guardar exitosamente.
- [ ] Un mensaje de error visible aparece si el guardado falla (ej. red caída).
- [ ] Todos los endpoints de configuración requieren autenticación JWT.

## Flujo principal

1. Usuario navega a "Settings" en la sidebar de la shell.
2. El MFE Settings carga — llama `GET /api/settings` para obtener la configuración actual.
3. Los campos del formulario se rellenan con los valores del backend.
4. El usuario modifica los campos que necesite.
5. Pulsa "Save Changes" — se llama `PATCH /api/settings/{section}` con los datos del formulario.
6. El backend persiste los cambios y devuelve los valores actualizados (200 OK).
7. La UI muestra un indicador de éxito.

## Contrato API

Definido en `contracts/openapi/settings.yaml`.

Endpoints utilizados:

| Método | Endpoint                         | Operación                    |
|--------|----------------------------------|------------------------------|
| GET    | `/api/settings`                  | `getSettings`                |
| GET    | `/api/settings/general`          | `getGeneralSettings`         |
| PATCH  | `/api/settings/general`          | `updateGeneralSettings`      |
| GET    | `/api/settings/api`              | `getApiSettings`             |
| PATCH  | `/api/settings/api`              | `updateApiSettings`          |
| GET    | `/api/settings/notifications`    | `getNotificationSettings`    |
| PATCH  | `/api/settings/notifications`    | `updateNotificationSettings` |

## Notas de implementación

- **Backend**: nuevo `SettingsResource.java` en `apps/backend/command-service/`.
- **Persistencia inicial**: `SettingsStore` singleton con `ConcurrentHashMap` y valores por defecto.
- **Modelos**: generados automáticamente desde `contracts/openapi/settings.yaml` en fase `generate-sources`.
- **Frontend**: el componente `App.tsx` de `mfe-settings` debe migrar de valores hardcodeados a llamadas al cliente generado desde `shared-api`.
- **shared-api**: requiere regenerar tras añadir `settings.yaml` al proceso de generación de `@hey-api/openapi-ts`.

## Dependencias

- US-001 (canal de comandos) — backend ya operativo, reutiliza la misma infraestructura.
- `contracts/openapi/settings.yaml` — contrato definido, pendiente de consumir.
