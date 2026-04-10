# Shared Dashboard API

## Descripción

Módulo TypeScript generado automáticamente desde `contracts/openapi/dashboard.yaml` usando `@hey-api/openapi-ts`. Proporciona tipos y funciones HTTP con type-safety completo para el Dashboard Service.

## Ubicación

`apps/frontend/shared-dashboard-api/`

## Funciones API generadas

| Función | Método | Endpoint |
|---------|--------|----------|
| `getDashboardMetrics` | GET | `/dashboard/metrics` |
| `getDashboardActivity` | GET | `/dashboard/activity` |

## Tipos generados

- `DashboardMetrics` — `{ pending, processing, completed, failed: number }`
- `DashboardActivity` — `ActivityItem[]`
- `ActivityItem` — `{ id, timestamp, type, description, userId?, metadata? }`

## Uso en MFE

```typescript
import {
  createClient,
  getDashboardMetrics,
  getDashboardActivity,
  type DashboardMetrics,
  type ActivityItem,
} from '@cma-factoria/shared-dashboard-api';

const client = createClient({ baseUrl: 'http://localhost:8080' });

const metricsRes = await getDashboardMetrics({ client });
const metrics: DashboardMetrics = metricsRes.data;
```

## Ciclo de vida

```bash
# Generar src/ desde el contrato OpenAPI
npm run generate   # lee contracts/openapi/dashboard.yaml

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
