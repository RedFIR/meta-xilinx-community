# License applies to this recipe code, not the toolchain itself
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${POKYBASE}/LICENSE;md5=3f40d7994397109285ec7b81fdeb3b58"

PROVIDES = "\
    virtual/${TARGET_PREFIX}gcc \
    virtual/${TARGET_PREFIX}gcc-intermediate \
    virtual/${TARGET_PREFIX}gcc-initial \
    virtual/${TARGET_PREFIX}binutils \
    virtual/${TARGET_PREFIX}libc \
    "
#RPROVIDES = "glibc-utils libsegfault glibc-thread-db libgcc-dev libstdc++-dev libstdc++"
#PACKAGES_DYNAMIC = "glibc-gconv-*"
INHIBIT_DEFAULT_DEPS = "1"
PR = "r0"

SRCREV = "569081301f0f1d8d3b24335a364e8ff1774190d4"
SRC_URI = "git://git.xilinx.com/xldk/microblaze_v2.0.git;protocol=git"

S = "${WORKDIR}/git"

do_install() {
    cd ${S}

    install -d ${STAGING_DIR_TARGET}
    tar xf microblaze-unknown-linux-gnu.tgz

    cp -ar microblaze-unknown-linux-gnu/microblaze-unknown-linux-gnu/sys-root/* \
            ${STAGING_DIR_TARGET}
}

do_package[noexec] = "1"
do_package_write_ipk[noexec] = "1"
do_package_write_rpm[noexec] = "1"
do_package_write_deb[noexec] = "1"
