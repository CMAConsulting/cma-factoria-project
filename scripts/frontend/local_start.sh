#!/bin/bash
# CMA Factoria - Frontend Local Start Script
# Description: Inicializa el frontend (shell + MFEs + shared APIs) localmente
# Usage: ./local_start.sh --profile <dev|staging|prod>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$PROJECT_ROOT/scripts/commons/log.sh"
MODULE_NAME="frontend-localstart"

# Parsear argumentos
PROFILE="dev"

while [[ $# -gt 0 ]]; do
    case $1 in
        --profile)
            PROFILE="$2"
            shift 2
            ;;
        *)
            echo "Usage: $0 --profile <dev|staging|prod>"
            exit 1
            ;;
    esac
done

log "INFO" "=========================================="
log "INFO" "Iniciando Frontend - CMA Factoria"
log "INFO" "Perfil: $PROFILE"
log "INFO" "=========================================="

FRONTEND_DIR="$PROJECT_ROOT/apps/frontend"

for app in mfe-principal mfe-commands mfe-settings shared-commands-api mfe-dashboard; do
    if [[ ! -d "$FRONTEND_DIR/$app" ]]; then
        handle_error "Directorio de frontend no encontrado: $FRONTEND_DIR/$app"
    fi
done

# Función para cargar variables de entorno por perfil
load_profile_env() {
    local app_dir="$1"
    local env_file="$app_dir/${PROFILE}.env"
    
    if [[ -f "$env_file" ]]; then
        log "INFO" "Cargando variables de entorno desde: $env_file"
        set -a
        source "$env_file"
        set +a
    else
        log "WARN" "No se encontró archivo de perfil: $env_file"
    fi
}

# Cargar profiles para cada MFE
load_profile_env "$FRONTEND_DIR/mfe-commands"
load_profile_env "$FRONTEND_DIR/mfe-settings"
load_profile_env "$FRONTEND_DIR/mfe-dashboard"
load_profile_env "$FRONTEND_DIR/mfe-principal"

log "INFO" "Instalando dependencias de shared-commands-api..."
cd "$FRONTEND_DIR/shared-commands-api"
if [[ -f "package.json" ]]; then
    npm install --silent 2>/dev/null || npm install
    npm run build 2>/dev/null || true
    npm link 2>/dev/null || true
    log "SUCCESS" "shared-commands-api dependencies installed"
fi

log "INFO" "Instalando dependencias de mfe-commands..."
cd "$FRONTEND_DIR/mfe-commands"
if [[ -f "package.json" ]]; then
    npm install --silent 2>/dev/null || npm install
    npm link @cma-factoria/shared-commands-api 2>/dev/null || true
    log "SUCCESS" "mfe-commands dependencies installed"
fi

log "INFO" "Instalando dependencias de mfe-settings..."
cd "$FRONTEND_DIR/mfe-settings"
if [[ -f "package.json" ]]; then
    npm install --silent 2>/dev/null || npm install
    log "SUCCESS" "mfe-settings dependencies installed"
fi

log "INFO" "Instalando dependencias de mfe-dashboard..."
cd "$FRONTEND_DIR/mfe-dashboard"
if [[ -f "package.json" ]]; then
    npm install --silent 2>/dev/null || npm install
    log "SUCCESS" "mfe-dashboard dependencies installed"
fi

log "INFO" "Instalando dependencias de mfe-principal..."
cd "$FRONTEND_DIR/mfe-principal"
if [[ -f "package.json" ]]; then
    npm install --silent 2>/dev/null || npm install
    log "SUCCESS" "shell dependencies installed"
fi

cd "$FRONTEND_DIR"

log "INFO" "=========================================="
log "INFO" "Iniciando servicios de frontend..."
log "INFO" "=========================================="
log "INFO" " - MFE Principal: http://localhost:3000"
log "INFO" " - MFE Commands: http://localhost:3001"
log "INFO" " - MFE Settings: http://localhost:3002"
log "INFO" " - MFE Dashboard: http://localhost:3003"
log "INFO" "=========================================="

log "INFO" "Iniciando mfe-commands en puerto 3001..."
cd "$FRONTEND_DIR/mfe-commands"
npm run dev &
MFE_COMMANDS_PID=$!

log "INFO" "Iniciando mfe-settings en puerto 3002..."
cd "$FRONTEND_DIR/mfe-settings"
npm run dev &
MFE_SETTINGS_PID=$!

log "INFO" "Iniciando mfe-dashboard en puerto 3003..."
cd "$FRONTEND_DIR/mfe-dashboard"
npm run dev &
MFE_DASHBOARD_PID=$!

log "INFO" "Iniciando mfe-principal en puerto 3000..."
cd "$FRONTEND_DIR/mfe-principal"
npm run dev &
SHELL_PID=$!

log "SUCCESS" "Servicios de frontend iniciados"
log "INFO" "PIDs - MFE-Principal: $SHELL_PID, MFE-Commands: $MFE_COMMANDS_PID, MFE-Settings: $MFE_SETTINGS_PID, MFE-Dashboard: $MFE_DASHBOARD_PID"
log "INFO" "Presiona Ctrl+C para detener todos los servicios"

cleanup() {
    log "INFO" "Deteniendo servicios..."
    kill $MFE_COMMANDS_PID 2>/dev/null || true
    kill $MFE_SETTINGS_PID 2>/dev/null || true
    kill $MFE_DASHBOARD_PID 2>/dev/null || true
    kill $SHELL_PID 2>/dev/null || true
    log "SUCCESS" "Servicios detenidos"
    exit 0
}

trap cleanup SIGINT SIGTERM

wait