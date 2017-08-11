#!/bin/bash -e
. /etc/profile.d/modules.sh
module add ci
module add  gcc/${GCC_VERSION}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
make check

echo $?

make install
mkdir -p ${REPO_DIR}
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       FASTJET_VERSION       $VERSION
setenv       FASTJET_DIR           /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-${GCC_VERSION}
prepend-path LD_LIBRARY_PATH   $::env(FASTJET_DIR)/lib
setenv CPPFLAGS            "-I$::env(FASTJET_DIR)/include $CPPFLAGS"
setenv LDFLAGS           "-L$::env(FASTJET_DIR)/lib $LDFLAGS"
MODULE_FILE
) > modules/$VERSION-gcc-${GCC_VERSION}

mkdir -vp ${HEP}/${NAME}
cp -v modules/$VERSION-gcc-${GCC_VERSION} ${HEP}/${NAME}

echo "checking module availability"
module avail ${NAME}
echo "checking module "
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}
