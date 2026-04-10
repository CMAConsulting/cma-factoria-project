# CMA Factoria - Documentación del Proyecto

Sistema de automatización para ejecución remota de comandos con arquitectura de microfrontends.

## Visión General

| Componente | Tecnología | Puerto |
|------------|------------|--------|
| Backend | Quarkus (Java 17) | 8080 |
| Frontend Shell | React 18 + Webpack MF | 3000 |
| MFE Commands | React 18 + Module Federation | 3001 |
| MFE Settings | React 18 + Module Federation | 3002 |
| Shared API | TypeScript + @hey-api/openapi-ts | - |

## Estructura de Documentación

```
docs/
├── architecture/         # Architectural Decision Records (ADRs)
├── backend/             # Documentación del backend
├── frontend/            # Documentación del frontend
├── history/             # Registro de planificación
├── scripts/             # Scripts de automatización
└── README.md            # Este archivo
```

---

## Backend

### Command Service

**Ubicación:** `apps/backend/command-service/`

Microservicio REST para gestión de comandos remotos.

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/commands` | POST | Crear comando |
| `/api/commands` | GET | Listar comandos |
| `/api/commands/{id}` | GET | Consultar estado |
| `/api/commands/{id}/result` | GET | Obtener resultado |

**Tecnologías:**
- Quarkus 3.6.4
- RESTEasy Reactive
- OpenAPI Generator

**Ver:** [command-service.md](docs/backend/command-service.md)

---

## Frontend

### Shell (Puerto 3000)

Contenedor principal que integra los microfrontends.

**Características:**
- Navegación: Dashboard, Commands, Settings
- Diseño dark empresarial
- Carga lazy de MFEs

**Ver:** [shell.md](docs/frontend/shell.md)

### MFE Commands (Puerto 3001)

Microfrontend de gestión de comandos.

**Características:**
- Lista de comandos con estados
- Crear nuevos comandos
- Integración con shared-api

**Ver:** [mfe-commands.md](docs/frontend/mfe-commands.md)

### MFE Settings (Puerto 3002)

Microfrontend de configuración.

**Características:**
- Tabs: General, API, Notifications
- Formularios de configuración

### Shared API

Módulo TypeScript con tipos generados desde OpenAPI.

**Ver:** [shared-api.md](docs/frontend/shared-api.md)

---

## Contratos API

**Especificación:** `contracts/openapi/commands.yaml`

Generación automática de tipos con `@hey-api/openapi-ts`.

---

## Scripts

### Desarrollo Local

```bash
# Terminal 1 - Backend
./scripts/backend/local_start.sh

# Terminal 2 - Frontend
./scripts/frontend/local_start.sh
```

**Puertos:** 8080 (backend), 3000/3001/3002 (frontend)

**Ver:** [scripts/README.md](scripts/README.md)

---

## Arquitectura

### Module Federation

```
shell (3000) ───┬──> mfeCommands (3001)
               └──> mfeSettings (3002)
```

- **Shell**: Contenedor (host)
- **MFEs**: Remotos (remotes)
- **Shared**: Dependencias compartidas (react, react-dom)

### Decisiones de Arquitectura

**Ver:** [architecture/adr-001-canal-comandos-remotos.md](docs/architecture/adr-001-canal-comandos-remotos.md)

---

## Historial

Registro de planificación del proyecto.

**Ver:** [history/PLAN.md](docs/history/PLAN.md)

---

## Requisitos

- **Backend:** Java 17+, Maven 3.9+
- **Frontend:** Node.js 18+, npm
- **Puertos:** 8080, 3000, 3001, 3002 disponibles