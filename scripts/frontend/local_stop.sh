#!/bin/bash
# CMA Factoria - Frontend Local Stop Script
# Description: Detiene el frontend (shell + mfe-commands + mfe-settings)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$PROJECT_ROOT/scripts/commons/log.sh"
MODULE_NAME="frontend-localstop"

log "INFO" "Deteniendo servicios del frontend..."

log "INFO" "Buscando procesos en puertos 3000, 3001 y 3002..."

SHELL_PID=$(lsof -ti:3000 2>/dev/null || true)
MFE_COMMANDS_PID=$(lsof -ti:3001 2>/dev/null || true)
MFE_SETTINGS_PID=$(lsof -ti:3002 2>/dev/null || true)

if [[ -n "$SHELL_PID" ]]; then
    log "INFO" "Deteniendo shell (Puerto 3000, PID: $SHELL_PID)..."
    kill $SHELL_PID 2>/dev/null || true
fi

if [[ -n "$MFE_COMMANDS_PID" ]]; then
    log "INFO" "Deteniendo mfe-commands (Puerto 3001, PID: $MFE_COMMANDS_PID)..."
    kill $MFE_COMMANDS_PID 2>/dev/null || true
fi

if [[ -n "$MFE_SETTINGS_PID" ]]; then
    log "INFO" "Deteniendo mfe-settings (Puerto 3002, PID: $MFE_SETTINGS_PID)..."
    kill $MFE_SETTINGS_PID 2>/dev/null || true
fi

NODE_PIDS=$(pgrep -f "webpack" 2>/dev/null || true)
if [[ -n "$NODE_PIDS" ]]; then
    log "INFO" "Deteniendo procesos webpack..."
    echo "$NODE_PIDS" | xargs kill 2>/dev/null || true
fi

sleep 1
log "SUCCESS" "Todos los servicios de frontend detenidos"