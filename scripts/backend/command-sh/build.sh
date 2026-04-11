#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

source "$SCRIPT_DIR/../../commons/log.sh"
source "$SCRIPT_DIR/../../commons/get.sh"

MODULE_NAME="command-build"
LOG_MODULE_NAME="$MODULE_NAME"

PROFILE="dev"

usage() {
  cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Build Docker image for command-api-ms.

OPTIONS:
  -p, --profile    Profile name to use (default: dev)
  -h, --help      Show this help message

EXAMPLES:
  $SCRIPT_NAME --profile dev
  $SCRIPT_NAME --profile staging
  $SCRIPT_NAME -p prod
EOF
}

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
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

load_env_vars "$PROFILE" "$SCRIPT_DIR"

IMAGE_NAME=$(set_with_fallback "IMAGE_NAME" "cma-factoria/command-api-ms")
TAG=$(set_with_fallback "TAG" "latest")

log "INFO" "Building Docker image: $IMAGE_NAME:$TAG (profile: $PROFILE)"

PROJECT_ROOT="$(get_project_dir)"
DOCKER_DIR="$PROJECT_ROOT/infra/docker/command-docker"

BUILD_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
VCS_REF="$(git -C "$PROJECT_ROOT" rev-parse HEAD 2>/dev/null || echo 'unknown')"

docker build -t "$IMAGE_NAME:$TAG" \
  --build-arg BUILD_DATE="$BUILD_DATE" \
  --build-arg VCS_REF="$VCS_REF" \
  -f "$DOCKER_DIR/Dockerfile" \
  "$PROJECT_ROOT"

log "SUCCESS" "Image built successfully: $IMAGE_NAME:$TAG"

echo ""
log "INFO" "To run the container:"
echo "  docker run -p 8080:8080 $IMAGE_NAME:$TAG"