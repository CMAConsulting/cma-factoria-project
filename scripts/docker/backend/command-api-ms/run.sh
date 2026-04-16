#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

source "$SCRIPT_DIR/../../../commons/log.sh"
source "$SCRIPT_DIR/../../../commons/get.sh"
source "$SCRIPT_DIR/../modules/container.sh"

MODULE_NAME="command-start"
LOG_MODULE_NAME="$MODULE_NAME"

usage() {
  cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] COMMAND

Manage the command-api-ms container.

COMMANDS:
  --start         Start the container in detached mode
  --stop          Stop the running container
  --remove        Stop and remove the container
  --logs [N]      Show last N lines of logs (default: 20)
  --tail [N]      Follow logs starting from last N lines (default: 20)

OPTIONS:
  -p, --profile    Profile name to use (default: dev)
  -h, --help       Show this help message

EXAMPLES:
  $SCRIPT_NAME --start
  $SCRIPT_NAME --start --profile staging
  $SCRIPT_NAME --stop
  $SCRIPT_NAME --remove
  $SCRIPT_NAME --logs
  $SCRIPT_NAME --logs 50
  $SCRIPT_NAME --tail
  $SCRIPT_NAME --tail 100
EOF
}

PROFILE="dev"
COMMAND=""
LINES=20

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--profile)
      PROFILE="$2"
      shift 2
      ;;
    --start)
      COMMAND="start"
      shift
      ;;
    --stop)
      COMMAND="stop"
      shift
      ;;
    --remove)
      COMMAND="remove"
      shift
      ;;
    --logs)
      COMMAND="logs"
      if [[ $# -gt 1 && "$2" =~ ^[0-9]+$ ]]; then
        LINES="$2"
        shift 2
      else
        shift
      fi
      ;;
    --tail)
      COMMAND="tail"
      if [[ $# -gt 1 && "$2" =~ ^[0-9]+$ ]]; then
        LINES="$2"
        shift 2
      else
        shift
      fi
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$COMMAND" ]]; then
  log "ERROR" "No command specified. Use --start, --stop, --remove, --logs, or --tail."
  usage
  exit 1
fi

load_env_vars "$PROFILE" "$SCRIPT_DIR"

IMAGE_NAME=$(set_with_fallback "IMAGE_NAME" "command-api-ms")
TAG=$(set_with_fallback "TAG" "1.0.0")
LOCAL_IMAGE_NAME="${IMAGE_NAME}:${TAG}"
CONTAINER_NAME="${IMAGE_NAME}"

case "$COMMAND" in
  start)
    HTTP_HOST=$(set_with_fallback "HTTP_HOST" "0.0.0.0")
    HTTP_PORT=$(set_with_fallback "HTTP_PORT" "8080")
    CORS_ENABLED=$(set_with_fallback "CORS_ENABLED" "")
    CORS_ORIGINS=$(set_with_fallback "CORS_ORIGINS" "")
    DB_HOST=$(set_with_fallback "DB_HOST" "")
    DB_PORT=$(set_with_fallback "DB_PORT" "")
    DB_NAME=$(set_with_fallback "DB_NAME" "")
    DB_USER=$(set_with_fallback "DB_USER" "")
    DB_PASSWORD=$(set_with_fallback "DB_PASSWORD" "")

    container_start "$CONTAINER_NAME" "$LOCAL_IMAGE_NAME" "8080" "8080" \
      -e HTTP_HOST="$HTTP_HOST" \
      -e HTTP_PORT="$HTTP_PORT" \
      -e CORS_ENABLED="$CORS_ENABLED" \
      -e CORS_ORIGINS="$CORS_ORIGINS" \
      -e DB_HOST="$DB_HOST" \
      -e DB_PORT="$DB_PORT" \
      -e DB_NAME="$DB_NAME" \
      -e DB_USER="$DB_USER" \
      -e DB_PASSWORD="$DB_PASSWORD"
    ;;

  stop)
    container_stop "$CONTAINER_NAME"
    ;;

  remove)
    container_remove "$CONTAINER_NAME"
    ;;

  logs)
    container_logs "$CONTAINER_NAME" "$LINES"
    ;;

  tail)
    container_tail "$CONTAINER_NAME" "$LINES"
    ;;
esac
