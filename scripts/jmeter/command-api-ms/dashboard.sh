#!/bin/bash
set -euo pipefail

MODULE_NAME="jmeter-dashboard-command-api-ms"
LOG_MODULE_NAME="$MODULE_NAME"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../commons/get.sh"
source "$(get_project_dir)/scripts/commons/log.sh"

PROFILE="dev"
JMETER_FILE_ARG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--profile)
      PROFILE="$2"
      shift 2
      ;;
    --jmeter-file)
      JMETER_FILE_ARG="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

load_env_vars "$PROFILE" "$SCRIPT_DIR"

JMETER_HOME=$(set_with_fallback "JMETER_HOME" "/usr/local/jmeter")
JMETER_FILE=$(set_with_fallback "JMETER_FILE" "scenarie-001")

[[ -n "$JMETER_FILE_ARG" ]] && JMETER_FILE="$JMETER_FILE_ARG"

TMP_DIR="$(get_project_dir)/.tmp/jmeter/command-api-ms"
JTL_FILE="$TMP_DIR/${JMETER_FILE}.jtl"
DASHBOARD_DIR="$TMP_DIR/${JMETER_FILE}-dashboard"

if [[ ! -f "$JTL_FILE" ]]; then
  log "ERROR" "Archivo JTL no encontrado: $JTL_FILE"
  log "ERROR" "Ejecuta start.sh primero para generar los resultados."
  exit 1
fi

JTL_LINES=$(wc -l < "$JTL_FILE")
if [[ "$JTL_LINES" -le 1 ]]; then
  log "ERROR" "El archivo JTL no contiene muestras: $JTL_FILE"
  log "ERROR" "El test puede haber finalizado sin ejecutar requests. Revisa el log: $TMP_DIR/${JMETER_FILE}.log"
  exit 1
fi

log "INFO" "Muestras encontradas: $((JTL_LINES - 1)) registros"

if [[ -d "$DASHBOARD_DIR" ]]; then
  log "INFO" "Eliminando dashboard previo: $DASHBOARD_DIR"
  rm -rf "$DASHBOARD_DIR"
fi

log "INFO" "Generando dashboard para: $JMETER_FILE"
log "INFO" "JTL: $JTL_FILE"
log "INFO" "Salida: $DASHBOARD_DIR"

"$JMETER_HOME/bin/jmeter" -g "$JTL_FILE" -o "$DASHBOARD_DIR"

log "SUCCESS" "Dashboard generado: $DASHBOARD_DIR/index.html"
