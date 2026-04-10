# CMA Factoria

Sistema de automatización para ejecución remota de comandos con arquitectura de microfrontends.

## Stack

| Componente | Tecnología | Puerto |
|------------|------------|--------|
| Backend | Quarkus 3 (Java 17) + RESTEasy Reactive | 8080 |
| MFE Principal | React 18 + Webpack Module Federation (host) | 3000 |
| MFE Commands | React 18 + Module Federation (remote) | 3001 |
| MFE Settings | React 18 + Module Federation (remote) | 3002 |
| MFE Dashboard | React 18 + Module Federation (remote) | 3003 |
| Shared Commands API | TypeScript generado desde `contracts/openapi/commands.yaml` | — |
| Shared Dashboard API | TypeScript generado desde `contracts/openapi/dashboard.yaml` | — |
| Shared Settings API | TypeScript generado desde `contracts/openapi/settings.yaml` | — |

## Estructura

```
.
├── CLAUDE.md                        # Contexto del proyecto para Claude Code
├── README.md
│
├── apps/
│   ├── backend/
│   │   └── command-service/         # Microservicio Quarkus (puerto 8080)
│   └── frontend/
│       ├── mfe-principal/           # Host MFE — navegación y layout (3000)
│       ├── mfe-commands/            # Remote MFE — gestión de comandos (3001)
│       ├── mfe-settings/            # Remote MFE — configuración (3002)
│       ├── mfe-dashboard/           # Remote MFE — métricas y actividad (3003)
│       ├── shared-commands-api/     # Cliente HTTP generado desde commands.yaml
│       ├── shared-dashboard-api/    # Cliente HTTP generado desde dashboard.yaml
│       └── shared-settings-api/     # Cliente HTTP generado desde settings.yaml
│
├── contracts/
│   └── openapi/
│       ├── commands.yaml            # Contrato API de comandos
│       ├── dashboard.yaml           # Contrato API de dashboard
│       └── settings.yaml           # Contrato API de configuración
│
├── scripts/
│   ├── backend/
│   │   ├── local_start.sh
│   │   └── local_stop.sh
│   └── frontend/
│       ├── local_start.sh
│       └── local_stop.sh
│
├── docs/                            # Documentación técnica
│   ├── architecture/                # ADRs
│   ├── backend/
│   ├── frontend/
│   ├── history/
│   └── scripts/
│
└── .claude/                         # Configuración Claude Code
    ├── agents/                      # Oscar, Ivan, Jester, Scout
    └── commands/                    # Skills como slash commands
```

## Desarrollo local

```bash
# Terminal 1 — Backend (Quarkus en puerto 8080)
./scripts/backend/local_start.sh

# Terminal 2 — Frontend (mfe-principal:3000 + remotos:3001-3003)
./scripts/frontend/local_start.sh
```

**Requisitos:** Java 17+, Maven 3.9+, Node.js 18+, puertos 8080 / 3000 / 3001 / 3002 / 3003 libres.

Accede a: `http://localhost:3000`

## Arquitectura Module Federation

```
mfePrincipal (3000)
  ├── mfeCommands  → http://localhost:3001/remoteEntry.js
  ├── mfeSettings  → http://localhost:3002/remoteEntry.js
  └── mfeDashboard → http://localhost:3003/remoteEntry.js
```

El MFE Principal actúa como host. Los MFEs remotos se cargan de forma lazy con `React.lazy()`.

## Contratos OpenAPI

Las especificaciones OpenAPI viven en `contracts/openapi/`. Cada contrato tiene su propia shared-api:

```bash
# Commands
cd apps/frontend/shared-commands-api && npm run generate && npm run build

# Dashboard
cd apps/frontend/shared-dashboard-api && npm run generate && npm run build

# Settings
cd apps/frontend/shared-settings-api && npm run generate && npm run build
```

Los MFEs importan desde su shared-api correspondiente:
- `mfe-commands` → `@cma-factoria/shared-commands-api`
- `mfe-dashboard` → `@cma-factoria/shared-dashboard-api`
- `mfe-settings` → `@cma-factoria/shared-settings-api`

## Agentes Claude Code

El proyecto tiene 4 agentes especializados en `.claude/agents/`:

