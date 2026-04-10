# Shared Settings API

## Descripción

Módulo TypeScript generado automáticamente desde `contracts/openapi/settings.yaml` usando `@hey-api/openapi-ts`. Proporciona tipos y funciones HTTP con type-safety completo para el Settings Service.

## Ubicación

`apps/frontend/shared-settings-api/`

## Funciones API generadas

| Función | Método | Endpoint |
|---------|--------|----------|
| `getSettings` | GET | `/settings` |
| `getGeneralSettings` | GET | `/settings/general` |
| `updateGeneralSettings` | PATCH | `/settings/general` |
| `getApiSettings` | GET | `/settings/api` |
| `updateApiSettings` | PATCH | `/settings/api` |
| `getNotificationSettings` | GET | `/settings/notifications` |
| `updateNotificationSettings` | PATCH | `/settings/notifications` |

## Tipos generados

- `GeneralSettings` — `{ applicationName, environment, timezone }`
- `ApiSettings` — `{ apiBaseUrl, apiTimeoutMs, enableApiCaching }`
- `NotificationSettings` — `{ emailOnCommandCompletion, pushOnError, weeklySummaryEnabled }`
- `SettingsResponse` — `{ general, api, notifications }`

## Uso en MFE

```typescript
import {
  createClient,
  getGeneralSettings,
  updateGeneralSettings,
  type GeneralSettings,
} from '@cma-factoria/shared-settings-api';

const client = createClient({ baseUrl: 'http://localhost:8080' });

// Leer
const res = await getGeneralSettings({ client });
const settings: GeneralSettings = res.data;

// Actualizar (body:, no data:)
await updateGeneralSettings({ client, body: settings });
```

## Ciclo de vida

```bash
# Generar src/ desde el contrato OpenAPI
npm run generate   # lee contracts/openapi/settings.yaml

# Compilar a dist/
npm run build

# Limpiar (src/ + dist/)
npm run clean
```

> `npm run clean` elimina **tanto `src/` como `dist/`**. Ejecutar `generate` + `build` tras hacer clean.

## Dependencias

```json
{
  "devDependencies": {
    "typescript": "^5.7.2",
    "@hey-api/openapi-ts": "^0.94.4"
  }
}
```
