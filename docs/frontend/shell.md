# Shell — Contenedor Principal

## Descripción

Host MFE que actúa como contenedor de toda la aplicación. Provee el layout (sidebar + header), navegación entre páginas y carga lazy de los microfrontends remotos.

## Ubicación

`apps/frontend/shell/`

## Puerto

- **Desarrollo**: 3000

## Stack

- React 18 + TypeScript 5.7
- Webpack 5 + Module Federation
- Diseño dark industrial: `Outfit` (UI) + `JetBrains Mono` (código/monoespaciado)

## Configuración Module Federation

```javascript
// webpack.config.js
new ModuleFederationPlugin({
  name: 'shell',
  filename: 'remoteEntry.js',
  remotes: {
    mfeCommands: 'mfeCommands@http://localhost:3001/remoteEntry.js',
    mfeSettings: 'mfeSettings@http://localhost:3002/remoteEntry.js',
  },
  shared: {
    react: { singleton: true, requiredVersion: '^18.3.1' },
    'react-dom': { singleton: true, requiredVersion: '^18.3.1' },
  },
})
```

## Type Declarations

Los módulos remotos se declaran en `src/types.d.ts`:

```typescript
declare module 'mfeCommands/CommandsApp';
declare module 'mfeSettings/SettingsApp';
```

## Estructura de Navegación

El shell gestiona tres páginas vía estado local (`currentPage: 'dashboard' | 'commands' | 'settings'`):

| Página | Componente cargado | Descripción |
|--------|-------------------|-------------|
| `dashboard` | Stats grid + MfeCommands inline | Vista por defecto |
| `commands` | MfeCommands pantalla completa | — |
| `settings` | MfeSettings | — |

## Diseño

- Sidebar fijo de 240px (64px en responsive — solo iconos visibles)
- Header sticky con título de página y breadcrumb
- Stats grid de 4 cards en el dashboard (Pending / Processing / Completed / Failed)
- Iconos SVG inline (sin emojis, sin dependencias de icon library)
- Paleta: `#050505` fondo, `#ff6b35` accent naranja, `#fafafa` texto
- Fuentes: Outfit + JetBrains Mono (Google Fonts)
- Textura noise sutil en el body (SVG data URL, `opacity: 0.03`)

## Consumo de Microfrontends

```tsx
const MfeCommands = lazy(() => import('mfeCommands/CommandsApp'));
const MfeSettings = lazy(() => import('mfeSettings/SettingsApp'));

// Cada MFE envuelto en Suspense con fallback de loading
<Suspense fallback={<div className="loading-state"><div className="spinner"/></div>}>
  <MfeCommands />
</Suspense>
```

## Desarrollo

```bash
cd apps/frontend/shell
npm install
npm run dev    # http://localhost:3000
npm run build
```

**Nota:** Requiere que `mfe-commands` (3001) y `mfe-settings` (3002) estén corriendo para cargar los remotes.

## Dependencias principales

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