| Agente | Rol |
|--------|-----|
| **Oscar** | Orquestador — coordina el flujo scout → ivan → jester |
| **Scout** | Investigador — analiza el repo y genera SPEC.md |
| **Ivan** | Implementador — escribe código según el SPEC |
| **Jester** | QA — valida builds, puertos y compliance |

La definición canónica de cada agente está en `.opencode/agent/`.

## Slash Commands

Disponibles como `/comando` en Claude Code (`.claude/commands/`):

| Comando | Propósito |
|---------|-----------|
| `/creative-ui-design` | Diseño UI dark industrial (Outfit + JetBrains Mono) |
| `/quarkus-backend` | Patrones de backend Quarkus + OpenAPI |
| `/frontend-api-integration` | Integración HTTP en MFEs |
| `/microfrontends-setup` | Configuración Module Federation |
| `/react-typescript` | Componentes y tipos React + TypeScript |

La definición canónica de cada skill está en `.opencode/skills/`.

## Instalación de herramientas AI

### Claude Code

CLI oficial de Anthropic para interactuar con Claude directamente desde la terminal.

**Requisitos:** Node.js 18+, suscripción Claude Pro/Max/Team o cuenta en Anthropic Console.

```bash
# macOS / Linux / WSL
curl -fsSL https://claude.ai/install.sh | bash

# macOS (Homebrew)
brew install --cask claude-code

# Windows (PowerShell)
irm https://claude.ai/install.ps1 | iex
```

**Primer uso:**

```bash
claude        # abre la sesión — solicita login automáticamente en el primer arranque
```

Las credenciales quedan almacenadas localmente. Para cambiar de cuenta: `/login` dentro de Claude Code.

El proyecto incluye configuración lista en `.claude/` (agentes, comandos) y `CLAUDE.md` (contexto del proyecto). Al abrir Claude Code en este directorio, todo el contexto se carga automáticamente.

---

### OpenCode

TUI de código abierto para desarrollo asistido por IA. Soporta múltiples proveedores (Anthropic, OpenAI, Google, etc.).

**Requisitos:** Terminal con soporte true color y Unicode (recomendados: WezTerm, Ghostty, Kitty, iTerm2).

```bash
# macOS / Linux
curl -fsSL https://opencode.ai/install | bash

# npm (cualquier plataforma)
npm install -g opencode-ai@latest

# macOS (Homebrew)
brew install opencode

# Windows (Scoop)
scoop install opencode
```

**Primer uso:**

```bash
opencode             # abre el TUI
opencode auth login  # configura el proveedor LLM y API key
```

**Instalar plugins del proyecto** (solo la primera vez):

```bash
cd .opencode
npm install
```

El proyecto incluye configuración en `.opencode/` — agentes (`agent/`), skills (`skills/`) y hooks (`hooks/`) se cargan automáticamente al abrir OpenCode en este directorio.

---

## Documentación

| Documento | Contenido |
|-----------|-----------|
| [command-service.md](docs/backend/command-service.md) | Backend REST API — comandos |
| [dashboard-service.md](docs/backend/dashboard-service.md) | Backend REST API — dashboard |
| [settings-service.md](docs/backend/settings-service.md) | Backend REST API — configuración |
| [mfe-principal.md](docs/frontend/mfe-principal.md) | MFE Principal (host) |
| [mfe-commands.md](docs/frontend/mfe-commands.md) | MFE Commands |
| [mfe-settings.md](docs/frontend/mfe-settings.md) | MFE Settings |
| [mfe-dashboard.md](docs/frontend/mfe-dashboard.md) | MFE Dashboard |
| [shared-commands-api.md](docs/frontend/shared-commands-api.md) | Shared Commands API |
| [shared-dashboard-api.md](docs/frontend/shared-dashboard-api.md) | Shared Dashboard API |
| [shared-settings-api.md](docs/frontend/shared-settings-api.md) | Shared Settings API |
| [adr-001](docs/architecture/adr-001-canal-comandos-remotos.md) | Decisión: Canal de comandos remotos |
| [scripts/backend.md](docs/scripts/backend.md) | Scripts de backend |
| [scripts/frontend.md](docs/scripts/frontend.md) | Scripts de frontend |
