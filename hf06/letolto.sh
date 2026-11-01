#!/usr/bin/env bash

set -euo pipefail

TMP_DIR=$(mktemp -d)
URLS=("$@")
OUT_DIR="./files"
LOG_PATH="./letolto.log"
MAX_RETRIES=3

# INT and ERR don't have to be speciied, EXIT covers both
trap cleanup EXIT

cleanup() {
  echo "Cleaning up"
  rm -r "$TMP_DIR"
}

log() {
  local msg=$1
  echo "$(date +%T) $msg" >>$LOG_PATH
}

try_download() {
  local url=$1
  local delay=1
  for ((i = 0; i < MAX_RETRIES; i++)); do
    log "Attempt $((i + 1))/$MAX_RETRIES fetch from $url"
    if curl -fsSL "$url" -o "$TMP_DIR/$(date +%N).json" 2>>$LOG_PATH; then
      log "Download successful"
      return 0
    fi

    if ((i < MAX_RETRIES - 1)); then
      log "Request failed. Retrying in ${delay}s"
      sleep $delay
      delay=$((delay * 2))
    fi
  done

  log "Download failed from $1"
}

download_files() {
  echo "Starting file download"
  for url in "${URLS[@]}"; do
    try_download "$url"
  done

  cp -r "$TMP_DIR/." "$OUT_DIR"
  echo "File download finished"
}

if [ $# -gt 0 ]; then
  download_files
else
  echo "Error: Provide at lease one url"
fi
