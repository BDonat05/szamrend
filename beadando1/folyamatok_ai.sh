#!/bin/bash
# folyamatok_ai.sh - képzelt futó folyamatok kezelése
#
# Használat:
#   ./folyamatok_ai.sh --start <alkalmazás_neve>
#   ./folyamatok_ai.sh --stop  <PID>
#   ./folyamatok_ai.sh --kill  <PID>
#   ./folyamatok_ai.sh --lista
#
# Fájlformátum (indulo.dat, aktualis.dat), soronként:
#   PID NÉV STÁTUSZ      (S = fut, T = terminált)

INDULO="indulo.dat"
AKTUALIS="aktualis.dat"

hiba() {
  echo "Hiba: $1" >&2
  exit 1
}

usage() {
  echo "Használat: $0 --start <alkalmazás> | --stop <PID> | --kill <PID> | --lista" >&2
  exit 1
}

# Az aktuális folyamatok fájl létrehozása az induló folyamatokból
if [ ! -f "$AKTUALIS" ]; then
  if [ -f "$INDULO" ]; then
    cp "$INDULO" "$AKTUALIS" || hiba "nem sikerült létrehozni a(z) $AKTUALIS fájlt"
  else
    : >"$AKTUALIS" || hiba "nem sikerült létrehozni a(z) $AKTUALIS fájlt"
  fi
fi

# PID ellenőrzése: szám-e és létezik-e
ellenoriz_pid() {
  case "$1" in
  '' | *[!0-9]*) hiba "a PID csak pozitív egész szám lehet: '$1'" ;;
  esac
  awk -v p="$1" '$1 == p { f = 1 } END { exit !f }' "$AKTUALIS" ||
    hiba "nincs $1 PID-del rendelkező folyamat"
}

case "$1" in
-start | --start)
  [ -n "$2" ] || hiba "add meg az indítandó alkalmazás nevét"
  case "$2" in
  *[[:space:]]*) hiba "az alkalmazás neve nem tartalmazhat szóközt" ;;
  esac
  # Új PID: a legnagyobb meglévő + 1 (üres fájlnál 1)
  ujpid=$(awk 'BEGIN { m = 0 } $1 > m { m = $1 } END { print m + 1 }' "$AKTUALIS")
  echo "$ujpid $2 S" >>"$AKTUALIS"
  echo "Elindítva: $2 (PID: $ujpid, státusz: S)"
  ;;

-stop | --stop)
  ellenoriz_pid "$2"
  allapot=$(awk -v p="$2" '$1 == p { print $3 }' "$AKTUALIS")
  if [ "$allapot" = "T" ]; then
    echo "A(z) $2 PID-ű folyamat már terminálva van."
    exit 0
  fi
  tmp=$(mktemp) || hiba "nem sikerült ideiglenes fájlt létrehozni"
  awk -v p="$2" '$1 == p { $3 = "T" } { print }' "$AKTUALIS" >"$tmp" &&
    mv "$tmp" "$AKTUALIS"
  echo "Terminálva: PID $2 (S -> T)"
  ;;

-kill | --kill)
  ellenoriz_pid "$2"
  tmp=$(mktemp) || hiba "nem sikerült ideiglenes fájlt létrehozni"
  awk -v p="$2" '$1 != p' "$AKTUALIS" >"$tmp" &&
    mv "$tmp" "$AKTUALIS"
  echo "Törölve: PID $2"
  ;;

-lista | --lista)
  printf '%-8s %-25s %s\n' "PID" "NÉV" "STÁTUSZ"
  awk '{ printf "%-8s %-25s %s\n", $1, $2, $3 }' "$AKTUALIS"
  ;;

*)
  usage
  ;;
esac
