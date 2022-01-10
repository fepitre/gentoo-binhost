#!/bin/bash

set -ex

emerge --sync

cat >> /etc/portage/make.conf << EOF
FEATURES="buildpkg binpkg-logs clean-logs split-log"
PORTAGE_LOGDIR="/var/log/portage"
PORTAGE_LOGDIR_CLEAN="find \"\${PORTAGE_LOGDIR}\" -type f ! -name \"summary.log*\" -mtime +7 -delete"
EOF

echo 'user ALL = NOPASSWD: /usr/bin/emerge' > /etc/sudoers.d/user

mkdir /var/log/binhost
chown user:user /var/log/binhost
