# Scripts de Frontend

Scripts para el desarrollo local del frontend (React con Module Federation).

## Estructura

```
scripts/frontend/
├── local_start.sh    # Inicia todos los servicios
└── local_stop.sh     # Detiene todos los servicios
```

## local_start.sh

Inicia los servicios de frontend en background.

### Servicios

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| Shell | 3000 | Contenedor principal (host) |
| MFE Commands | 3001 | Microfrontend de comandos |
| MFE Settings | 3002 | Microfrontend de configuración |

### Proceso

1. Verifica que existan los directorios de cada app
2. Instala dependencias de shared-api, mfe-commands, mfe-settings, shell
3. Inicia los 3 MFEs en background
4. Maneja terminación con Ctrl+C

### Uso

```bash
./scripts/frontend/local_start.sh
```

Accede a: `http://localhost:3000`

## local_stop.sh

Detiene los servicios de frontend.

### Características

- Detiene procesos en puertos 3000, 3001, 3002
- Busca y mata procesos webpack restantes

### Uso

```bash
./scripts/frontend/local_stop.sh
```

## MFEs Disponibles

### Shell (Puerto 3000)

Contenedor principal que integra todos los microfrontends.
Navegación: Dashboard, Commands, Settings.

### MFE Commands (Puerto 3001)

Gestión de comandos de despliegue.
Expone: `./CommandsApp`

### MFE Settings (Puerto 3002)

Configuración de la aplicación.
Expone: `./SettingsApp`

## Requisitos

- Node.js 18+
- Puertos disponibles: 3000, 3001, 3002
- Dependencies: webpack, webpack-dev-server