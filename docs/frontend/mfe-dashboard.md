# MFE Dashboard — Microfrontend de Dashboard

## Descripción

Microfrontend remoto que muestra métricas del sistema y actividad reciente. Expone el componente `DashboardApp` para ser consumido por el MFE Principal. Integrado con el Dashboard Service del backend vía `@cma-factoria/shared-dashboard-api`.

## Ubicación

`apps/frontend/mfe-dashboard/`

## Puerto

- **Desarrollo**: 3003

## Stack

- React 18 + TypeScript 5.7
- Webpack 5 + Module Federation
- `@cma-factoria/shared-dashboard-api` — cliente generado desde `contracts/openapi/dashboard.yaml`

## Configuración Module Federation

```javascript
// webpack.config.js
new ModuleFederationPlugin({
  name: 'mfeDashboard',
  filename: 'remoteEntry.js',
  exposes: {
    './DashboardApp': './src/App',
  },
  shared: {
    react:       { singleton: true, requiredVersion: '^18.3.1', eager: true },
    'react-dom': { singleton: true, requiredVersion: '^18.3.1', eager: true },
    '@cma-factoria/shared-dashboard-api': { singleton: true, eager: true },
  },
})
```

## Integración con la API

El componente carga métricas y actividad en paralelo al montar:

```typescript
import { createClient, getDashboardMetrics, getDashboardActivity } from '@cma-factoria/shared-dashboard-api';

const client = createClient({ baseUrl: 'http://localhost:8080' });

const [metricsRes, activityRes] = await Promise.all([
  getDashboardMetrics({ client }),
  getDashboardActivity({ client }),
]);
```

## Datos mostrados

| Sección | Endpoint | Descripción |
|---------|----------|-------------|
| Stats grid | `GET /api/dashboard/metrics` | Contadores Pending / Processing / Completed / Failed |
| Activity feed | `GET /api/dashboard/activity` | Lista de eventos recientes con tipo, descripción y timestamp |

## Tipos de actividad

| Tipo | Badge | Color |
|------|-------|-------|
| `command-start` | START | amarillo |
| `command-complete` | OK | verde |
| `command-error` | ERR | rojo |
| `notification` | INFO | naranja |

## Estados UI

- **Loading**: spinner mientras carga datos iniciales
- **Error**: mensaje de error con botón "Reintentar"
- **Empty activity**: la sección de actividad no aparece si la lista está vacía

## Patrón Bootstrap

Usa el patrón obligatorio de Module Federation:

```
src/index.tsx    → import('./bootstrap')   ← dynamic import
src/bootstrap.tsx → createRoot + render    ← aquí renderiza
```

## Desarrollo

```bash
# 1. Compilar la shared API primero
cd apps/frontend/shared-dashboard-api && npm run build

# 2. Arrancar el MFE
cd apps/frontend/mfe-dashboard
npm install
npm run dev    # http://localhost:3003
npm run build
```

## Dependencias

```json
{
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "@cma-factoria/shared-dashboard-api": "file:../shared-dashboard-api"
  }
}
```
