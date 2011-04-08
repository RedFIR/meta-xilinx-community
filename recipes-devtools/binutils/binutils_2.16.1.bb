require recipes-devtools/binutils/binutils.inc

PR = "r0"

LIC_FILES_CHKSUM="\
    file://src-release;endline=17;md5=86129096d3b755e5e2367ccb229c2af2\
    file://COPYING;md5=0636e73ff0215e8d672dc4c32c317bb3\
    file://COPYING.LIB;md5=f30a9716ef3762e3467a2f62bf790f0a\
    file://gas/COPYING;md5=ceab81aa1f02825092808fdafba0239d\
    file://include/COPYING;md5=94d55d512a9ba36caa9b7df079bae19f\
    file://libiberty/COPYING.LIB;md5=7fbc338309ac38fefcd64b04bb903e34\
    file://bfd/COPYING;md5=ceab81aa1f02825092808fdafba0239d\
    "

SRCREV = "29c4a5daf35f045c8a7da730473388c7fddb5af3"
SRC_URI = "\
     git://developer.petalogix.com/toolchain/binutils.git;protocol=git \
     file://binutils-uclibc-300-001_ld_makefile_patch.patch;patchdir=${WORKDIR}/git \
     file://binutils-uclibc-300-006_better_file_error.patch;patchdir=${WORKDIR}/git \
     file://binutils-uclibc-300-012_check_ldrunpath_length.patch;patchdir=${WORKDIR}/git \
     file://binutils-uclibc-gas-needs-libm.patch;patchdir=${WORKDIR}/git \
     file://binutils-x86_64_i386_biarch.patch;patchdir=${WORKDIR}/git \
     file://libtool-2.4-update.patch;patchdir=${WORKDIR}/git \
     file://binutils-2.19.1-ld-sysroot.patch;patchdir=${WORKDIR}/git \
     file://libiberty_path_fix.patch;patchdir=${WORKDIR}/git \
     file://binutils-poison.patch;patchdir=${WORKDIR}/git \
     file://libtool-rpath-fix.patch;patchdir=${WORKDIR}/git \
     "

S = "${WORKDIR}/git"

# Todo: rework patchs
#     file://binutils-uclibc-100-uclibc-conf.patch \
#     file://110-arm-eabi-conf.patch \

BBCLASSEXTEND = "native"
