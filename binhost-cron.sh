#!/bin/bash

set -ex

exec {lock_fd}>/home/user/binhost.lock || exit 1
flock -n "$lock_fd" || { echo "ERROR: flock() failed." >&2; exit 1; }

REMOTE_URL="$1"
LOG_FILE="/var/log/binhost/$(date -u +%Y%m%dT%H%M%SZ).log"

if [ -n "$REMOTE_URL" ]; then
    # Ensure trailing / for rsync
    if [ "${REMOTE_URL: -1}" != "/" ]; then
        REMOTE_URL="${REMOTE_URL}/"
    fi
    sudo emerge -uDN @world --quiet-build --buildpkg --buildpkg-exclude "app-emulation/qubes-*" 2>&1 | tee -a "$LOG_FILE"
    rsync -e "ssh -o StrictHostKeyChecking=no" -av --progress --no-perms --omit-dir-times /var/cache/binpkgs/ "$REMOTE_URL" | tee -a "$LOG_FILE"
fi

flock -u "$lock_fd"
