#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  printf 'Hasznalat: %s <logfile>\n' "$0" >&2
  exit 1
fi

logfile=$1

if [[ ! -f "$logfile" || ! -r "$logfile" ]]; then
  printf 'Hiba: a fajl nem letezik, vagy nem olvashato: %s\n' \
    "$logfile" >&2
  exit 1
fi

awk '
function sortByCount(keys, counts, n, i, j, k, tmp, tmpc) {
    for (i = 2; i <= n; i++) {
        k = keys[i]
        tmpc = counts[k]
        j = i - 1

        while (j >= 1 &&
               (counts[keys[j]] < tmpc ||
               (counts[keys[j]] == tmpc && keys[j] > k))) {
            keys[j + 1] = keys[j]
            j--
        }

        keys[j + 1] = k
    }
}

function sortByKey(keys, n, i, j, k) {
    for (i = 2; i <= n; i++) {
        k = keys[i]
        j = i - 1

        while (j >= 1 && keys[j] > k) {
            keys[j + 1] = keys[j]
            j--
        }

        keys[j + 1] = k
    }
}

NF >= 11 {
    total++
    ip_count[$1]++

    if (!($1 in seen_ip)) {
        seen_ip[$1] = 1
        unique_ips++
    }

    status = $9 + 0
    status_count[status]++

    if (status >= 400 && status < 600) {
        error_count[$7]++
    }

    response = $11 + 0
    response_sum += response

    if (status == 200) {
        sum_200 += response
        count_200++
    }

    if (status == 500) {
        sum_500 += response
        count_500++
    }

    hour = substr($4, 2, 14)
    hour_count[hour]++
}

END {
    if (total == 0) {
        print "Hiba: a logfajlban nincs feldolgozhato rekord." \
            > "/dev/stderr"
        exit 2
    }

    printf "Riport:\n\n"
    printf "Osszes keres:       %d\n", total
    printf "Egyedi IP-cimek:    %d\n\n", unique_ips

    n = 0
    for (ip in ip_count) {
        ip_keys[++n] = ip
    }

    sortByCount(ip_keys, ip_count, n)

    printf "Top 10 legaktivabb ip:\n"
    printf "%-20s %12s\n", "IP-cim", "Keresszam"

    top = (n < 10 ? n : 10)

    for (i = 1; i <= top; i++) {
        ip = ip_keys[i]
        printf "%-20s %12d\n", ip, ip_count[ip]
    }

    printf "\n2. Http statuszok:\n"
    printf "%-15s %12s %12s\n", "Statusz", "Darab", "Szazalek"

    n = 0
    for (s in status_count) {
        status_keys[++n] = s
    }

    sortByKey(status_keys, n)

    for (i = 1; i <= n; i++) {
        s = status_keys[i]
        printf "%-15s %12d %11.2f%%\n", \
            s, status_count[s], 100 * status_count[s] / total
    }

    printf "\n3. Hibas keresek:\n"
    printf "%-35s %12s\n", "Url", "Darab"

    n = 0
    for (url in error_count) {
        error_keys[++n] = url
    }

    sortByCount(error_keys, error_count, n)

    if (n == 0) {
        printf "Nem volt 4xx vagy 5xx hiba.\n"
    } else {
        for (i = 1; i <= n; i++) {
            url = error_keys[i]
            printf "%-35s %12d\n", url, error_count[url]
        }
    }

    printf "\n4. Orankenti forgalom:\n"
    printf "%-20s %12s\n", "Datum, ora", "Keresszam"

    n = 0
    peak_hour = ""
    peak_count = 0

    for (h in hour_count) {
        hour_keys[++n] = h

        if (hour_count[h] > peak_count) {
            peak_count = hour_count[h]
            peak_hour = h
        }
    }

    sortByKey(hour_keys, n)

    for (i = 1; i <= n; i++) {
        h = hour_keys[i]
        printf "%-20s %12d\n", h, hour_count[h]
    }

    printf "Csucsora: %s (%d keres)\n", peak_hour, peak_count

    printf "\n5. Atlagos valaszido:\n"
    printf "%-25s %15s\n", "Keresek", "Atlag (sec)"
    printf "%-25s %15.3f\n", "Osszes", response_sum / total

    if (count_200 > 0) {
        printf "%-25s %15.3f\n", "HTTP 200", sum_200 / count_200
    } else {
        printf "%-25s %15s\n", "HTTP 200", "N/A"
    }

    if (count_500 > 0) {
        printf "%-25s %15.3f\n", "HTTP 500", sum_500 / count_500
    } else {
        printf "%-25s %15s\n", "HTTP 500", "N/A"
    }

    if (n > 0) {
        ip = ip_keys[1]
        printf "\n6. Kovetkeztetes:\n"
        printf "A legaktivabb IP a %s, ami az osszes keres %.2f%%-aert felel.\n", \
            ip, 100 * ip_count[ip] / total
    }
}
' "$logfile"
