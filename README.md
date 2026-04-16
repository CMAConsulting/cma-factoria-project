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
├── apps/
│   ├── backend/
│   │   ├── command-api-ms/          # Microservicio Quarkus native (puerto 8080)
│   │   ├── dashboard-api-ms/        # Microservicio dashboard (puerto 8081)
│   │   └── settings-api-ms/         # Microservicio settings (puerto 8082)
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
├── infra/
│   ├── database/
│   │   ├── command-db/              # Tablas y stored procedures de commands
│   │   ├── dashboard-db/            # Tablas y stored procedures de dashboard
│   │   └── settings-db/             # Tablas y stored procedures de settings
│   ├── docker/
│   │   └── command-docker/
│   │       └── Dockerfile           # Multi-stage build: Mandrel → UBI micro
│   └── k8s/
│       └── command-api-ms/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── configmap.yaml
│           ├── secret.yaml
│           └── kustomization.yaml
│
├── scripts/
│   ├── commons/                     # Funciones reutilizables (log, get, check, wait)
│   ├── backend/                     # local_start.sh / local_stop.sh
│   ├── frontend/                    # local_start.sh / local_stop.sh
│   ├── docker/
│   │   ├── backend/
│   │   │   ├── modules/             # container.sh, image.sh
│   │   │   └── command-api-ms/      # build.sh, run.sh
│   │   └── database/
│   │       ├── modules/             # postgres.sh, volume.sh
│   │       └── postgresql.sh
│   ├── k8s/
│   │   └── command-api-ms/          # configure.sh, run.sh
│   ├── database/                    # impact_*.sh — aplica SQL al esquema
│   ├── jmeter/                      # install.sh, command-api-ms/start.sh
│   └── latex/                       # compile-pdf.sh, compile-puml.sh
│
├── tests/
│   └── jmeter/                      # Planes de prueba .jmx
│
└── docs/                            # Documentación técnica
    ├── architecture/                # ADRs e integraciones
    ├── backend/                     # APIs REST por servicio
    ├── database/                    # Esquemas por base de datos
    ├── frontend/                    # MFEs y shared APIs
    ├── scripts/                     # Guías de scripts
    ├── jmeter/                      # Pruebas de carga
    ├── sequence/                    # Diagramas PlantUML
    └── uml/                         # Diagramas de arquitectura
```

## Desarrollo local

```bash
# Terminal 1 — Backend (Quarkus en puerto 8080)
./scripts/backend/local_start.sh

# Terminal 2 — Frontend (mfe-principal:3000 + remotos:3001-3003)
./scripts/frontend/local_start.sh
```

**Requisitos:** Java 21+, Maven 3.9+, Node.js 18+, puertos 8080 / 3000–3003 libres.

Accede a: `http://localhost:3000`

## Build del microservicio

### JVM (rápido, para desarrollo)

```bash
cd apps/backend/command-api-ms
./mvnw clean package -DskipTests
```

### Nativo (producción)

Genera un ejecutable Linux nativo usando el contenedor Mandrel. Requiere Docker.

```bash
cd apps/backend/command-api-ms
./mvnw package -Pnative -DskipTests -Dquarkus.native.container-build=true
# Resultado: target/command-api-ms-1.0.0-SNAPSHOT-runner (~65 MB, arranque ~14 ms)
```

## Docker

### Build de imagen nativa

```bash
# Construye la imagen multi-stage (Mandrel builder → UBI micro)
bash scripts/docker/backend/command-api-ms/build.sh

# Con perfil específico
bash scripts/docker/backend/command-api-ms/build.sh --profile staging

# Build + push al registry
bash scripts/docker/backend/command-api-ms/build.sh --upload
```

### Gestión del contenedor

```bash
bash scripts/docker/backend/command-api-ms/run.sh --start
bash scripts/docker/backend/command-api-ms/run.sh --stop
bash scripts/docker/backend/command-api-ms/run.sh --remove
bash scripts/docker/backend/command-api-ms/run.sh --logs        # últimas 20 líneas
bash scripts/docker/backend/command-api-ms/run.sh --logs 50
bash scripts/docker/backend/command-api-ms/run.sh --tail        # seguir logs en vivo
```

