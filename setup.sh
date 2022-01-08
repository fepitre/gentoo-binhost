#!/bin/bash

set -ex

emerge app-eselect/eselect-repository
eselect repository enable gitlab
emerge --sync

echo 'dev-util/gitlab-runner-bin ~amd64' > /etc/portage/package.accept_keywords/gitlab-runner
emerge dev-util/gitlab-runner-bin

echo 'gitlab-runner ALL = NOPASSWD: /usr/bin/emerge' > /etc/sudoers.d/gitlab-runner

usermod -aG portage gitlab-runner

systemctl enable gitlab-runner
systemctl start gitlab-runner

cat >> /etc/portage/make.conf << EOF
FEATURES="buildpkg binpkg-logs clean-logs split-log"
PORTAGE_LOGDIR="/var/log/portage"
PORTAGE_LOGDIR_CLEAN="find \"\${PORTAGE_LOGDIR}\" -type f ! -name \"summary.log*\" -mtime +7 -delete"
EOF
