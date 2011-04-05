PR = "r0"
require gcc-${PV}.inc
require recipes-devtools/gcc/gcc-configure-target.inc
require recipes-devtools/gcc/gcc-package-target.inc

SRC_URI_append = "file://fortran-cross-compile-hack.patch"

ARCH_FLAGS_FOR_TARGET += "-isystem${STAGING_INCDIR}"

SRC_URI[md5sum] = "93d1c436bf991564524701259b6285a2"
SRC_URI[sha256sum] = "23bd0013d76ac6fb4537e5e8f4e5947129362dcc32f0d08563b7d4d9e44c0e17"
