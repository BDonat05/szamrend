#!/usr/bin/env bash

decor() {
  echo "--"
  echo "$1"

  for i in {0..10}; do
    echo "$i"
  done
}

decor "asdasd"

check_conn() {
  if [ $# -gt 0 ]; then
    if [ $# -gt 1 ]; then
      max_time="$2"
    else
      max_time="8"
    fi
    if curl -s --max-time "$max_time" -o asd.txt "$1"; then
      # VAN_HALOZAT=1
      echo "Halozat: van"
    else
      # VAN_HALOZAT=0
      echo "Halozat: nincs"
    fi
  fi
}

check_conn "https://api.frankfurter.dev/v1/latest" 10
jq . asd.txt
