#!/bin/bash
# Módulo reusable para ejecutar scripts SQL contra PostgreSQL
# Uso: source modules/sql_runner.sh

# Función para ejecutar scripts SQL con registro
# Parámetros:
#   $1 - Directorio de scripts SQL
#   $2 - Descripción del tipo de scripts
#   $3 - Nombre de la base de datos
# Variables requeridas en contexto:
#   PSQL_USERNAME, PSQL_PASSWORD, PSQL_HOSTNAME, PSQL_PORT
run_sql_scripts() {
  local dir="$1"
  local description="$2"
  local database="$3"
  
  if [[ ! -d "$dir" ]]; then
    handle_error "Directorio no encontrado: $dir"
    return 1
  fi
  
  log "INFO" "=== Impactando $description ==="
  
  local sql_count=0
  local sql_error=0
  
  for sql_file in "$dir"/*.sql; do
    if [[ -f "$sql_file" ]]; then
      sql_count=$((sql_count + 1))
      local filename="$(basename "$sql_file")"
      log "INFO" "Ejecutando $filename contra $database"
      
      if PGPASSWORD="$PSQL_PASSWORD" psql \
        --host="$PSQL_HOSTNAME" \
        --port="$PSQL_PORT" \
        --username="$PSQL_USERNAME" \
        --dbname="$database" \
        -f "$sql_file" 2>&1; then
        log "SUCCESS" "$filename ejecutado correctamente"
      else
        log "ERROR" "Error ejecutando $filename"
        sql_error=$((sql_error + 1))
      fi
    fi
  done
  
  log "INFO" "=== $description: $sql_count scripts, $sql_error errores ==="
  
  if [[ $sql_error -gt 0 ]]; then
    return 1
  fi
  return 0
}

# Función para verificar conexión a PostgreSQL
check_psql_connection() {
  log "INFO" "Verificando conexión a PostgreSQL..."
  
  if PGPASSWORD="$PSQL_PASSWORD" psql \
    --host="$PSQL_HOSTNAME" \
    --port="$PSQL_PORT" \
    --username="$PSQL_USERNAME" \
    --dbname="postgres" \
    -c "SELECT version();" > /dev/null 2>&1; then
    log "SUCCESS" "Conexión a PostgreSQL exitosa"
    return 0
  else
    handle_error "No se puede conectar a PostgreSQL en $PSQL_HOSTNAME:$PSQL_PORT"
    return 1
  fi
}

# Función para mostrar ayuda de uso
show_usage() {
  echo "Uso: $0 [--profile <perfil>]"
  echo "Por defecto usa el perfil 'dev'"
}