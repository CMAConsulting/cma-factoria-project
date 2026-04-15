# CMA Factoria

Sistema de automatización para ejecución remota de comandos con arquitectura de microfrontends.

## Stack

| Componente | Tecnología | Puerto |
|------------|------------|--------|
| Backend | Quarkus 3 (Java 21) + RESTEasy Reactive | 8080 |
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
│   ├── latex/
│   └── scripts/
│
├── .opencode/                       # Configuración OpenCode
│   ├── agent/                       # 9 agentes especializados
│   ├── skills/                      # Conocimiento especializado
│   └── hooks/                       # Validaciones pre-commit
│
├── .claude/                         # Configuración Claude Code
│   ├── agents/                      # Alias de agentes
│   └── commands/                    # Skills como slash commands
```

## Desarrollo local

```bash
# Terminal 1 — Backend (Quarkus en puerto 8080)
./scripts/backend/local_start.sh

# Terminal 2 — Frontend (mfe-principal:3000 + remotos:3001-3003)
./scripts/frontend/local_start.sh
```

**Requisitos:** Java 21+, Maven 3.9+, Node.js 18+, puertos 8080 / 3000 / 3001 / 3002 / 3003 libres.

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

## Agentes OpenCode

El proyecto tiene 9 agentes especializados en `.opencode/agent/`:

| Agente | Rol | Responsabilidades |
|--------|-----|------------------|
| **Product Owner** | Orquestador | Coordina el SDLC, delega tareas, mantiene trazabilidad |
| **Optimizer** | Investigador | Analiza código, genera SPEC.md, documenta estructura |
| **Dev Senior** | Implementador | Código siguiendo SPEC.md, sigue patrones del proyecto |
| **Backend Senior** | Implementador Backend | Quarkus/Java, CORS, PostgreSQL, troubleshooting |
| **Frontend Senior** | Implementador Frontend | React/TypeScript/MFEs, Module Federation |
| **QA Senior** | Validador | Pruebas adversariales, builds, compliance |
| **Database Operator** | Ingeniero BD | Tablas, stored procedures, índices PostgreSQL |
| **Bash Specialist** | Script Developer | Scripts Bash, soporte --profile, scripts/commons/ |
| **UML-Spec** | Modelador | Diagramas UML PlantUML, conversión OpenAPI |

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

El proyecto incluye configuración en `.opencode/` — agentes (9 roles especializados), skills (`skills/`) y hooks (`hooks/`) se cargan automáticamente al abrir OpenCode en este directorio.

---

## Documentación

| Documento | Contenido |
|-----------|-----------|
| [cma-factoria.tex](docs/latex/cma-factoria.tex) | Documento LaTeX para presentaciones (PDF) |
| [references.bib](docs/latex/references.bib) | Bibliografía BibTeX con 15 referencias académicas |
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

### Compilación del Documento LaTeX

```bash
cd docs/latex
pdflatex cma-factoria.tex
biber cma-factoria
pdflatex cma-factoria.tex
pdflatex cma-factoria.tex
```

### Referencias Académicas Verificadas

El documento LaTeX incluye 15 referencias académicas con enlaces verificados:

| # | Referencia | URL |
|---|-----------|-----|
| 1 | Peng et al. (2023) - GitHub Copilot Impact | [arXiv:2302.06590](https://arxiv.org/abs/2302.06590) |
| 2 | Cui et al. (2024) - Field Experiment | [MIT PubPub](https://mit-genai.pubpub.org/pub/v5iixksv/release/2) |
| 3 | Ziegler et al. (2024) - CACM | [ACM CACM](https://cacm.acm.org/research/measuring-github-copilots-impact-on-productivity/) |
| 4 | Smit et al. (2024) - AMCIS BMW | [AISNet](https://aisel.aisnet.org/amcis2024/ai_aa/ai_aa/10) |
| 5 | Pandey (2024) - Real-World Projects | [NASA ADS](https://ui.adsabs.harvard.edu/abs/2024arXiv240617910P/abstract) |
| 6 | Trandafir (2024) - Vertical Slice | [Baeldung](https://www.baeldung.com/java-vertical-slice-architecture) |
| 7 | Yakhin (2024) - Comparative Review | [IJAIR](https://aimjournals.com/index.php/ijaair/article/view/413) |
| 8 | Mane et al. (2024) - Micro Frontends | [ResearchGate](https://www.researchgate.net/publication/388841942) |
| 9 | Antunes (2024) - SBES Migration | [arXiv:2407.15829](https://arxiv.org/pdf/2407.15829) |
| 10 | Lando & Hasselbring (2025) - BIMF | [arXiv:2501.18225](https://arxiv.org/abs/2501.18225) |
| 11 | Hossain (2026) - Contract-First API | [mdsanwarhossain.me](https://mdsanwarhossain.me/blog-contract-first-openapi.html) |
| 12 | Sturgeon (2025) - OpenAPI Workflow | [Bump.sh](https://docs.bump.sh/guides/openapi/specification/v3.1/the-perfect-modern-openapi-workflow) |
| 13 | Franchin (2025) - Quarkus Benchmark | [ITNEXT](https://itnext.io/performance-benchmark-spring-boot-3-4-3-vs-quarkus-3-19-3-vs-micronaut-4-7-6-aaadfb0382b4) |
| 14 | Microsoft (2024) - Magentic-One | [MSR](https://www.microsoft.com/en-us/research/publication/magentic-one-a-generalist-multi-agent-system-for-solving-complex-tasks/) |
| 15 | He et al. (2025) - LLM Multi-Agent SE | [arXiv:2404.04834](https://arxiv.org/pdf/2404.04834) |
