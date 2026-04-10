#!/bin/bash
# CMA Factoria - Backend Local Start Script
# Description: Inicializa el backend (command-service) localmente

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$PROJECT_ROOT/scripts/commons/log.sh"
MODULE_NAME="backend-localstart"

log "INFO" "=========================================="
log "INFO" "Iniciando Backend - CMA Factoria"
log "INFO" "=========================================="

BACKEND_DIR="$PROJECT_ROOT/apps/backend/command-service"

if [[ ! -d "$BACKEND_DIR" ]]; then
    handle_error "Directorio de backend no encontrado: $BACKEND_DIR"
fi

cd "$BACKEND_DIR"

if [[ ! -f "pom.xml" ]]; then
    handle_error "No se encontró pom.xml en $BACKEND_DIR"
fi

log "INFO" "Verificando/compilando proyecto backend..."
mvn clean compile -q

log "INFO" "Iniciando command-service en modo desarrollo..."
log "INFO" "El servicio estará disponible en: http://localhost:8080"
log "INFO" "Presiona Ctrl+C para detener"

mvn quarkus:dev