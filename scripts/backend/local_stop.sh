#!/bin/bash
# CMA Factoria - Backend Local Stop Script
# Description: Detiene el backend (command-api-ms / dashboard-api-ms / settings-api-ms)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$PROJECT_ROOT/scripts/commons/log.sh"
MODULE_NAME="backend-localstop"

log "INFO" "Deteniendo servicios del backend..."

for PORT in 8080 8081 8082; do
    PID=$(lsof -ti:$PORT 2>/dev/null || true)
    if [[ -n "$PID" ]]; then
        log "INFO" "Deteniendo proceso Quarkus (PID: $PID) en puerto $PORT..."
        kill $PID 2>/dev/null || true
    else
        log "WARN" "No se encontró proceso en puerto $PORT"
    fi
done

sleep 2

JAVA_PIDS=$(pgrep -f "quarkus" 2>/dev/null || true)
if [[ -n "$JAVA_PIDS" ]]; then
    log "INFO" "Deteniendo procesos Java relacionados con Quarkus..."
    echo "$JAVA_PIDS" | xargs kill 2>/dev/null || true
    sleep 1
fi

log "SUCCESS" "Todos los servicios de backend detenidos"