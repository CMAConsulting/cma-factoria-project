# Mapeo del Servicio de Comandos (command-service) ↔ Base de Datos (command-db)

## Descripción General

El microservicio `command-service` gestiona la recepción, envío y seguimiento de comandos remotos en el sistema. Su API está definida en `contracts/openapi/commands.yaml`.

### Tablas involucradas

| Archivo | Tabla | Descripción |
|---------|-------|-------------|
| `infra/database/command-db/tables/001_commands.sql` | `commands` | Registro maestro de cada comando solicitado. Contiene `id`, `command`, `payload`, `metadata`, `status`, `created_at`, `completed_at`. |
| `infra/database/command-db/tables/002_command_results.sql` | `command_results` | Resultado de la ejecución de un comando. Contiene `command_id`, `result`, `error`, `completed_at`. |

### Stored Procedures (SPs)

| Archivo | SP | Operación REST | Descripción |
|---------|----|----------------|-------------|
| `infra/database/command-db/storeprocedures/001_sp_insert_command.sql` | `sp_insert_command` | `POST /commands` | Inserta un nuevo comando con estado `pending` y devuelve la fila completa. |
| `infra/database/command-db/storeprocedures/002_sp_get_command.sql` | `sp_get_command` | `GET /commands/{id}` | Obtiene el comando y su resultado (si existe). Lanza excepción si no se encuentra. |
| `infra/database/command-db/storeprocedures/003_sp_list_commands.sql` | `sp_list_commands` | `GET /commands` | Lista comandos con filtrado por `status` y `source`, paginación (`limit`, `offset`) y columna `total`. |
| `infra/database/command-db/storeprocedures/004_sp_get_command_result.sql` | `sp_get_command_result` | `GET /commands/{id}/result` | Devuelve únicamente el resultado (o error) de un comando. Lanza excepción si no hay resultado. |

### Mapeo Endpoint → SP

| Método | Ruta | SP | Comentario |
|--------|------|----|------------|
| POST | `/commands` | `sp_insert_command` | Crea nuevo comando |
| GET | `/commands` | `sp_list_commands` | Lista con filtros y paginación |
| GET | `/commands/{id}` | `sp_get_command` | Detalle del comando |
| GET | `/commands/{id}/result` | `sp_get_command_result` | Resultado del comando |

### Notas de Implementación

- La tabla `commands` usa `UUID` como clave primaria generada con `gen_random_uuid()`.
- El campo `status` tiene un `CHECK` constraint para asegurar valores válidos: `pending`, `processing`, `completed`, `failed`.
- La tabla `command_results` tiene una relación `FOREIGN KEY (command_id) REFERENCES commands(id) ON DELETE CASCADE`.
- Los SPs siguen la convención `sp_<verbo>_<entidad>` y devuelven `TABLE` con columnas explícitas (nunca `SELECT *`).
- Los scripts son idempotentes (`CREATE TABLE IF NOT EXISTS`, `CREATE OR REPLACE FUNCTION`).

---