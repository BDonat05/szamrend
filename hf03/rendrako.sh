#!/usr/bin/env bash

set -euo pipefail

# Argumentumok ellenorzese
if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Hasznalat: $0 KONYVTAR [--rendezd]" >&2
    exit 1
fi

dir=$1
rendez=false

if [[ $# -eq 2 ]]; then
    if [[ $2 != "--rendezd" ]]; then
        echo "Hiba: ismeretlen kapcsolo: $2" >&2
        exit 1
    fi
    rendez=true
fi

# A konyvtar ellenorzese
if [[ ! -d $dir ]]; then
    echo "Hiba: a konyvtar nem letezik: $dir" >&2
    exit 1
fi

# Jelentes
echo "jelentes: $dir"

fajlok=$(find "$dir" -type f | wc -l)
konyvtarak=$(find "$dir" -type d | wc -l)

echo "Fajlok szama: $fajlok"
echo "Konyvtarak szama: $konyvtarak"

echo
echo "Az 5 legnagyobb fajl:"

find "$dir" -type f -printf '%s\t%p\0' |
    sort -z -nr |
    head -z -n 5 |
    while IFS= read -r -d '' sor; do
        meret=${sor%%$'\t'*}
        nev=${sor#*$'\t'}
        printf "%s byte\t%s\n" "$meret" "$nev"
    done

echo
echo "30 napnal regebben modositott fajlok:"

regiek=$(find "$dir" -type f -mtime +30 | wc -l)
echo "Darab: $regiek"

echo
echo "Ures fajlok:"

find "$dir" -type f -empty -print

echo
echo "Kiterjesztesek szerinti megoszlas:"

find "$dir" -type f -printf '%f\n' |
    awk '
    {
        if ($0 !~ /\./) {
            ext = "[nincs kiterjesztes]"
        } else {
            ext = $0
            sub(/^.*\./, "", ext)
            if (ext == "") {
                ext = "[nincs kiterjesztes]"
            }
        }
        count[ext]++
    }
    END {
        for (ext in count) {
            printf "%5d %s\n", count[ext], ext
        }
    }' |
    sort -rn

echo
echo "Mindenki altal irhato fajlok"

find "$dir" -type f -perm -o+w -print

# Rendezes
if [[ $rendez == true ]]; then
    echo
    echo "FIGYELEM! Rendrakas kapcsolo hasznalva"
    echo "A fajlok masolva lesznek, az eredetiek megmaradnak."
    echo "A mindenki altal irhato fajlokrol levesszuk az o+w jogot."
    read -r -p "Folytatod? (y/n): " valasz

    if [[ $valasz != "y" ]]; then
        echo "A rendrakas megszakitva."
        exit 0
    fi

    cel="$dir/_rendezett"
    mkdir -p "$cel"

    # Masolas kiterjesztes szerint
    find "$dir" -type f \
        ! -path "$cel/*" \
        -print0 |
        while IFS= read -r -d '' f; do
            nev=${f##*/}
            if [[ $nev == *.* && $nev != .* ]]; then
                ext=${nev##*.}
                if [[ -z $ext ]]; then
                    ext="_egyeb"
                fi
            else
                ext="_egyeb"
            fi

            mkdir -p "$cel/$ext"
            cp -n -- "$f" "$cel/$ext/"
        done

    echo
    echo "Jogosultsagok javitasa:"

    find "$dir" -type f -perm -o+w -print0 |
        while IFS= read -r -d '' f; do
            printf "Jogosultsag javitasa: %s\n" "$f"
            chmod o-w -- "$f"
        done

    echo "Rendrakas befejezve"
else
    echo
    echo "Jelentes kesz"
fi
