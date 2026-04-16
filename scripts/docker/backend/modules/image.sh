#!/bin/bash
# Docker image build and push functions.
# Requires: log() sourced from commons/log.sh before this module.

image_build() {
  local local_image="$1"
  local dockerfile="$2"
  local context="$3"
  shift 3
  # Remaining args are passed through (e.g., --build-arg KEY=VAL)

  log "INFO" "Building image: $local_image"
  docker build --no-cache -t "$local_image" -f "$dockerfile" "$@" "$context"
  log "SUCCESS" "Image built: $local_image"
}

image_push() {
  local local_image="$1"
  local registry_image="$2"
  local registry_server="$3"
  local registry_username="$4"
  local registry_password="$5"

  log "INFO" "Tagging image for registry: $registry_image"
  docker tag "$local_image" "$registry_image"

  log "INFO" "Logging into registry: $registry_server"
  echo "$registry_password" | docker login "$registry_server" -u "$registry_username" --password-stdin

  log "INFO" "Uploading image to registry..."
  docker push "$registry_image"
  log "SUCCESS" "Image uploaded: $registry_image"
}
