#!/bin/bash
# CMA Factoria - Backend Local Start Script
# Description: Inicializa el backend localmente
# Usage: ./local_start.sh [command|dashboard|settings] --profile <dev|staging|prod>
#   (sin argumentos) - arranca command-api-ms en puerto 8080
#   dashboard        - arranca dashboard-api-ms en puerto 8081
#   settings         - arranca settings-api-ms en puerto 8082
#   --profile        - perfil de variables de entorno (default: dev)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$PROJECT_ROOT/scripts/commons/log.sh"
MODULE_NAME="backend-localstart"

# Parsear argumentos
SERVICE="command"
PROFILE="dev"

while [[ $# -gt 0 ]]; do
    case $1 in
        --profile)
            PROFILE="$2"
            shift 2
            ;;
        command|dashboard|settings)
            SERVICE="$1"
            shift
            ;;
        *)
            echo "Usage: $0 [command|dashboard|settings] --profile <dev|staging|prod>"
            exit 1
            ;;
    esac
done

log "INFO" "=========================================="
log "INFO" "Iniciando Backend - CMA Factoria"
log "INFO" "Servicio: $SERVICE | Perfil: $PROFILE"
log "INFO" "=========================================="

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

# Cargar variables de entorno del perfil
ENV_FILE="$BACKEND_DIR/${PROFILE}.env"
if [[ -f "$ENV_FILE" ]]; then
    log "INFO" "Cargando variables de entorno desde: $ENV_FILE"
    set -a
    source "$ENV_FILE"
    set +a
else
    log "WARN" "No se encontró archivo de perfil: $ENV_FILE"
fi

log "INFO" "Verificando/compilando proyecto backend ($SERVICE_NAME)..."
mvn clean compile -q

log "INFO" "Iniciando $SERVICE_NAME en modo desarrollo..."
log "INFO" "El servicio estará disponible en: http://localhost:$SERVICE_PORT"
log "INFO" "Presiona Ctrl+C para detener"

mvn quarkus:dev
