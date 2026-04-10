# MFE Settings — Microfrontend de Configuración

## Descripción

Microfrontend remoto para la configuración de la aplicación. Expone el componente `SettingsApp` para ser consumido por el MFE Principal. Integrado con el Settings Service del backend vía `@cma-factoria/shared-settings-api`.

## Ubicación

`apps/frontend/mfe-settings/`

## Puerto

- **Desarrollo**: 3002

## Stack

- React 18 + TypeScript 5.7
- Webpack 5 + Module Federation
- `@cma-factoria/shared-settings-api` — cliente generado desde `contracts/openapi/settings.yaml`

## Configuración Module Federation

```javascript
// webpack.config.js
new ModuleFederationPlugin({
  name: 'mfeSettings',
  filename: 'remoteEntry.js',
  exposes: {
    './SettingsApp': './src/App',
  },
  shared: {
    react:       { singleton: true, requiredVersion: '^18.3.1', eager: true },
    'react-dom': { singleton: true, requiredVersion: '^18.3.1', eager: true },
    '@cma-factoria/shared-settings-api': { singleton: true, eager: true },
  },
})
```

## Integración con la API

El componente carga la configuración real en mount y persiste los cambios al backend:

```typescript
import { createClient, getGeneralSettings, updateGeneralSettings } from '@cma-factoria/shared-settings-api';

const client = createClient({ baseUrl: 'http://localhost:8080' });

// Al montar: carga las 3 secciones en paralelo
const [genRes, apiRes, notifRes] = await Promise.all([
  getGeneralSettings({ client }),
  getApiSettings({ client }),
  getNotificationSettings({ client }),
]);

// Al guardar: PATCH de la sección activa
await updateGeneralSettings({ client, body: general });
```

## Tabs disponibles

| Tab | Campos | Endpoint PATCH |
|-----|--------|----------------|
| **General** | Application Name, Environment (dev/staging/prod), Timezone | `/api/settings/general` |
| **API** | API Base URL, API Timeout (ms), Enable API Caching | `/api/settings/api` |
| **Notifications** | Email on completion, Push on errors, Weekly summary | `/api/settings/notifications` |

## Estados UI

- **Loading**: spinner mientras carga la configuración inicial
- **Error**: mensaje de error con botón "Reintentar"
- **Saving**: botón deshabilitado con texto "Saving..."
- **Saved**: confirmación visual durante 2 segundos tras guardar exitosamente

## Diseño

Hereda el sistema de diseño del MFE Principal mediante variables CSS:

- Sin `border-radius` (estética industrial)
- Tabs con underline naranja activo
- Inputs y selects con tipografía `JetBrains Mono`, sin border-radius
- Select con flecha SVG custom
- Botón "Save Changes": outlined naranja, fill al hover
- Labels en uppercase con `letter-spacing`

## Patrón Bootstrap

Usa el patrón obligatorio de Module Federation para evitar errores de shared scope:

```
src/index.tsx   → import('./bootstrap')   ← dynamic import
src/bootstrap.tsx → createRoot + render   ← aquí renderiza
```

## Desarrollo

```bash
# 1. Compilar la shared API primero
cd apps/frontend/shared-settings-api && npm run build

# 2. Arrancar el MFE
cd apps/frontend/mfe-settings
npm install
npm run dev    # http://localhost:3002
npm run build
```

## Dependencias

```json
{
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "@cma-factoria/shared-settings-api": "file:../shared-settings-api"
  }
}
```
