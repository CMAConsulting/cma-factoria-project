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
├── scripts/                    # Scripts de automatización
│   └── commons/                 # Utilidades compartidas para scripts
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
| `scripts/` | Scripts de automatización |
| `scripts/commons/` | Utilidades compartidas para scripts |
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

| Agente  | Bash | Read | Write |
|---------|------|------|-------|
| Oscar   | ask | allow | allow |
| Scout   | allow | allow | allow |
| Ivan    | allow | allow | allow |
| Jester  | allow | allow | allow |
| Dbforge | allow | allow | allow |

## Definiciones de APIs (API First)

### Reglas para Specs OpenAPI

1. **Ubicación**: `contracts/openapi/*.yaml`
2. **Tipos específicos**: NO usar `type: object` o `additionalProperties`
3. **Definir esquemas**: Todos los tipos deben estar en `components/schemas`
4. **Parámetros reutilizables**: Definir en `components/parameters` y referenciar con `$ref`

### Ejemplo de Schema Correcto

```yaml
components:
  schemas:
    CommandPayload:
      type: object
      properties:
        environment:
          type: string
        version:
          type: string
    
    CommandRequest:
      type: object
      properties:
        command:
          type: string
        payload:
          $ref: '#/components/schemas/CommandPayload'
```

### Errores Comunes a Evitar

- ❌ `additionalProperties: true`
- ❌ `type: object` sin propiedades definidas
- ❌ Definiciones inline de parámetros en paths
- ❌ Tipos genéricos sin schema

## Estructura de Backend (Quarkus)

### Paquetes

```
src/main/java/org/cma/factoria/[service]/
├── endpoint/          # REST endpoints (JAX-RS/Reactive)
│   └── *Resource.java
├── service/           # Lógica de negocio
│   └── *Service.java
└── model/             # NO escribir - se genera automáticamente
```

### Reglas de Implementación

1. **Modelos**: Se generan automáticamente desde `contracts/openapi/` via OpenAPI Generator
2. **Lombok**: Usar en entity classes (no en modelos generados)
3. **No Maps**: Usar clases específicas para payload/metadata/result
4. **Paquetes limpio**: Solo endpoint y service en src

### Configuración pom.xml

```xml
<!-- OpenAPI Generator -->
<plugin>
    <groupId>org.openapitools</groupId>
    <artifactId>openapi-generator-maven-plugin</artifactId>
    <configOptions>
        <sourceFolder>src/main/java</sourceFolder>
        <additionalModelTypeAnnotations>
            @lombok.AllArgsConstructor
            @lombok.Builder
        </additionalModelTypeAnnotations>
    </configOptions>
</plugin>

<!-- Build Helper para fuentes generadas -->
<plugin>
    <groupId>org.codehaus.mojo</groupId>
    <artifactId>build-helper-maven-plugin</artifactId>
</plugin>
```

### Compilación

```bash
mvn clean compile  # Genera modelos y compila
```

### Resolución de Errores Comunes

| Error | Solución |
|-------|----------|
| `cannot find symbol` | Verificar que build-helper agregó fuentes generadas |
| `incompatible types` | Verificar paquetes - usar model no entity |
| `nullable: true not allowed` | Usar `type: string` en OpenAPI 3.1 |

### Referencias de Imports

- **Modelos generados**: `org.cma.factoria.commands.model.*`
- **Lombok**: Solo en entity classes