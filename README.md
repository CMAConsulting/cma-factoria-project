# CMA Factoria

Sistema de automatización para ejecución remota de comandos con arquitectura de microfrontends.

## Stack

| Componente | Tecnología | Puerto |
|------------|------------|--------|
| Backend | Quarkus 3 (Java 17) + RESTEasy Reactive | 8080 |
| Frontend Shell | React 18 + Webpack Module Federation (host) | 3000 |
| MFE Commands | React 18 + Module Federation (remote) | 3001 |
| MFE Settings | React 18 + Module Federation (remote) | 3002 |
| Shared API | TypeScript generado desde OpenAPI (`@hey-api/openapi-ts`) | — |

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
│       ├── shell/                   # Host MFE — navegación y layout (3000)
│       ├── mfe-commands/            # Remote MFE — gestión de comandos (3001)
│       ├── mfe-settings/            # Remote MFE — configuración (3002)
│       └── shared-api/              # Cliente HTTP generado desde OpenAPI
│
├── contracts/
│   └── openapi/
│       └── commands.yaml            # Fuente de verdad de la API
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

# Terminal 2 — Frontend (shell:3000 + mfe-commands:3001 + mfe-settings:3002)
./scripts/frontend/local_start.sh
```

**Requisitos:** Java 17+, Maven 3.9+, Node.js 18+, puertos 8080 / 3000 / 3001 / 3002 libres.

Accede a: `http://localhost:3000`

## Arquitectura Module Federation

```
shell (3000)
  ├── mfeCommands → http://localhost:3001/remoteEntry.js
  └── mfeSettings → http://localhost:3002/remoteEntry.js
```

El Shell actúa como host. Los MFEs son remotos que se cargan de forma lazy con `React.lazy()`.

## API Contract

La especificación OpenAPI vive en `contracts/openapi/commands.yaml`. Los tipos TypeScript se generan automáticamente:

```bash
cd apps/frontend/shared-api
npm run generate   # regenera desde commands.yaml
npm run build      # compila a dist/
```

Los MFEs importan desde `@cma-factoria/shared-api`.

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
| [command-service.md](docs/backend/command-service.md) | Backend REST API |
| [shell.md](docs/frontend/shell.md) | Shell (host MFE) |
| [mfe-commands.md](docs/frontend/mfe-commands.md) | MFE Commands |
| [mfe-settings.md](docs/frontend/mfe-settings.md) | MFE Settings |
| [shared-api.md](docs/frontend/shared-api.md) | Cliente OpenAPI generado |
| [adr-001](docs/architecture/adr-001-canal-comandos-remotos.md) | Decisión: Canal de comandos remotos |
| [scripts/backend.md](docs/scripts/backend.md) | Scripts de backend |
| [scripts/frontend.md](docs/scripts/frontend.md) | Scripts de frontend |
