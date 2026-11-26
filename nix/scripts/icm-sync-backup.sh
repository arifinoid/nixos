#!/usr/bin/env bash
# Dump the icm-sync canonical SQLite store and keep the last 14 daily copies.
# Runs as the icm-sync user via systemd (see vps-icm-sync.nix).
set -euo pipefail

bin=${1:?usage: icm-sync-backup.sh <icm-sync-api binary>}
data_dir=/var/lib/icm-sync
backup_dir=/var/backups/icm-sync
keep=14

mkdir -p "$backup_dir"

target="$backup_dir/icm-sync-$(date -u +%Y%m%dT%H%M%SZ).db"
ICM_SYNC_DB="$data_dir/icm-sync.db" ICM_SYNC_BACKUP_PATH="$target" "$bin" backup

# `ls -t` is newest first, so everything after the retention window goes.
ls -1t "$backup_dir"/icm-sync-*.db | tail -n +"$((keep + 1))" | while read -r old; do
  rm -f "$old"
done
