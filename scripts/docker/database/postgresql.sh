#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../../" && pwd)"
TMP_DIR="$PROJECT_DIR/.tmp"

source "$PROJECT_DIR/scripts/commons/log.sh"
source "$PROJECT_DIR/scripts/commons/get.sh"
source "$SCRIPT_DIR/modules/volume.sh"
source "$SCRIPT_DIR/modules/postgres.sh"

MODULE_NAME="postgresql"
LOG_MODULE_NAME="$MODULE_NAME"

PROFILE="${PROFILE:-dev}"
COMMAND=""

usage() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS] COMMAND

Initialize and manage PostgreSQL container instances.

COMMANDS:
  init        Initialize PostgreSQL with volumes
  start       Start existing PostgreSQL container
  stop        Stop PostgreSQL container
  remove      Remove PostgreSQL container and volumes
  status      Show container status
  test        Test connectivity with psql

OPTIONS:
  -p, --profile PROFILE    Environment profile (dev, staging, prod) [default: dev]
  -h, --help               Show this help message

EXAMPLES:
  $(basename "$0") init
  $(basename "$0") -p staging init
  $(basename "$0") start
  $(basename "$0") remove
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p|--profile)
        PROFILE="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      -*)
        log "ERROR" "Unknown option: $1"
        usage
        exit 1
        ;;
      *)
        COMMAND="$1"
        shift
        ;;
    esac
  done
}

parse_args "$@"

if [[ -z "$COMMAND" ]]; then
  usage
  exit 1
fi

load_env_vars "$PROFILE" "$SCRIPT_DIR"

POSTGRES_VERSION=$(set_with_fallback "POSTGRES_VERSION" "16")
POSTGRES_PORT=$(set_with_fallback "POSTGRES_PORT" "5432")
POSTGRES_DB=$(set_with_fallback "POSTGRES_DB" "factoria")
POSTGRES_USER=$(set_with_fallback "POSTGRES_USER" "factoria")
POSTGRES_PASSWORD=$(set_with_fallback "POSTGRES_PASSWORD" "factoria")
USE_NATIVE_VOLUME=$(set_with_fallback "USE_NATIVE_VOLUME" "true")
VOLUME_PATH=$(set_with_fallback "VOLUME_PATH" "")

if [[ "$USE_NATIVE_VOLUME" == "true" ]]; then
  DATA_VOLUME="${VOLUME_PATH:-factoria_postgres_data_${PROFILE}}"
  DATA_DIR=""
else
  DATA_VOLUME=""
  DATA_DIR="${VOLUME_PATH:-${TMP_DIR}/postgres/${PROFILE}/data}"
fi

CONTAINER_NAME="factoria-postgres-${PROFILE}"

case "$COMMAND" in
  init)
    postgres_init "$CONTAINER_NAME" "$POSTGRES_VERSION" "$POSTGRES_PORT" \
      "$POSTGRES_DB" "$POSTGRES_USER" "$POSTGRES_PASSWORD" \
      "$USE_NATIVE_VOLUME" "$DATA_VOLUME" "$DATA_DIR"
    ;;
  start)
    postgres_start "$CONTAINER_NAME"
    ;;
  stop)
    postgres_stop "$CONTAINER_NAME"
    ;;
  remove)
    postgres_remove "$CONTAINER_NAME" "$USE_NATIVE_VOLUME" "$DATA_VOLUME" "$DATA_DIR"
    ;;
  status)
    postgres_status "$CONTAINER_NAME" "$POSTGRES_VERSION" "$POSTGRES_PORT" \
      "$POSTGRES_DB" "$POSTGRES_USER" \
      "$USE_NATIVE_VOLUME" "$DATA_VOLUME" "$DATA_DIR"
    ;;
  test)
    postgres_test "$CONTAINER_NAME" "$POSTGRES_USER" "$POSTGRES_DB"
    ;;
  *)
    log "ERROR" "Unknown command: $COMMAND"
    usage
    exit 1
    ;;
esac
