#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
module add deploy
module add  gcc/${GCC_VERSION}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"
rm -rf
../configure \
--prefix=${SOFT_DIR}-gcc-${GCC_VERSION} \
--enable-allplugins
make

make install
echo "Creating the modules file directory ${HEP}"
mkdir -p ${HEP}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/FASTJET-deploy"
setenv FASTJET_VERSION       $VERSION
setenv FASTJET_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-${GCC_VERSION}
prepend-path LD_LIBRARY_PATH   $::env(FASTJET_DIR)/lib
setenv CPPFLAGS            "-I${FASTJET_DIR}/include $CPPFLAGS"
setenv LDFLAGS           "-L${FASTJET_DIR}/lib $LDFLAGS"
MODULE_FILE
) > ${HEP}/${NAME}/${VERSION}-gcc-${GCC_VERSION}



echo "checking module availability"
module avail ${NAME}
echo "checking module "
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}
