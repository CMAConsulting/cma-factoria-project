#!/bin/bash
# CMA Factoria - Backend Local Stop Script
# Description: Detiene el backend (command-service)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$PROJECT_ROOT/scripts/commons/log.sh"
MODULE_NAME="backend-localstop"

log "INFO" "Deteniendo servicios del backend..."

QUARKUS_PID=$(lsof -ti:8080 2>/dev/null || true)

if [[ -n "$QUARKUS_PID" ]]; then
    log "INFO" "Deteniendo proceso Quarkus (PID: $QUARKUS_PID) en puerto 8080..."
    kill $QUARKUS_PID 2>/dev/null || true
    sleep 2
    log "SUCCESS" "Backend detenido"
else
    log "WARN" "No se encontró proceso en puerto 8080"
fi

JAVA_PIDS=$(pgrep -f "quarkus" 2>/dev/null || true)
if [[ -n "$JAVA_PIDS" ]]; then
    log "INFO" "Deteniendo procesos Java relacionados con Quarkus..."
    echo "$JAVA_PIDS" | xargs kill 2>/dev/null || true
    sleep 1
fi

log "SUCCESS" "Todos los servicios de backend detenidos"