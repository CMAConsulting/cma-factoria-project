# Mapeo del Servicio de Dashboard (dashboard-service) → Base de Datos (dashboard-db)

## Descripción General

El microservicio `dashboard-service` proporciona vistas analíticas y en tiempo real del sistema. Su API está definida en `contracts/openapi/dashboard.yaml`.

### Tablas involucradas

| Archivo | Tabla | Descripción |
|---------|-------|-------------|
| `infra/database/dashboard-db/tables/001_dashboard_metrics.sql` | `dashboard_metrics` | Métricas agregadas del sistema (pending, processing, completed, failed) con actualización en tiempo real (`last_updated`). |
| `infra/database/dashboard-db/tables/002_dashboard_activity.sql` | `dashboard_activity` | Historial de actividades recientes (ej: ejecución de comandos o notificaciones) con tipo (`command-start`, `command-complete`, etc.). |

### Stored Procedures (SPs)

| Archivo | SP | Operación REST | Descripción |
|---------|----|----------------|-------------|
| `infra/database/dashboard-db/storeprocedures/001_sp_get_dashboard_metrics.sql` | `sp_get_dashboard_metrics` | `GET /dashboard/metrics` | Devuelve métricas agregadas del sistema. |
| `infra/database/dashboard-db/storeprocedures/002_sp_get_dashboard_activity.sql` | `sp_get_dashboard_activity` | `GET /dashboard/activity` | Lista actividades recientes con paginación opcional por usuario. |

### Mapeo Endpoint → SP

| Método | Ruta | SP | Comentario |
|--------|------|----|------------|
| GET | `/dashboard/metrics` | `sp_get_dashboard_metrics` | Obtiene métricas actuales |
| GET | `/dashboard/activity` | `sp_get_dashboard_activity` | Lista actividades recientes |

### Notas de Implementación

- Los métricos se actualizan mediante un job en segundo plano que ejecuta `INSERT` o `UPDATE` en `dashboard_metrics` conforme cambian los datos.
- La tabla `dashboard_activity` tiene un `INDEX` en `timestamp` y `user_id` para consultas rápidas de actividades recientes.
- Los SPs devuelven datos esterilizados a través de `RETURNS TABLE`, evitando SQL injection al generar consultas dinámicas.
- La paginación en `sp_get_dashboard_activity` usa `LIMIT` y `OFFSET` sin dependencia de `ROW_NUMBER()` para mayor compatibilidad.

---