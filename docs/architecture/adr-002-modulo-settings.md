# ADR-002: Módulo de Configuración (Settings)

## Estado

**Aceptado** — Pendiente de implementación backend

## Contexto

El MFE Settings expone tres secciones de configuración (General, API, Notifications) que actualmente operan de forma estática — los valores están hardcodeados en el frontend y los cambios no persisten entre sesiones. Se necesita un backend que persista y sirva estas configuraciones.

La decisión complementa ADR-001, que resolvió el canal de ejecución de comandos remotos. Este ADR resuelve cómo gestionar la configuración de la aplicación de forma persistente y coherente entre sesiones y réplicas.

## Decisión

Se implementará una **Settings API** en el backend existente (`command-service`) con los siguientes principios:

### Estructura de endpoints

| Método  | Endpoint                    | Descripción                                 |
|---------|-----------------------------|---------------------------------------------|
| `GET`   | `/api/settings`             | Obtener todas las configuraciones           |
| `GET`   | `/api/settings/general`     | Obtener configuración general               |
| `PATCH` | `/api/settings/general`     | Actualizar configuración general            |
| `GET`   | `/api/settings/api`         | Obtener configuración de API                |
| `PATCH` | `/api/settings/api`         | Actualizar configuración de API             |
| `GET`   | `/api/settings/notifications` | Obtener preferencias de notificaciones    |
| `PATCH` | `/api/settings/notifications` | Actualizar preferencias de notificaciones |

### Secciones de configuración

**General** — metadatos de la instancia:
- `applicationName`: nombre visible de la aplicación
- `environment`: entorno activo (`development`, `staging`, `production`)
- `timezone`: zona horaria IANA (ej. `Europe/Madrid`)

**API** — conexión al backend:
- `apiBaseUrl`: URL base del backend (usado por el frontend para construir requests)
- `apiTimeoutMs`: timeout de llamadas HTTP (1000–120 000 ms)
- `enableApiCaching`: flag para caché de respuestas

**Notifications** — preferencias de alertas:
- `emailOnCommandCompletion`: email al finalizar un comando
- `pushOnError`: push cuando un comando falla
- `weeklySummaryEnabled`: resumen semanal de actividad

### Contrato OpenAPI

El contrato vive en `contracts/openapi/settings.yaml` y es la única fuente de verdad, siguiendo el mismo flujo que `commands.yaml`:
- El backend genera los modelos Java desde él en fase `generate-sources`.
- El frontend genera los tipos TypeScript con `@hey-api/openapi-ts`.

### Persistencia

Fase inicial: almacenamiento en memoria (`ConcurrentHashMap` con singleton `SettingsStore`) con valores por defecto al arrancar el servicio. Suficiente para desarrollo y demos; no requiere base de datos.

### Autenticación

Misma estrategia que la Command API: `Authorization: Bearer <token>`. Todos los endpoints requieren el token.

## Consecuencias

### Positivas

- Las configuraciones persisten durante la sesión del servidor (no se pierden al navegar entre páginas).
- El frontend puede arrancar con valores dinámicos del backend en lugar de defaults hardcodeados.
- El contrato OpenAPI garantiza coherencia entre frontend y backend sin coordinación manual.
- Extensible: cuando se añada persistencia real (PostgreSQL, etc.), solo cambia la implementación de `SettingsStore`, no el contrato.

### Negativas

- Los settings se pierden al reiniciar el servidor (fase inicial en memoria).
- Un único servicio gestiona tanto comandos como settings — acopla dominios distintos en el mismo microservicio. Aceptable para el tamaño actual del proyecto.

## Alternativas consideradas

1. **Fichero de configuración en disco (JSON/YAML)** — Simple pero problemático en entornos containerizados (volúmenes, permisos).
2. **Variables de entorno** — Adecuado para config de infraestructura, no para preferencias de usuario modificables en runtime.
3. **Servicio separado `settings-service`** — Correcto a escala, pero sobredimensionado para el estado actual del proyecto.
4. **localStorage en el frontend** — No comparte estado entre usuarios ni sesiones; no persistible en el servidor.
