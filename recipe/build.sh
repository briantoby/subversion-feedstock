#!/usr/bin/env bash
set -ex

if [[ -z "${MACOSX_DEPLOYMENT_TARGET}" ]] ; then
    export CFLAGS="${CFLAGS} -U__USE_XOPEN2K -std=c99"
else
    export CFLAGS="-isysroot ${CONDA_BUILD_SYSROOT} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET} ${CFLAGS} -U__USE_XOPEN2K -std=c99"
fi

./configure \
  --prefix="${PREFIX}" \
  --enable-svnxx \
  --enable-bdb6 \
  --with-sqlite="${PREFIX}" \
  --disable-static \
  --with-swig-perl=${BUILD_PREFIX}/bin/perl

make -j ${CPU_COUNT}
make -j ${CPU_COUNT} check CLEANUP=true TESTS=subversion/tests/cmdline/basic_tests.py
make install

make swig-pl-lib
make install-swig-pl-lib
pushd subversion/bindings/swig/perl/native
perl Makefile.PL PREFIX="${PREFIX}" INSTALLDIRS=site INSTALLARCHLIB="${PREFIX}/lib/perl5/5.32" INSTALLSITEARCH="${PREFIX}/lib/perl5/5.32/site_perl"
make install
popd
