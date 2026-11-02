#!/usr/bin/env bash

set -euo pipefail

INDULO="./indulo.dat"
AKTUALIS="./aktualis.dat"

START=""
STOP=0
KILL=0
LISTA=0

usage() {
  cat <<EOF
  Hasznalat: $0 [kapcsolok] <parameterek>

  Kapcsolok:
    -start <nev>: Elinditja a megadott nevu folyamatot
    -stop <pid>: Allitsa meg a megadott pid-vel rendelkezo folyamatot
    -kill <pid>: Torolje a megadott pid-vel rendelkezo folyamatot
    -lista: Irja ki az osszes futo folyamatot stdin-re

  Tobb kapcsolo megadasa eseten a vegrehajtas sorrendje:
  start -> stop -> kill -> lista
EOF
}

error_() {
  echo "$1" >&2
  exit 1
}

setup_aktualis() {
  if [ -f $INDULO ]; then
    # cp $INDULO $AKTUALIS || error_ "Hiba: nem sikerult letrehozni $AKTUALIS file-t"
    cat "/dev/null" >$AKTUALIS
    while read -r l; do
      start "$l" >"/dev/null"
    done <$INDULO
  else
    error_ "Hiba: A futtatashoz letezzen $INDULO file"
  fi
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
    -start)
      START=${2:?"Hiba: start kapcsolo hasznalata eseten adja meg az elinditando process nevet!
$(usage)"}
      shift 2
      ;;
    -stop)
      STOP=${2:?"Hiba: stop kapcsolo hasznalata eseten adja meg a megallitando process pid-jet!
$(usage)"}
      shift 2
      ;;
    -kill)
      KILL=${2:?"Hiba: kill kapcsolo hasznalata eseten adja meg a torlendo process pid-jet!
$(usage)"}
      shift 2
      ;;
    -lista)
      LISTA=1
      shift
      ;;
    *)
      echo "Ismeretlen parameter"
      usage
      exit 1
      ;;
    esac
  done
}

lista() {
  echo "Folyamatok listazasa:"
  # cat $AKTUALIS
  printf "%-15s %-15s %s\n" "PID" "NEV" "STATUSZ"
  awk '{printf "%-15s %-15s %s\n", $1, $2, $3}' $AKTUALIS
}

start() {
  local newpid=$(awk 'BEGIN { maxPid = 0 } $1 > maxPid { maxPid = $1 } END { printf maxPid + 1 }' $AKTUALIS)
  echo "$newpid $1 S" >>$AKTUALIS
  echo "$1 elinditva (pid: $newpid)"
}

stop() {
  local name=$(awk -v pid="$1" '$1 == pid {printf $2}' $AKTUALIS)
  sed -i -r "s/^$1.+S\$/$1 $name T/" $AKTUALIS
  echo "$name (pid: $1) leallitva"
}

kill() {
  local name=$(awk -v pid="$1" '$1 == pid {printf $2}' $AKTUALIS)
  sed -i -r "/^$1/d" $AKTUALIS
  echo "$name (pid: $1) torolve"
}

if [ ! "$#" -gt 0 ]; then
  error_ "Legalabb 1db kapcsolo szukseges!"
fi
setup_aktualis
parse_args "$@"

if [ -n "$START" ]; then
  start "$START"
fi
if [ "$STOP" -gt 0 ]; then
  stop "$STOP"
fi
if [ "$KILL" -gt 0 ]; then
  kill "$KILL"
fi
if [ $LISTA -eq 1 ]; then
  lista
fi
