#!/usr/bin/env bash

set -uo pipefail

MOUNT_POINT="${1:-/mnt/helpdesk-data}"
THRESHOLD="${2:-80}"
LOG_FILE="${LOG_FILE:-/var/log/helpdesk-disk-monitor.log}"

write_log() {
    local message="$1"

    if ! printf '%s\n' "$message" | tee -a "$LOG_FILE"; then
        printf 'ERROR: unable to write to %s (run with appropriate permissions)\n' "$LOG_FILE" >&2
        exit 3
    fi
}

if [[ ! "$THRESHOLD" =~ ^[0-9]+$ ]] || (( THRESHOLD < 0 || THRESHOLD > 100 )); then
    printf 'ERROR: threshold must be an integer from 0 to 100\n' >&2
    exit 3
fi

TIMESTAMP="$(date --iso-8601=seconds)"

if ! mountpoint -q "$MOUNT_POINT"; then
    write_log "$TIMESTAMP status=ERROR mount=$MOUNT_POINT reason=not-mounted"
    exit 2
fi

if ! USAGE="$(df -P "$MOUNT_POINT" | awk 'NR==2 {gsub(/%/, "", $5); print $5}')"; then
    write_log "$TIMESTAMP status=ERROR mount=$MOUNT_POINT reason=df-failed"
    exit 3
fi

if [[ ! "$USAGE" =~ ^[0-9]+$ ]]; then
    write_log "$TIMESTAMP status=ERROR mount=$MOUNT_POINT reason=invalid-usage"
    exit 3
fi

if (( USAGE >= THRESHOLD )); then
    STATUS="ALERT"
    EXIT_CODE=1
else
    STATUS="OK"
    EXIT_CODE=0
fi

write_log "$TIMESTAMP status=$STATUS mount=$MOUNT_POINT usage=${USAGE}% threshold=${THRESHOLD}%"
exit "$EXIT_CODE"
