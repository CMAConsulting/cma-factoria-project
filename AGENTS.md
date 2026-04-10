# AGENTS.md - Agentic Delivery OS

## Estructura del Proyecto

```
.
├── .opencode/                  # Configuración y "personalidad" del sistema agéntico
│   ├── agent/                  # Definiciones de roles (oscar.md, ivan.md, scout.md)
│   ├── skills/                 # Paquetes de conocimiento on-demand
│   └── hooks/                  # Scripts de validación pre-commit y seguridad
├── apps/                       # Aplicaciones finales
│   ├── backend/                # API, Lógica de negocio y servicios
│   └── frontend/               # Interfaz de usuario, componentes y estados
├── contracts/                  # Contratos de interfaz y esquemas
│   ├── openapi/                # Especificaciones Swagger/OpenAPI (YAML/JSON)
│   └── schemas/                # Definiciones de eventos y modelos compartidos
├── docs/                       # Documentación técnica permanente
│   ├── history/                # ARCHIVO CRÍTICO: Registros de planificación de la IA
│   └── architecture/           # ADRs (Architectural Decision Records)
├── infra/                      # Infraestructura como Código (IaC)
│   ├── database/               # Scripts de migración, modelos Prisma/TypeORM
│   └── docker/                 # Configuraciones de contenedores y despliegue
├── tests/                      # Suite de pruebas globales (e2e, integración)
├── AGENTS.md                   # Mapa de navegación e instrucciones globales para la IA
├── opencode.json               # Configuración técnica de modelos y permisos
└── BEADS.json                  # Sistema de tracking de tareas optimizado para agentes
```

## Mapa de Navegación

| Directorio | Propósito |
|------------|-----------|
| `.opencode/agent/` | Definiciones de roles de agentes |
| `.opencode/skills/` | Conocimiento especializado |
| `.opencode/hooks/` | Scripts de validación pre-commit |
| `apps/backend/` | API y lógica de negocio |
| `apps/frontend/` | Interfaz de usuario |
| `contracts/openapi/` | Especificaciones OpenAPI/Swagger |
| `contracts/schemas/` | Modelos compartidos |
| `docs/history/` | Registros de planificación |
| `docs/architecture/` | ADRs |
| `infra/database/` | Migraciones y modelos |
| `infra/docker/` | Contenedores |
| `tests/` | Tests e2e e integración |

## Reglas de Estilo

- **Naming**: follow-case (kebab-case para archivos, camelCase para JS/TS, snake_case para Python)
- **Comentarios**: Solo si es crítico para entender el código
- **Imports**: Organizar por: externos → internos → locales
- **Testing**: Tests junto al código con sufijo `.test.ts` o `.spec.ts`

## Protocolo de Ejecución

1. **Oscar** recibe la tarea
2. **Scout** analiza y genera SPEC.md
3. **Ivan** implementa según SPEC.md
4. **Jester** valida y reporta issues
5. **Oscar** consolida en docs/history/PLAN.md

## Permisos por Agente

| Agente | Bash | Read | Write |
|--------|------|------|-------|
| Oscar | ask | allow | allow |
| Scout | allow | allow | allow |
| Ivan | allow | allow | allow |
| Jester | allow | allow | allow |