#!/usr/bin/env bash

# Rendszerinformacio kiirasa a geprol
# Hasznalat: ./rendszerinfo.sh [fajlnev]
# Parameter nelkul a stdin-re ir
# A script 0-val ter vissza siker eseten, hibas celfajl eseten nem 0-val.

hostname="$(hostname)"
kernel="$(uname -r)"
uptime_info="$(uptime -p)"
user="$(whoami)"
home_size="$(du -sh "$HOME")"
disk_free="$(df -h /)"
processes="$(ps -e --no-headers | wc -l)"

output() {
printf '%-20s %s\n' "Hostname:" "$hostname"
printf '%-20s %s\n' "Kernel version:" "$kernel"
printf '%-20s %s\n' "Uptime:" "$uptime_info"
printf '%-20s %s\n' "User:" "$user"
printf '%-20s %s\n' "Home size:" "$home_size"
printf '%-20s %s\n' "Free space:" "$disk_free"
printf '%-20s %s\n' "Num of processes:" "$processes"
}

if [[ "$#" -eq 0 ]]; then
output
exit 0
fi

if [[ "$#" -eq 1 ]]; then
if ! output > "$1"; then
printf 'Nem sikerült irni a(z) "%s" fajlba.\n' "$1" >&2
exit 1
fi
exit 0
fi

printf 'Túl sok parameter. Hasznalat: %s [fajlnev]\n' "$0" >&2
exit 1
