#!/bin/bash
set -euo pipefail

MODULE_NAME="jmeter-command-api-ms"
LOG_MODULE_NAME="$MODULE_NAME"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../commons/get.sh"
source "$(get_project_dir)/scripts/commons/log.sh"

PROFILE="dev"
JMETER_FILE_ARG=""
GUI_MODE=false
CLEAR_MODE=false

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
    --gui)
      GUI_MODE=true
      shift
      ;;
    --clear)
      CLEAR_MODE=true
      shift
      ;;
    *)
      shift
      ;;
  esac
done

load_env_vars "$PROFILE" "$SCRIPT_DIR/.."

JMETER_HOME=$(set_with_fallback "JMETER_HOME" "/usr/local/jmeter")
TARGET_HOST=$(set_with_fallback "TARGET_HOST" "localhost")
TARGET_PORT=$(set_with_fallback "TARGET_PORT" "8080")
JMETER_FILE=$(set_with_fallback "JMETER_FILE" "scenarie-001")

# CLI arg overrides env value
[[ -n "$JMETER_FILE_ARG" ]] && JMETER_FILE="$JMETER_FILE_ARG"

JMX_PATH="$(get_project_dir)/tests/jmeter/command-api-ms/${JMETER_FILE}.jmx"
if [[ ! -f "$JMX_PATH" ]]; then
  log "ERROR" "Archivo JMX no encontrado: $JMX_PATH"
  exit 1
fi

TMP_DIR="$(get_project_dir)/.tmp/jmeter/command-api-ms"
mkdir -p "$TMP_DIR"

if [[ "$CLEAR_MODE" == true ]]; then
  log "INFO" "Limpiando archivos en: $TMP_DIR"
  rm -f "$TMP_DIR"/*.jtl "$TMP_DIR"/*.log
  rm -rf "$TMP_DIR"/*-dashboard
  log "SUCCESS" "Archivos eliminados"
  exit 0
fi

JMETER_EXTRA_ARGS=()
JMETER_PROPS_FILE="$(get_project_dir)/tests/jmeter/command-api-ms/${PROFILE}.env"
if [[ -f "$JMETER_PROPS_FILE" ]]; then
  JMETER_EXTRA_ARGS+=("-q" "$JMETER_PROPS_FILE")
  log "INFO" "Properties: $JMETER_PROPS_FILE"
fi

log "INFO" "Starting JMeter test for command-api-ms (profile: $PROFILE)"
log "INFO" "Target: http://${TARGET_HOST}:${TARGET_PORT}/api/commands"

JMETER_MODE_ARGS=()
[[ "$GUI_MODE" == false ]] && JMETER_MODE_ARGS+=("-n")

JVM_ARGS="-Xms1g -Xmx3g -XX:MaxMetaspaceSize=256m" \
"$JMETER_HOME/bin/jmeter" \
  "${JMETER_MODE_ARGS[@]}" \
  -t "$JMX_PATH" \
  "${JMETER_EXTRA_ARGS[@]}" \
  -l "$TMP_DIR/${JMETER_FILE}.jtl" \
  -j "$TMP_DIR/${JMETER_FILE}.log"

log "SUCCESS" "JMeter test completed — results: $TMP_DIR/${JMETER_FILE}.jtl"
