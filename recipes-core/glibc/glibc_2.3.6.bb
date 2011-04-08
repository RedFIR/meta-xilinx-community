require recipes-core/glibc/glibc.inc

LIC_FILES_CHKSUM = "file://COPYING;md5=393a5ca445f6965873eca0259a17f833 \
                    file://elf/cache.c;beginline=1;endline=17;md5=892edaa7e827cce8e2bc73b96855641a \
                    file://COPYING.LIB;md5=bbb461211a33b134d42ed5ee802b37ff \
                    "
PACKAGES_DYNAMIC = "libc6*"
RPROVIDES_${PN}-dev = "libc6-dev virtual-libc-dev"

PR = "r0"

# the -isystem in bitbake.conf screws up glibc do_stage
BUILD_CPPFLAGS = "-I${STAGING_INCDIR_NATIVE}"
TARGET_CPPFLAGS = "-I${STAGING_DIR_TARGET}${includedir}"

GLIBC_ADDONS ?= ""

GLIBC_BROKEN_LOCALES = " _ER _ET so_ET yn_ER sid_ET tr_TR mn_MN gez_ET gez_ER bn_BD te_IN"

FILESPATH = "${@base_set_filespath([ '${FILE_DIRNAME}/glibc-${PV}', '${FILE_DIRNAME}/glibc-2.4', '${FILE_DIRNAME}/glibc', '${FILE_DIRNAME}/files', '${FILE_DIRNAME}' ], d)}"

#
# For now, we will skip building of a gcc package if it is a uclibc one
# and our build is not a uclibc one, and we skip a glibc one if our build
# is a uclibc build.
#
# See the note in gcc/gcc_3.4.0.oe
#

python __anonymous () {
    import bb, re
    uc_os = (re.match('.*uclibc$', bb.data.getVar('TARGET_OS', d, 1)) != None)
    if uc_os:
        raise bb.parse.SkipPackage("incompatible with target %s" %
                                   bb.data.getVar('TARGET_OS', d, 1))
}

RDEPENDS_${PN}-dev = "linux-libc-headers-dev"

SRCREV = "41dc4008d2141c7dc413811594d38792c6e89345"
SRC_URI = "git://developer.petalogix.com/toolchain/glibc.git;protocol=git \
           file://glibc-config.sub-microblaze-target-machine.patch;patchdir=${WORKDIR}/git \
		   file://glibc-accept-binutils-2.20.x-and-newer.patch;patchdir=${WORKDIR}/git \
	       file://glibc-microblaze-readelf-missing-dwarf-info.patch;patchdir=${WORKDIR}/git \
           file://manual-mixed-rules.patch;patchdir=${WORKDIR}/git \
           file://nscd-init.patch;patchdir=${WORKDIR}/git;striplevel=0 \
           file://fhs-linux-paths.patch;patchdir=${WORKDIR}/git \
           file://dl-cache-libcmp.patch;patchdir=${WORKDIR}/git \
           file://ldsocache-varrun.patch;patchdir=${WORKDIR}/git \
           file://nptl-crosscompile.patch;patchdir=${WORKDIR}/git \
           file://ldd-unbash.patch;patchdir=${WORKDIR}/git \
           file://etc/ld.so.conf;patchdir=${WORKDIR}/git \
           file://generate-supported.mk;patchdir=${WORKDIR}/git \
           file://zecke-sane-readelf.patch;patchdir=${WORKDIR}/git \
          "

S = "${WORKDIR}/git"
B = "${WORKDIR}/build-${TARGET_SYS}"

# We need this for nativesdk
export libc_cv_slibdir = "${base_libdir}"

EXTRA_OECONF = "--enable-kernel=${OLDEST_KERNEL} \
                --without-cvs --disable-profile --disable-debug --without-gd \
                --enable-clocale=gnu \
                --enable-add-ons=${GLIBC_ADDONS} \
                --with-headers=${STAGING_INCDIR} \
                --without-selinux \
                ${GLIBC_EXTRA_OECONF}"

EXTRA_OECONF += "${@get_libc_fpu_setting(bb, d)}"

do_configure () {
# /var/db was not included to FHS
	sed -i s:/var/db/nscd:/var/run/nscd: ${S}/nscd/nscd.h
# override this function to avoid the autoconf/automake/aclocal/autoheader
# calls for now
# don't pass CPPFLAGS into configure, since it upsets the kernel-headers
# version check and doesn't really help with anything
	if [ -z "`which rpcgen`" ]; then
		echo "rpcgen not found.  Install glibc-devel."
		exit 1
	fi
	(cd ${S} && gnu-configize) || die "failure in running gnu-configize"
	CPPFLAGS="" oe_runconf
}

rpcsvc = "bootparam_prot.x nlm_prot.x rstat.x \
          yppasswd.x klm_prot.x rex.x sm_inter.x mount.x \
          rusers.x spray.x nfs_prot.x rquota.x key_prot.x"

do_compile () {
	# -Wl,-rpath-link <staging>/lib in LDFLAGS can cause breakage if another glibc is in staging
	unset LDFLAGS
	base_do_compile
	(
		cd ${S}/sunrpc/rpcsvc
		for r in ${rpcsvc}; do
			h=`echo $r|sed -e's,\.x$,.h,'`
			rpcgen -h $r -o $h || oewarn "unable to generate header for $r"
		done
	)
}

require recipes-core/glibc/glibc-stage.inc
require recipes-core/glibc/glibc-package.inc

BBCLASSEXTEND = "nativesdk"
