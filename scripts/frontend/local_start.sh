#!/bin/bash
# CMA Factoria - Frontend Local Start Script
# Description: Inicializa el frontend (shell + mfe-commands + mfe-settings) localmente

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$PROJECT_ROOT/scripts/commons/log.sh"
MODULE_NAME="frontend-localstart"

log "INFO" "=========================================="
log "INFO" "Iniciando Frontend - CMA Factoria"
log "INFO" "=========================================="

FRONTEND_DIR="$PROJECT_ROOT/apps/frontend"

for app in shell mfe-commands mfe-settings shared-api; do
    if [[ ! -d "$FRONTEND_DIR/$app" ]]; then
        handle_error "Directorio de frontend no encontrado: $FRONTEND_DIR/$app"
    fi
done

log "INFO" "Instalando dependencias de shared-api..."
cd "$FRONTEND_DIR/shared-api"
if [[ -f "package.json" ]]; then
    npm install --silent 2>/dev/null || npm install
    log "SUCCESS" "shared-api dependencies installed"
fi

log "INFO" "Instalando dependencias de mfe-commands..."
cd "$FRONTEND_DIR/mfe-commands"
if [[ -f "package.json" ]]; then
    npm install --silent 2>/dev/null || npm install
    log "SUCCESS" "mfe-commands dependencies installed"
fi

log "INFO" "Instalando dependencias de mfe-settings..."
cd "$FRONTEND_DIR/mfe-settings"
if [[ -f "package.json" ]]; then
    npm install --silent 2>/dev/null || npm install
    log "SUCCESS" "mfe-settings dependencies installed"
fi

log "INFO" "Instalando dependencias de shell..."
cd "$FRONTEND_DIR/shell"
if [[ -f "package.json" ]]; then
    npm install --silent 2>/dev/null || npm install
    log "SUCCESS" "shell dependencies installed"
fi

cd "$FRONTEND_DIR"

log "INFO" "=========================================="
log "INFO" "Iniciando servicios de frontend..."
log "INFO" "=========================================="
log "INFO" " - Shell: http://localhost:3000"
log "INFO" " - MFE Commands: http://localhost:3001"
log "INFO" " - MFE Settings: http://localhost:3002"
log "INFO" "=========================================="

log "INFO" "Iniciando mfe-commands en puerto 3001..."
cd "$FRONTEND_DIR/mfe-commands"
npm run dev &
MFE_COMMANDS_PID=$!

log "INFO" "Iniciando mfe-settings en puerto 3002..."
cd "$FRONTEND_DIR/mfe-settings"
npm run dev &
MFE_SETTINGS_PID=$!

log "INFO" "Iniciando shell en puerto 3000..."
cd "$FRONTEND_DIR/shell"
npm run dev &
SHELL_PID=$!

log "SUCCESS" "Servicios de frontend iniciados"
log "INFO" "PIDs - Shell: $SHELL_PID, MFE-Commands: $MFE_COMMANDS_PID, MFE-Settings: $MFE_SETTINGS_PID"
log "INFO" "Presiona Ctrl+C para detener todos los servicios"

cleanup() {
    log "INFO" "Deteniendo servicios..."
    kill $MFE_COMMANDS_PID 2>/dev/null || true
    kill $MFE_SETTINGS_PID 2>/dev/null || true
    kill $SHELL_PID 2>/dev/null || true
    log "SUCCESS" "Servicios detenidos"
    exit 0
}

trap cleanup SIGINT SIGTERM

wait