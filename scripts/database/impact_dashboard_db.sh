#!/bin/bash
set -euo pipefail

# Script para impactar scripts SQL de dashboard-db en PostgreSQL
# Uso: ./impact_dashboard_db.sh [--profile <perfil>]
# Por defecto usa el perfil 'dev'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
DB_SCRIPTS_DIR="$PROJECT_DIR/infra/database/dashboard-db"

# Cargar funciones helper
source "$SCRIPT_DIR/../commons/get.sh"
source "$SCRIPT_DIR/../commons/log.sh"
source "$SCRIPT_DIR/modules/sql_runner.sh"

# Configurar módulo de logging
MODULE_NAME="impact_dashboard_db"
LOG_MODULE_NAME="impact_dashboard_db"

# Parsear argumentos
PROFILE="dev"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      PROFILE="$2"
      shift 2
      ;;
    *)
      show_usage
      exit 1
      ;;
  esac
done

# Cargar variables de entorno del perfil
load_env_vars "$PROFILE" "$SCRIPT_DIR"

# Obtener valores con fallback usando la variable actualizada
PSQL_USERNAME=$(set_with_fallback "PSQL_USERNAME" "postgres")
PSQL_PASSWORD=$(set_with_fallback "PSQL_PASSWORD" "")
PSQL_DATABASE=$(set_with_fallback "PSQL_DASHBOARD_DB" "dashboard_db")
PSQL_HOSTNAME=$(set_with_fallback "PSQL_HOSTNAME" "localhost")
PSQL_PORT=$(set_with_fallback "PSQL_PORT" "5432")

# Validar variables requeridas
if [[ -z "${PSQL_DATABASE}" ]]; then
  handle_error "ENV_PSQL_DASHBOARD_DB no está definida en el perfil $PROFILE"
fi

# Log de inicio con información del perfil
log "INFO" "=== Impactando dashboard-db con perfil: $PROFILE ==="
log "INFO" "Base de datos objetivo: $(basename "$PSQL_DATABASE")"
log "INFO" "Host: $PSQL_HOSTNAME:$PSQL_PORT"

# Verificar conexión
check_psql_connection

# Ejecutar scripts en orden: tablas primero, luego stored procedures
run_sql_scripts "$DB_SCRIPTS_DIR/tables" "tablas" "$PSQL_DATABASE"
run_sql_scripts "$DB_SCRIPTS_DIR/storeprocedures" "stored procedures" "$PSQL_DATABASE"

log "SUCCESS" "=== Proceso completado para la base: $(basename "$PSQL_DATABASE") ==="