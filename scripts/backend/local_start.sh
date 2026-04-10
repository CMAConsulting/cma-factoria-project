#!/bin/bash
# CMA Factoria - Backend Local Start Script
# Description: Inicializa el backend localmente
# Usage: ./local_start.sh [command|dashboard|settings]
#   (sin argumentos) - arranca command-api-ms en puerto 8080
#   dashboard        - arranca dashboard-api-ms en puerto 8081
#   settings         - arranca settings-api-ms en puerto 8082

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$PROJECT_ROOT/scripts/commons/log.sh"
MODULE_NAME="backend-localstart"

log "INFO" "=========================================="
log "INFO" "Iniciando Backend - CMA Factoria"
log "INFO" "=========================================="

SERVICE="${1:-command}"

if [[ "$SERVICE" == "dashboard" ]]; then
    BACKEND_DIR="$PROJECT_ROOT/apps/backend/dashboard-api-ms"
    SERVICE_NAME="dashboard-api-ms"
    SERVICE_PORT="8081"
elif [[ "$SERVICE" == "settings" ]]; then
    BACKEND_DIR="$PROJECT_ROOT/apps/backend/settings-api-ms"
    SERVICE_NAME="settings-api-ms"
    SERVICE_PORT="8082"
else
    BACKEND_DIR="$PROJECT_ROOT/apps/backend/command-api-ms"
    SERVICE_NAME="command-api-ms"
    SERVICE_PORT="8080"
fi

if [[ ! -d "$BACKEND_DIR" ]]; then
    handle_error "Directorio de backend no encontrado: $BACKEND_DIR"
fi

cd "$BACKEND_DIR"

if [[ ! -f "pom.xml" ]]; then
    handle_error "No se encontró pom.xml en $BACKEND_DIR"
fi

log "INFO" "Verificando/compilando proyecto backend ($SERVICE_NAME)..."
mvn clean compile -q

log "INFO" "Iniciando $SERVICE_NAME en modo desarrollo..."
log "INFO" "El servicio estará disponible en: http://localhost:$SERVICE_PORT"
log "INFO" "Presiona Ctrl+C para detener"

mvn quarkus:dev
