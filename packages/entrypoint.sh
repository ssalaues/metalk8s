#!/bin/bash

set -e
set -u
set -o pipefail

buildsrpm() {
    set -x
    chown build:build /home/build
    su -l build rpmdev-setuptree
    for src in ${SOURCES:-}; do
        cp "/rpmbuild/SOURCES/${src}" "/home/build/rpmbuild/SOURCES/${src}"
        chown build:build "/home/build/rpmbuild/SOURCES/${src}"
    done
    cp "/rpmbuild/SPECS/${SPEC}" "/home/build/rpmbuild/SPECS/${SPEC}"
    chown build:build "/home/build/rpmbuild/SPECS/${SPEC}"
    su -l build -c "rpmbuild -bs /home/build/rpmbuild/SPECS/${SPEC}"
    su -l build -c "rpmlint -f /rpmbuild/rpmlintrc /home/build/rpmbuild/SRPMS/${SRPM}"
    cp "/home/build/rpmbuild/SRPMS/${SRPM}" "/rpmbuild/SRPMS/${SRPM}"
    chown "${TARGET_UID}:${TARGET_GID}" "/rpmbuild/SRPMS/${SRPM}"
}

buildrpm() {
    set -x
    yum-builddep -y "/rpmbuild/SRPMS/${SRPM}"
    chown build:build /home/build
    su -l build rpmdev-setuptree
    su -l build -c "rpmbuild --rebuild /rpmbuild/SRPMS/${SRPM}"
    for file in ${RPMS}; do
        su -l build -c "rpmlint -f /rpmbuild/rpmlintrc /home/build/rpmbuild/RPMS/${file}"
    done
    for file in ${RPMS}; do
        cp "/home/build/rpmbuild/RPMS/${file}" "/rpmbuild/RPMS/$(basename "${file}")"
        chown "${TARGET_UID}:${TARGET_GID}" "/rpmbuild/RPMS/$(basename "${file}")"
    done
}

buildrepo() {
    set -x
    mkdir /tmp/repodata
    chown build:build /tmp/repodata
    createrepo --outputdir /tmp/repodata /repository
    cp -a /tmp/repodata/repodata/. /repository/repodata/
    chown -R "${TARGET_UID}:${TARGET_GID}" /repository/repodata/
}

case ${1:-''} in
    buildrpm)
        buildrpm
        ;;
    buildsrpm)
        buildsrpm
        ;;
    buildrepo)
        buildrepo
        ;;
    '')
        exec /bin/bash
        ;;
    *)
        exec "$@"
        ;;
esac