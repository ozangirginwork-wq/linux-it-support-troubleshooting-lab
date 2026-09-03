#!/usr/bin/env bash

set -u

MOUNT_POINT="${1:-/mnt/helpdesk-data}"
THRESHOLD="${2:-80}"
LOG_FILE="/var/log/helpdesk-disk-monitor.log"

if ! mountpoint -q "$MOUNT_POINT"; then
    TIMESTAMP="$(date --iso-8601=seconds)"
    echo "$TIMESTAMP status=ERROR mount=$MOUNT_POINT reason=not-mounted" | tee -a "$LOG_FILE"
    exit 2
fi

USAGE="$(df -P "$MOUNT_POINT" | awk 'NR==2 {gsub(/%/, "", $5); print $5}')"
TIMESTAMP="$(date --iso-8601=seconds)"

if (( USAGE >= THRESHOLD )); then
    STATUS="ALERT"
    EXIT_CODE=1
else
    STATUS="OK"
    EXIT_CODE=0
fi

MESSAGE="$TIMESTAMP status=$STATUS mount=$MOUNT_POINT usage=${USAGE}% threshold=${THRESHOLD}%"
echo "$MESSAGE" | tee -a "$LOG_FILE"

exit "$EXIT_CODE"