### Base de datos PostgreSQL (Docker)

```bash
bash scripts/docker/database/postgresql.sh init     # crea volumen y contenedor
bash scripts/docker/database/postgresql.sh start
bash scripts/docker/database/postgresql.sh stop
bash scripts/docker/database/postgresql.sh status
bash scripts/docker/database/postgresql.sh test     # valida conectividad
bash scripts/docker/database/postgresql.sh remove
```

Ver: [docs/scripts/docker.md](docs/scripts/docker.md)

## Kubernetes

### Configurar manifiestos

Genera los YAMLs con los valores del perfil seleccionado:

```bash
bash scripts/k8s/command-api-ms/configure.sh --profile dev
bash scripts/k8s/command-api-ms/configure.sh --profile prod
```

### Despliegue

```bash
bash scripts/k8s/command-api-ms/run.sh apply       # despliega todos los recursos
bash scripts/k8s/command-api-ms/run.sh status      # estado de pods y deployment
bash scripts/k8s/command-api-ms/run.sh logs        # logs del pod activo
bash scripts/k8s/command-api-ms/run.sh tail        # seguir logs en vivo
bash scripts/k8s/command-api-ms/run.sh events      # eventos recientes
bash scripts/k8s/command-api-ms/run.sh stop        # escala a 0 réplicas
bash scripts/k8s/command-api-ms/run.sh remove      # elimina todos los recursos
```

El namespace de despliegue es `synopsis-ws` (configurable en `kustomization.yaml`).

Ver: [docs/scripts/k8s.md](docs/scripts/k8s.md)

## Base de datos

Los esquemas SQL viven en `infra/database/`. Para aplicarlos al contenedor activo:

```bash
bash scripts/database/impact_command_db.sh
bash scripts/database/impact_dashboard_db.sh
bash scripts/database/impact_settings_db.sh
```

Estructura de cada base:

| Base | Tablas | Stored Procedures |
|------|--------|-------------------|
| `command_db` | `commands`, `command_results` | 5 SPs (insert, get, list, result, count) |
| `dashboard_db` | `dashboard_metrics`, `dashboard_activity` | 2 SPs |
| `settings_db` | `settings_general`, `settings_api_config` | 2 SPs |

## Arquitectura Module Federation

```
mfePrincipal (3000)
  ├── mfeCommands  → http://localhost:3001/remoteEntry.js
  ├── mfeSettings  → http://localhost:3002/remoteEntry.js
  └── mfeDashboard → http://localhost:3003/remoteEntry.js
```

El MFE Principal actúa como host con `eager: true` en dependencias compartidas. Los MFEs remotos usan el patrón bootstrap obligatorio (`index.tsx` → dynamic import → `bootstrap.tsx`).

## Contratos OpenAPI

`contracts/openapi/` es la única fuente de verdad del contrato. Se consume en dos direcciones:

- **Backend:** `./mvnw clean compile` genera modelos Java en `target/generated-sources/`
- **Frontend:** `npm run generate` en cada `shared-*-api/` genera el cliente TypeScript

```bash
# Commands
cd apps/frontend/shared-commands-api && npm run generate && npm run build

# Dashboard
cd apps/frontend/shared-dashboard-api && npm run generate && npm run build

# Settings
cd apps/frontend/shared-settings-api && npm run generate && npm run build
```

## Pruebas de carga (JMeter)

```bash
# Instalar plugins (primera vez)
bash scripts/jmeter/install.sh

# Ejecutar escenario (perfil dev por defecto)
bash scripts/jmeter/command-api-ms/start.sh

# Ejecutar con perfil staging
bash scripts/jmeter/command-api-ms/start.sh --profile staging

# Ejecutar escenario específico
bash scripts/jmeter/command-api-ms/start.sh --jmeter-file scenarie-001

# Abrir en modo GUI
bash scripts/jmeter/command-api-ms/start.sh --gui

# Limpiar resultados anteriores
bash scripts/jmeter/command-api-ms/start.sh --clear

# Generar dashboard HTML desde el último .jtl
bash scripts/jmeter/command-api-ms/dashboard.sh
bash scripts/jmeter/command-api-ms/dashboard.sh --jmeter-file scenarie-001
```

