# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Stack

| Capa | Tecnología | Puerto |
|------|-----------|--------|
| Backend | Quarkus 3 (Java 17), RESTEasy Reactive | 8080 |
| Shell | React 18 + Webpack Module Federation (host) | 3000 |
| MFE Commands | React 18 + Module Federation (remote) | 3001 |
| MFE Settings | React 18 + Module Federation (remote) | 3002 |
| Shared API | @hey-api/openapi-ts generado desde OpenAPI | — |

## Comandos de desarrollo

### Backend (Quarkus)

```bash
cd apps/backend/command-service

mvn quarkus:dev          # Inicia con live reload en puerto 8080
mvn clean compile        # Compila + genera modelos desde OpenAPI (fase generate-sources)
mvn clean package        # Build completo
mvn test                 # Ejecuta tests (Surefire)
```

### Frontend — orden de arranque obligatorio

```bash
# 1. shared-api primero (MFEs dependen de su dist/)
cd apps/frontend/shared-api
npm run generate         # Genera src/ desde contracts/openapi/commands.yaml
npm run build            # Compila src/ → dist/

# 2. MFEs remotos
cd apps/frontend/mfe-commands && npm run dev   # puerto 3001
cd apps/frontend/mfe-settings && npm run dev   # puerto 3002

# 3. Shell (host)
cd apps/frontend/shell && npm run dev          # puerto 3000
```

O con los scripts de orquestación:

```bash
./scripts/backend/local_start.sh    # mvn clean compile + quarkus:dev
./scripts/frontend/local_start.sh   # instala deps + inicia los 3 MFEs
```

No hay scripts de `lint` ni `test` en los paquetes frontend.

## Arquitectura

### Flujo OpenAPI → código

`contracts/openapi/commands.yaml` es la única fuente de verdad para el contrato de la API. Se consume en dos direcciones:

- **Backend**: `mvn clean compile` activa el `openapi-generator-maven-plugin` en fase `generate-sources` → genera modelos Java en `target/generated-sources/openapi/src/main/java/org/cma/factoria/commands/model/`. El `build-helper-maven-plugin` añade ese directorio al source root. **Nunca editar esos modelos a mano.**
- **Frontend**: `npm run generate` en `shared-api/` usa `@hey-api/openapi-ts` → genera `src/` completo. `npm run build` compila a `dist/`. `npm run clean` elimina **tanto `src/` como `dist/`**.

### Module Federation

El shell actúa como **host** con `eager: true` en las dependencias compartidas. Los MFEs remotos también usan `eager: true`. Esto es intencional — evita el error `Shared module is not available for eager consumption`.

Cada MFE usa el patrón bootstrap obligatorio para Module Federation:

```
src/index.tsx  →  import('./bootstrap')   ← dynamic import, NO renderiza aquí
src/bootstrap.tsx  →  createRoot + render  ← aquí sí
```

El dynamic import en `index.tsx` difiere la inicialización hasta que Webpack resuelve el shared scope. Saltarse este patrón provoca errores de módulos compartidos.

### Dependencia shared-api

`mfe-commands` depende de `@cma-factoria/shared-api` como `"file:../shared-api"`. Si `shared-api/dist/` no existe o está desactualizado, el build del MFE fallará. Regenerar siempre antes de arrancar los MFEs tras cambios en el contrato OpenAPI.

### Variables CSS del sistema de diseño

El shell define variables CSS en `:root` (`--bg-void`, `--accent-primary: #ff6b35`, `--font-mono`, etc.) que los MFEs consumen directamente. Los MFEs **no** redefinen estos valores — heredan del shell. En dev, los MFEs deben correr dentro del shell para acceder al tema; standalone muestran fallbacks.

## Convenciones críticas

- **`executeCommand`**: usa `body:` como parámetro, no `data:`
- **Modelos backend**: añadidos automáticamente con `@AllArgsConstructor`, `@Builder`, `@RegisterForReflection` vía configuración del generador — no añadir Lombok manualmente a modelos generados
- **Nuevos remotes MFE**: declarar el módulo en `shell/src/types.d.ts` (`declare module 'mfeX/ComponentName'`) y agregar el remote en `shell/webpack.config.js`
- **Diseño**: dark industrial — sin `border-radius`, sin emojis como iconos, accent `#ff6b35`. Ver `/creative-ui-design`

## Agentes

| Agente | Rol | Cuándo usarlo |
|--------|-----|---------------|
| **Oscar** | Orquestador | Features completos que necesitan scout→ivan→jester |
| **Scout** | Investigador | Analizar código y generar SPEC.md |
| **Ivan** | Implementador | Escribir código según un plan/SPEC |
| **Jester** | QA / Validador | Verificar builds, puertos y compliance con SPEC |

Definidos en `.claude/agents/` con el contenido inlineado. La fuente canónica está en `.opencode/agent/` (para OpenCode).

> **Mantenimiento:** La sintaxis `@archivo` **no funciona en archivos de agentes**, solo en `CLAUDE.md`. Al editar un agente en `.opencode/agent/`, copiar los cambios manualmente al correspondiente `.claude/agents/`. El campo `name` debe estar en **minúsculas con guiones** (ej. `oscar`, `ivan`) — Claude Code ignora agentes con nombres en mayúsculas.

## Slash commands

| Comando | Propósito |
|---------|-----------|
| `/creative-ui-design` | Sistema de diseño dark industrial |
| `/quarkus-backend` | Patrones Quarkus + OpenAPI |
| `/frontend-api-integration` | Integración HTTP en MFEs |
| `/microfrontends-setup` | Configuración Module Federation |
| `/react-typescript` | Componentes y tipos React + TypeScript |

Definidos en `.claude/commands/`. Fuente de verdad en `.opencode/skills/`.
