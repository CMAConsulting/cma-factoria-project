#!/bin/bash
# CMA Factoria - Init Project Script
# Description: Inicializa un nuevo proyecto con la estructura básica
# Usage: ./init_project.sh <PROJECT_NAME>
#   PROJECT_NAME: Nombre del nuevo proyecto (ej: cma-mi-proyecto)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# ============================================
# Help
# ============================================
show_help() {
    cat << EOF
Usage: $(basename "$0") <PROJECT_NAME>

Inicializa un nuevo proyecto CMA Factoria con la estructura básica.

Arguments:
    PROJECT_NAME    Nombre del nuevo proyecto (obligatorio)

Example:
    $(basename "$0") cma-mi-proyecto

EOF
}

# ============================================
# Validaciones
# ============================================
if [[ $# -lt 1 ]]; then
    echo "Error: Falta el nombre del proyecto"
    show_help
    exit 1
fi

NEW_PROJECT_NAME="$1"
NEW_PROJECT_DIR="$PROJECT_ROOT/../$NEW_PROJECT_NAME"

if [[ -d "$NEW_PROJECT_DIR" ]]; then
    echo "Error: El directorio '$NEW_PROJECT_DIR' ya existe"
    exit 1
fi

echo "==========================================="
echo "Inicializando proyecto: $NEW_PROJECT_NAME"
echo "==========================================="

# ============================================
# Crear estructura de directorios
# ============================================
echo "Creando estructura de directorios..."

mkdir -p "$NEW_PROJECT_DIR/apps/backend"
mkdir -p "$NEW_PROJECT_DIR/apps/frontend"
mkdir -p "$NEW_PROJECT_DIR/contracts/openapi"
mkdir -p "$NEW_PROJECT_DIR/contracts/schemas"
mkdir -p "$NEW_PROJECT_DIR/docs/history"
mkdir -p "$NEW_PROJECT_DIR/docs/architecture"
mkdir -p "$NEW_PROJECT_DIR/infra/database"
mkdir -p "$NEW_PROJECT_DIR/infra/docker"
mkdir -p "$NEW_PROJECT_DIR/scripts/backend"
mkdir -p "$NEW_PROJECT_DIR/scripts/frontend"
mkdir -p "$NEW_PROJECT_DIR/tests"

# ============================================
# Crear archivos .keep en directorios vacíos
# ============================================
touch "$NEW_PROJECT_DIR/apps/backend/.keep"
touch "$NEW_PROJECT_DIR/apps/frontend/.keep"
touch "$NEW_PROJECT_DIR/contracts/openapi/.keep"
touch "$NEW_PROJECT_DIR/contracts/schemas/.keep"
touch "$NEW_PROJECT_DIR/docs/history/.keep"
touch "$NEW_PROJECT_DIR/docs/architecture/.keep"
touch "$NEW_PROJECT_DIR/infra/database/.keep"
touch "$NEW_PROJECT_DIR/infra/docker/.keep"
touch "$NEW_PROJECT_DIR/scripts/backend/.keep"
touch "$NEW_PROJECT_DIR/scripts/frontend/.keep"
touch "$NEW_PROJECT_DIR/tests/.keep"

# ============================================
# Copiar scripts/commons
# ============================================
echo "Copiando scripts/commons..."
cp -r "$PROJECT_ROOT/scripts/commons" "$NEW_PROJECT_DIR/scripts/"

# ============================================
# Copiar archivos de configuración Git
# ============================================
echo "Copiando archivos de configuración Git..."
[[ -f "$PROJECT_ROOT/.gitignore" ]] && cp "$PROJECT_ROOT/.gitignore" "$NEW_PROJECT_DIR/"
[[ -f "$PROJECT_ROOT/.gitattributes" ]] && cp "$PROJECT_ROOT/.gitattributes" "$NEW_PROJECT_DIR/"

# ============================================
# Copiar .opencode
# ============================================
echo "Copiando .opencode..."
cp -r "$PROJECT_ROOT/.opencode" "$NEW_PROJECT_DIR/"

# ============================================
# Copiar .claude
# ============================================
echo "Copiando .claude..."
cp -r "$PROJECT_ROOT/.claude" "$NEW_PROJECT_DIR/"

# ============================================
# Copiar docs/scripts/commons.md
# ============================================
echo "Copiando documentación de scripts..."
mkdir -p "$NEW_PROJECT_DIR/docs/scripts"
cp "$PROJECT_ROOT/docs/scripts/commons.md" "$NEW_PROJECT_DIR/docs/scripts/"

# ============================================
# Copiar scripts/backend/local_start.sh
# ============================================
echo "Copiando scripts de backend..."
cp "$PROJECT_ROOT/scripts/backend/local_start.sh" "$NEW_PROJECT_DIR/scripts/backend/"

# ============================================
# Copiar scripts/frontend/local_start.sh
# ============================================
echo "Copiando scripts de frontend..."
cp "$PROJECT_ROOT/scripts/frontend/local_start.sh" "$NEW_PROJECT_DIR/scripts/frontend/"

# ============================================
# Crear AGENTS.md base
# ============================================
echo "Creando AGENTS.md..."
cat > "$NEW_PROJECT_DIR/AGENTS.md" << 'EOF'
# AGENTS.md - Agentic Delivery OS

## Estructura del Proyecto

```
.
├── .opencode/                  # Configuración y "personalidad" del sistema agéntico
├── apps/                       # Aplicaciones finales
│   ├── backend/                # API, Lógica de negocio y servicios
│   └── frontend/              # Interfaz de usuario, componentes y estados
├── contracts/                  # Contratos de interfaz y esquemas
├── docs/                      # Documentación técnica permanente
├── infra/                     # Infraestructura como Código (IaC)
├── scripts/                    # Scripts de automatización
├── tests/                      # Suite de pruebas globales
└── AGENTS.md                   # Mapa de navegación e instrucciones globales
```

## Reglas de Estilo

- **Naming**: follow-case (kebab-case para archivos, camelCase para JS/TS)
- **Comentarios**: Solo si es crítico para entender el código
- **Testing**: Tests junto al código con sufijo `.test.ts` o `.spec.ts`

## Definiciones de roles disponibles

Consultar `.opencode/agent/` para definiciones de roles de agentes.
EOF

# ============================================
# Crear opencode.json base
# ============================================
echo "Creando opencode.json..."
cat > "$NEW_PROJECT_DIR/opencode.json" << 'EOF'
{
  "version": "1.0.0",
  "project": {
    "name": "cma-factoria",
    "type": "microfrontend-monorepo"
  },
  "models": {
    "default": "claude-sonnet-4-20250514",
    "reasoning": "o1"
  }
}
EOF

# ============================================
# Crear BEADS.json base
# ============================================
echo "Creando BEADS.json..."
cat > "$NEW_PROJECT_DIR/BEADS.json" << 'EOF'
{
  "version": "1.0.0",
  "columns": [
    { "id": "backlog", "title": "📋 Backlog" },
    { "id": "in_progress", "title": "🔄 In Progress" },
    { "id": "review", "title": "👀 Review" },
    { "id": "done", "title": "✅ Done" }
  ],
  "cards": []
}
EOF

# ============================================
# Inicializar Git y hacer commit inicial
# ============================================
echo "Inicializando repositorio Git..."
cd "$NEW_PROJECT_DIR"
git init
git add -A
git commit -m 'Commit inicial'

echo "==========================================="
echo "Proyecto '$NEW_PROJECT_NAME' creado exitosamente"
echo "Ubicación: $NEW_PROJECT_DIR"
echo "==========================================="
echo ""
echo "Próximos pasos:"
echo "1. cd $NEW_PROJECT_DIR"
echo "2. Actualizar configuración en opencode.json"
echo "3. Agregar microservicios en apps/backend/"
echo "4. Agregar MFEs en apps/frontend/"
echo "5. Definir contratos en contracts/"