Resultados en `.tmp/jmeter/command-api-ms/`. Objetivo: 14.500 TPS, error rate 0%, latencia P99 ≤ 500 ms.

Ver: [docs/test/jmeter/command-api-ms.md](docs/test/jmeter/command-api-ms.md)

## Agentes

| Agente | Rol | Cuándo usarlo |
|--------|-----|---------------|
| **Oscar** | Orquestador | Features completos que necesitan scout→ivan→jester |
| **Scout** | Investigador | Analizar código y generar SPEC.md |
| **Ivan** | Implementador | Escribir código según un plan/SPEC |
| **Jester** | QA / Validador | Verificar builds, puertos y compliance con SPEC |
| **DBForge** | Base de datos | Crear o modificar tablas, SPs e índices PostgreSQL |

Definidos en `.claude/agents/`. La fuente canónica está en `.opencode/agent/`.

## Slash Commands

| Comando | Propósito |
|---------|-----------|
| `/creative-ui-design` | Diseño UI dark industrial (Outfit + JetBrains Mono) |
| `/quarkus-backend` | Patrones de backend Quarkus + OpenAPI |
| `/frontend-api-integration` | Integración HTTP en MFEs |
| `/microfrontends-setup` | Configuración Module Federation |
| `/react-typescript` | Componentes y tipos React + TypeScript |

## Instalación de herramientas AI

### Claude Code

```bash
# macOS / Linux / WSL
curl -fsSL https://claude.ai/install.sh | bash
```

```bash
claude  # abre la sesión — solicita login automáticamente en el primer arranque
```

### OpenCode

```bash
curl -fsSL https://opencode.ai/install | bash
opencode auth login
```

```bash
# Instalar plugins del proyecto (solo la primera vez)
cd .opencode && npm install
```

## Documentación

| Documento | Contenido |
|-----------|-----------|
| [command-api-ms.md](docs/backend/command-api-ms.md) | Backend REST API — comandos |
| [dashboard-service.md](docs/backend/dashboard-service.md) | Backend REST API — dashboard |
| [settings-service.md](docs/backend/settings-service.md) | Backend REST API — configuración |
| [command-db.md](docs/database/command-db.md) | Esquema command_db |
| [dashboard-db.md](docs/database/dashboard-db.md) | Esquema dashboard_db |
| [settings-db.md](docs/database/settings-db.md) | Esquema settings_db |
| [mfe-principal.md](docs/frontend/mfe-principal.md) | MFE Principal (host) |
| [mfe-commands.md](docs/frontend/mfe-commands.md) | MFE Commands |
| [mfe-settings.md](docs/frontend/mfe-settings.md) | MFE Settings |
| [mfe-dashboard.md](docs/frontend/mfe-dashboard.md) | MFE Dashboard |
| [docker.md](docs/scripts/docker.md) | Scripts Docker — build, run, postgresql |
| [k8s.md](docs/scripts/k8s.md) | Scripts Kubernetes — configure, deploy |
| [backend.md](docs/scripts/backend.md) | Scripts de desarrollo local backend |
| [frontend.md](docs/scripts/frontend.md) | Scripts de desarrollo local frontend |
| [command-api-ms.md](docs/test/jmeter/command-api-ms.md) | Plan de pruebas de carga JMeter |
| [adr-001](docs/architecture/adr-001-canal-comandos-remotos.md) | ADR: Canal de comandos remotos |
| [cma-factoria.tex](docs/latex/cma-factoria.tex) | Documento LaTeX (PDF) |

### Compilación LaTeX

```bash
cd docs/latex
pdflatex cma-factoria.tex && biber cma-factoria && pdflatex cma-factoria.tex
```
