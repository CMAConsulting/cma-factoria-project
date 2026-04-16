#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

source "$SCRIPT_DIR/../../commons/log.sh"
source "$SCRIPT_DIR/../../commons/get.sh"

MODULE_NAME="command-build"
LOG_MODULE_NAME="$MODULE_NAME"

PROFILE="dev"
UPLOAD=false

usage() {
  cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Build Docker image for command-api-ms.

OPTIONS:
  -p, --profile    Profile name to use (default: dev)
  --upload        Upload image to registry after building
  -h, --help      Show this help message

EXAMPLES:
  $SCRIPT_NAME --profile dev
  $SCRIPT_NAME --profile staging
  $SCRIPT_NAME --upload
  $SCRIPT_NAME -p prod --upload
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--profile)
      PROFILE="$2"
      shift 2
      ;;
    --upload)
      UPLOAD=true
      shift
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

IMAGE_NAME=$(set_with_fallback "IMAGE_NAME" "command-api-ms")
TAG=$(set_with_fallback "TAG" "1.0.0")
REGISTRY_SERVER=$(set_with_fallback "REGISTRY_SERVER" "")
REGISTRY_USERNAME=$(set_with_fallback "REGISTRY_USERNAME" "")
REGISTRY_PASSWORD=$(set_with_fallback "REGISTRY_PASSWORD" "")

# Nombre local sin registry
LOCAL_IMAGE_NAME="$IMAGE_NAME:$TAG"
# Nombre con registry para upload
REGISTRY_IMAGE_NAME="$REGISTRY_SERVER/$IMAGE_NAME:$TAG"

log "INFO" "Building Docker image: $LOCAL_IMAGE_NAME (profile: $PROFILE)"

PROJECT_ROOT="$(get_project_dir)"
DOCKER_DIR="$PROJECT_ROOT/infra/docker/command-docker"

BUILD_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
VCS_REF="$(git -C "$PROJECT_ROOT" rev-parse HEAD 2>/dev/null || echo 'unknown')"

# Build local sin registry (sin caché para forzar rebuild)
docker build --no-cache -t "$LOCAL_IMAGE_NAME" \
  --build-arg BUILD_DATE="$BUILD_DATE" \
  --build-arg VCS_REF="$VCS_REF" \
  -f "$DOCKER_DIR/Dockerfile" \
  "$PROJECT_ROOT"

log "SUCCESS" "Image built successfully: $LOCAL_IMAGE_NAME"

if [[ "$UPLOAD" == "true" ]]; then
  if [[ -z "$REGISTRY_SERVER" ]]; then
    log "ERROR" "REGISTRY_SERVER not configured. Cannot upload image."
    exit 1
  fi

  log "INFO" "Tagging image for registry: $REGISTRY_IMAGE_NAME"
  docker tag "$LOCAL_IMAGE_NAME" "$REGISTRY_IMAGE_NAME"

  log "INFO" "Logging into registry: $REGISTRY_SERVER"
  echo "$REGISTRY_PASSWORD" | docker login "$REGISTRY_SERVER" -u "$REGISTRY_USERNAME" --password-stdin

  log "INFO" "Uploading image to registry..."
  docker push "$REGISTRY_IMAGE_NAME"

  log "SUCCESS" "Image uploaded successfully: $REGISTRY_IMAGE_NAME"
fi

echo ""
log "INFO" "To run the container:"
echo "  docker run -p 8080:8080 $LOCAL_IMAGE_NAME"