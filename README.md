gentoo-binhost
===

Some notes about how to set up a Gentoo `binhost` (see [[1]](https://wiki.gentoo.org/wiki/Project:Binhost)) with the help of Gitlab CI.

An instance of this setup is hosted by the author and can be found at https://gentoo.notset.fr/repo/standard/.

# Installation

## Gitlab Runner

Add `gitlab` overlay:
```bash
$ emerge app-eselect/eselect-repository
$ eselect repository enable gitlab
$ emerge --sync
```

Emerge `gitlab-runner-bin`:
```bash
$ echo 'dev-util/gitlab-runner-bin ~amd64' > /etc/portage/package.accept_keywords/gitlab-runner
$ emerge dev-util/gitlab-runner-bin
```

Register runner:
```bash
$ /usr/libexec/gitlab-runner/gitlab-runner register
(...)
```

Allow `gitlab-runner` user to `emerge`:
```bash
$ echo 'gitlab-runner ALL = NOPASSWD: /usr/bin/emerge' > /etc/sudoers.d/gitlab-runner
```

Add `gitlab-runner` to `portage` group to allow `gitlab-runner` to copy `/var/log/portage`:
```bash
$ usermod -aG portage gitlab-runner
```
> FIXME: is there a better solution?

Enable and start `gitlab-runner`:
```bash
$ systemctl enable gitlab-runner
$ systemctl start gitlab-runner
```

# Configuration

Profile and packages list can be adapted. Here we use what is provided for Qubes OS [Gentoo templates](https://github.com/QubesOS/qubes-builder-gentoo).

## Profile and packages list

| Flavor  | Profile                                        | Packages list                                                                                                  | USE flags                                                                                                    | KEYWORDS                                                                                                                 |
|---------|------------------------------------------------|----------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------|
| GNOME   | default/linux/amd64/17.1/desktop/gnome/systemd | [gnome](https://raw.githubusercontent.com/QubesOS/qubes-builder-gentoo/master/scripts/packages_gnome.list)     | [gnome](https://raw.githubusercontent.com/QubesOS/qubes-builder-gentoo/master/scripts/package.use/gnome)     | [gnome](https://raw.githubusercontent.com/QubesOS/qubes-builder-gentoo/master/scripts/package.accept_keywords/gnome)     |
| XFCE    | default/linux/amd64/17.1/desktop/gnome/systemd | [xfce](https://raw.githubusercontent.com/QubesOS/qubes-builder-gentoo/master/scripts/packages_xfce.list)       | [xfce](https://raw.githubusercontent.com/QubesOS/qubes-builder-gentoo/master/scripts/package.use/xfce)       | [xfce](https://raw.githubusercontent.com/QubesOS/qubes-builder-gentoo/master/scripts/package.accept_keywords/xfce)       |
| MINIMAL | default/linux/amd64/17.1/systemd               | [minimal](https://raw.githubusercontent.com/QubesOS/qubes-builder-gentoo/master/scripts/packages_minimal.list) | [minimal](https://raw.githubusercontent.com/QubesOS/qubes-builder-gentoo/master/scripts/package.use/minimal) | [minimal](https://raw.githubusercontent.com/QubesOS/qubes-builder-gentoo/master/scripts/package.accept_keywords/minimal) |

## Portage

Add to `/etc/portage/make.conf`:
```bash
FEATURES="buildpkg binpkg-logs clean-logs split-log"
PORTAGE_LOGDIR="/var/log/portage"
PORTAGE_LOGDIR_CLEAN="find \"\${PORTAGE_LOGDIR}\" -type f ! -name \"summary.log*\" -mtime +7 -delete"
```

## Remote host

A remote host is assumed to be configured to allow incoming SSH connections and to serve a web server. Each job will rsync `/var/cache/binpkgs` to the corresponding remote
location per flavor.

# Usage

## Build updates

From [[2]](https://wiki.gentoo.org/wiki/Binary_package_guide), the following command:
```bash
$ emerge -uDN @world --quiet-build --buildpkg
```

is scheduled in order to publish `binpkg` for every updates.

## Full rebuild

On a fully operational Gentoo system (physical of virtual), it may be needed to run the first time, a full rebuild of
all packages. In order to do that, we recommend pretending the full rebuild to see if something goes wrong:

```bash
$ emerge -pe @world --quiet-build --buildpkg
```

If no error is noticed:
```bash
$ emerge -e @world --quiet-build --buildpkg
```

# NOTSET

On the hosted instance by the author, each Qubes OS gentoo template is used to create three independent `binhost` as
virtual machines. They are registered as Gitlab runners. Artifacts and logs of builds can be found 
at [fepitre-bot/gentoo-binhost](https://gitlab.notset.fr/fepitre-bot/gentoo-binhost/).

# References

1. https://wiki.gentoo.org/wiki/Project:Binhost
2. https://wiki.gentoo.org/wiki/Binary_package_guide.
