#!/usr/bin/env bash
echo "stuff"
echo -n "nincs sortores"
echo #csak sortores
echo

printf "nev: %s\n" "$USER"
echo "asd" >proba.txt
echo "asd2" >>proba.txt

cat proba.txt

ls nincs_ilyen_file 2>hiba.txt
ls nincs_ilyen_file &>/dev/null

cat hiba.txt
head -2 proba.txt # elso ket sor
tail -1 proba.txt # utolso sor
wc -l proba.txt   #hany sor
wc -w proba.txt   #hany szo

nev="doooonut"
echo "nev: $nev"
mai_datum=$(date +%Y-%m-%d)
echo "ma $mai_datum van"

echo "Ennek a scriptnek a neve: $0"
echo "Kaptunk $#db parametert"
echo "Ezek a parameterek: $*"
echo "Az elso parameter: $1"

grep "asd" proba.txt
