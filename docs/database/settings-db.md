# Mapeo del Servicio de Configuración (settings-service) ↔ Base de Datos (settings-db)

## Descripción General

El microservicio `settings-service` administra la configuración de la aplicación (general, API y notificaciones). Su API está descrita en `contracts/openapi/settings.yaml`.

### Tablas involucradas

| Archivo | Tabla | Descripción |
|---------|-------|-------------|
| `infra/database/settings-db/tables/001_settings_general.sql` | `settings_general` | Configuración global (nombre de la app, entorno, zona horaria). |
| `infra/database/settings-db/tables/002_settings_api_config.sql` | `settings_api_config` | Configuración del cliente API (URL, timeout, caché). |
| `infra/database/settings-db/tables/003_settings_notifications.sql` | `settings_notifications` | Preferencias de notificación (email, push, resumen semanal). |

### Stored Procedures (SPs)

| Archivo | SP | Operación REST | Descripción |
|---------|----|----------------|-------------|
| `infra/database/settings-db/storeprocedures/001_sp_get_settings_notifications.sql` | `sp_get_settings_notifications` | `GET /settings/notifications` | Devuelve la fila única de `settings_notifications`. |
| `infra/database/settings-db/storeprocedures/002_sp_update_settings_notifications.sql` | `sp_update_settings_notifications` | `PATCH /settings/notifications` | Actualiza los campos de notificación y devuelve la fila actualizada. |
| *(Se asume que existen SPs para general y API; si son necesarios crear, seguir el mismo patrón).*

### Mapeo Endpoint → SP

| Método | Ruta | SP | Comentario |
|--------|------|----|------------|
| GET | `/settings` | `sp_get_settings_general` *(no creado en este commit; sigue la convención)* | Obtiene la configuración global completa. |
| PATCH | `/settings/general` | `sp_update_settings_general` *(no creado en este commit; sigue la convención)* | Actualiza `applicationName`, `environment` y `timezone`. |
| GET | `/settings/api` | `sp_get_settings_api_config` *(no creado en este commit; sigue la convención)* | Obtiene configuración de la API. |
| PATCH | `/settings/api` | `sp_update_settings_api_config` *(no creado en este commit; sigue la convención)* | Actualiza URL, timeout y caché. |
| GET | `/settings/notifications` | `sp_get_settings_notifications` | Devuelve la configuración de notificaciones. |
| PATCH | `/settings/notifications` | `sp_update_settings_notifications` | Actualiza los flags de notificación. |

### Notas de Implementación

- Cada tabla tiene una única fila pre‑insertada (id = 1) para que la API siempre devuelva datos.
- `settings_general.environment` está limitado a los valores `development`, `staging` y `production` mediante `CHECK`.
- `settings_api_config.api_timeout_millis` está restringido entre 1 000 ms y 120 000 ms.
- Los SPs usan `CREATE OR REPLACE FUNCTION` y retornan `TABLE (…)` con columnas explícitas.
- Los índices se crean sobre columnas de filtro frecuente (`environment`).

---