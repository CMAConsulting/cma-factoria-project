# PLAN.md — Historial de Planificación

---

## Plan 001 — Scaffolding Inicial

**Fecha:** 2026-04-09
**Estado:** Completado

### Objetivo

Implementar la arquitectura base del proyecto desde cero.

### Fases ejecutadas

#### Fase 1: Análisis (Scout)
- [x] Determinar tipo de proyecto: webapp de gestión de comandos remotos
- [x] Definir stack: Quarkus backend + React MFE frontend
- [x] Generar especificación de la API REST

#### Fase 2: Scaffolding (Ivan)
- [x] Backend: `apps/backend/command-service/` con Quarkus 3.6.4
  - Endpoints REST: POST/GET `/api/commands`, GET `/api/commands/{id}`, GET `/api/commands/{id}/result`
  - Almacenamiento en memoria (ConcurrentHashMap)
  - OpenAPI spec en `contracts/openapi/commands.yaml`
- [x] Frontend Shell: `apps/frontend/shell/` — host MFE con Module Federation
- [x] MFE Commands: `apps/frontend/mfe-commands/` — remote MFE (puerto 3001)
- [x] Shared API: `apps/frontend/shared-api/` — tipos TypeScript generados desde OpenAPI
- [x] Scripts de desarrollo: `scripts/backend/` y `scripts/frontend/`
- [x] Documentación inicial en `docs/`

#### Fase 3: Validación (Jester)
- [x] Backend compila y arranca en puerto 8080
- [x] MFE Commands carga desde Shell via Module Federation
- [x] Shared API genera tipos correctamente desde OpenAPI

---

## Plan 002 — MFE Settings + Shared API Refactor

**Fecha:** 2026-04-09
**Estado:** Completado

### Objetivo

Añadir el microfrontend de configuración y refactorizar la Shared API para usar el cliente generado por `@hey-api/openapi-ts`.

### Cambios realizados

- [x] Creado `apps/frontend/mfe-settings/` — remote MFE expuesto en puerto 3002
  - Tabs: General, API, Notifications
- [x] Shell actualizado para cargar `mfeSettings` como remote adicional
- [x] Shared API refactorizada: migrada a `src/` con cliente `@hey-api/openapi-ts`
  - Modelos eliminados del directorio raíz (generados en `src/` ahora)
  - `executeCommand` usa parámetro `body` (no `data`)

---

## Plan 003 — Rediseño UX: Dark Industrial

**Fecha:** 2026-04-10
**Estado:** Completado

### Objetivo

Aplicar el skill `creative-ui-design` para elevar la calidad visual sin alterar la funcionalidad.

### Dirección estética

Industrial utilitarian — dark theme, sharp edges, tipografía técnica.

### Cambios realizados

**Shell (`apps/frontend/shell/`):**
- [x] CSS completo con sistema de variables (`--bg-void`, `--accent-primary: #ff6b35`, etc.)
- [x] Fuentes: Outfit (UI) + JetBrains Mono (código)
- [x] Textura noise sutil en body (SVG data URL)
- [x] Emojis reemplazados por iconos SVG inline (BoltIcon, GridIcon, TerminalIcon, GearIcon, BellIcon, HelpIcon, ClockIcon, CogIcon, CheckIcon, XIcon)
- [x] Fix responsive: `.nav-item span:not(.nav-icon)` para preservar iconos en sidebar colapsado

**MFE Commands (`apps/frontend/mfe-commands/`):**
- [x] CSS alineado al sistema de diseño del shell (variables CSS, sin hardcode)
- [x] Sin `border-radius` — estética industrial
- [x] Botones outlined naranja, fill al hover
- [x] Indicador de hover con borde izquierdo animado
- [x] `statusColors.processing` cambiado de indigo `#4f46e5` a naranja `#ff6b35`
- [x] Emojis eliminados del estado error y vacío

**MFE Settings (`apps/frontend/mfe-settings/`):**
- [x] CSS alineado al sistema de diseño del shell
- [x] Sin `border-radius` en inputs, selects ni botones
- [x] Tabs con underline naranja (antes indigo)
- [x] Select con flecha SVG custom

---

## Plan 004 — Integración Claude Code

**Fecha:** 2026-04-10
**Estado:** Completado

### Objetivo

Integrar los agentes y skills de OpenCode en Claude Code, unificando la configuración con una sola fuente de verdad.

### Archivos creados

- [x] `CLAUDE.md` — contexto del proyecto para Claude Code
- [x] `.claude/agents/oscar.md` — Orquestador (carga `.opencode/agent/oscar.md`)
- [x] `.claude/agents/ivan.md` — Implementador (carga `.opencode/agent/ivan.md`)
- [x] `.claude/agents/jester.md` — QA (carga `.opencode/agent/jester.md`)
- [x] `.claude/agents/scout.md` — Investigador (carga `.opencode/agent/scout.md`)
- [x] `.claude/commands/creative-ui-design.md` — carga `.opencode/skills/creative-ui-design/SKILL.md`
- [x] `.claude/commands/quarkus-backend.md` — carga `.opencode/skills/quarkus-backend/SKILL.md`
- [x] `.claude/commands/frontend-api-integration.md` — carga `.opencode/skills/frontend-api-integration/SKILL.md`
- [x] `.claude/commands/microfrontends-setup.md` — carga `.opencode/skills/microfrontends-setup/SKILL.md`
- [x] `.claude/commands/react-typescript.md` — carga `.opencode/skills/react-typescript/SKILL.md`

### Estrategia de unificación

Los archivos `.opencode/agent/*.md` y `.opencode/skills/*/SKILL.md` son la fuente de verdad. Las contrapartes en `.claude/` los referencian con `@` imports — editar el original actualiza ambos sistemas automáticamente.
