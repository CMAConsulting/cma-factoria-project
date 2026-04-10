# MFE Settings — Microfrontend de Configuración

## Descripción

Microfrontend remoto para la configuración de la aplicación. Expone el componente `SettingsApp` para ser consumido por el Shell.

## Ubicación

`apps/frontend/mfe-settings/`

## Puerto

- **Desarrollo**: 3002

## Stack

- React 18 + TypeScript 5.7
- Webpack 5 + Module Federation

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
    react: { singleton: true, requiredVersion: '^18.3.1' },
    'react-dom': { singleton: true, requiredVersion: '^18.3.1' },
  },
})
```

## Tabs disponibles

| Tab | Campos |
|-----|--------|
| **General** | Application Name, Environment (dev/staging/prod), Timezone |
| **API** | API Base URL, API Timeout (ms), Enable API Caching |
| **Notifications** | Email on completion, Push on errors, Weekly summary |

## Diseño

Hereda el sistema de diseño del shell mediante variables CSS:

- Sin `border-radius` (estética industrial)
- Tabs con underline naranja activo (no azul/indigo)
- Inputs y selects con tipografía `JetBrains Mono`, sin border-radius
- Select con flecha SVG custom (sin `appearance: auto`)
- Botón "Save Changes": outlined naranja, fill al hover
- Labels en uppercase con `letter-spacing`

## Desarrollo

```bash
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
    "react-dom": "^18.3.1"
  },
  "devDependencies": {
    "webpack": "^5.97.1",
    "webpack-dev-server": "^5.2.0",
    "typescript": "^5.7.2",
    "ts-loader": "^9.5.1"
  }
}
```

## Notas

- Los formularios son estáticos (sin persistencia en backend por ahora)
- Puede ejecutarse de forma independiente en `http://localhost:3002`
