require recipes-devtools/gcc/gcc-common.inc

DEPENDS =+ "mpfr gmp libmpc elfutils"
NATIVEDEPS = "mpfr-native gmp-native gettext-native libmpc-native elfutils-native"

LICENSE="GCC RUNTIME LIBRARY EXCEPTION & GPLv2 & GPLv3 & LGPLv2.1 & LGPLv3"

LIC_FILES_CHKSUM = "file://COPYING;md5=59530bdf33659b29e73d4adb9f9f6552 \
                   file://COPYING.LIB;md5=2d5025d4aa3495befef8f17206a5b0a1"

SRCREV = "8de38a58d6f48a7ff0498c2a4fec38f937a648e2"
SRC_URI = "git://developer.petalogix.com/toolchain/gcc.git;protocol=git \
          "

# Todo: rework crosscompiling related patchs
#
#	   file://gcc-4.3.1-ARCH_FLAGS_FOR_TARGET.patch;patchdir=${WORKDIR}/git \
#	   file://100-uclibc-conf.patch;patchdir=${WORKDIR}/git \
#           file://gcc-uclibc-locale-ctype_touplow_t.patch;patchdir=${WORKDIR}/git \
#	   file://cache-amnesia.patch;patchdir=${WORKDIR}/git \
#	   file://gcc-flags-for-build.patch;patchdir=${WORKDIR}/git \
#	   file://libstdc++-emit-__cxa_end_cleanup-in-text.patch;patchdir=${WORKDIR}/git \
#	   file://arm-bswapsi2.patch;patchdir=${WORKDIR}/git \
#		\
#           file://fedora/gcc43-c++-builtin-redecl.patch;striplevel=0;patchdir=${WORKDIR}/git \
#           file://fedora/gcc43-ia64-libunwind.patch;striplevel=0;patchdir=${WORKDIR}/git \
#           file://fedora/gcc43-java-nomulti.patch;striplevel=0;patchdir=${WORKDIR}/git \
#           file://fedora/gcc43-ppc32-retaddr.patch;striplevel=0;patchdir=${WORKDIR}/git \
#           file://fedora/gcc43-pr32139.patch;striplevel=0;patchdir=${WORKDIR}/git \
#           file://fedora/gcc43-pr33763.patch;striplevel=0;patchdir=${WORKDIR}/git \
#           file://fedora/gcc43-rh330771.patch;striplevel=0;patchdir=${WORKDIR}/git \
#           file://fedora/gcc43-rh341221.patch;striplevel=0;patchdir=${WORKDIR}/git \
#           file://fedora/gcc43-java-debug-iface-type.patch;striplevel=0;patchdir=${WORKDIR}/git \
#           file://fedora/gcc43-i386-libgomp.patch;striplevel=0;patchdir=${WORKDIR}/git \
#           file://fedora/gcc45-no-add-needed.patch;striplevel=0;patchdir=${WORKDIR}/git \
#           file://103-uclibc-conf-noupstream.patch;patchdir=${WORKDIR}/git  \
#           file://200-uclibc-locale.patch;patchdir=${WORKDIR}/git  \
#           file://203-uclibc-locale-no__x.patch;striplevel=1;patchdir=${WORKDIR}/git \
#           file://204-uclibc-locale-wchar_fix.patch;striplevel=1;patchdir=${WORKDIR}/git \
#           file://205-uclibc-locale-update.patch;striplevel=1;patchdir=${WORKDIR}/git \
#           file://301-missing-execinfo_h.patch;patchdir=${WORKDIR}/git  \
#           file://302-c99-snprintf.patch;patchdir=${WORKDIR}/git  \
#           file://303-c99-complex-ugly-hack.patch;patchdir=${WORKDIR}/git  \
#           file://304-index_macro.patch;patchdir=${WORKDIR}/git  \
#           file://305-libmudflap-susv3-legacy.patch;patchdir=${WORKDIR}/git  \
#           file://306-libstdc++-namespace.patch;patchdir=${WORKDIR}/git  \
#           file://740-sh-pr24836.patch;patchdir=${WORKDIR}/git  \
#           file://800-arm-bigendian.patch;patchdir=${WORKDIR}/git  \
#           file://904-flatten-switch-stmt-00.patch;patchdir=${WORKDIR}/git  \
#           file://arm-nolibfloat.patch;patchdir=${WORKDIR}/git  \
#           file://arm-softfloat.patch;patchdir=${WORKDIR}/git \
#           file://zecke-xgcc-cpp.patch;patchdir=${WORKDIR}/git \
#           file://gcc-poison-system-directories.patch;patchdir=${WORKDIR}/git \
#           file://gcc-poison-dir-extend.patch;patchdir=${WORKDIR}/git \
#           file://gcc-4.3.3-SYSROOT_CFLAGS_FOR_TARGET.patch;patchdir=${WORKDIR}/git \
#	   file://64bithack.patch;patchdir=${WORKDIR}/git \
#	   file://optional_libstdc.patch;patchdir=${WORKDIR}/git \
#	   file://disable_relax_pic_calls_flag.patch;patchdir=${WORKDIR}/git \
#	   file://gcc-poison-parameters.patch;patchdir=${WORKDIR}/git \
#	   file://GPLUSPLUS_INCLUDE_DIR_with_sysroot.patch;patchdir=${WORKDIR}/git \
#  file://COLLECT_GCC_OPTIONS.patch;patchdir=${WORKDIR}/git \
#	  "
	
SRC_URI_append_sh3  = " file://sh3-installfix-fixheaders.patch;patch=1 "

S = "${WORKDIR}/git"

# Language Overrides
FORTRAN = ""
JAVA = ""

#EXTRA_OECONF_BASE = "  --enable-cheaders=c_std \
#			--enable-libssp \
#			--disable-bootstrap \
#			--disable-libgomp \
#			--disable-libmudflap"
EXTRA_OECONF_BASE = " --enable-lto \
			--enable-libssp \
			--disable-bootstrap \
			--disable-libgomp \
			--disable-libmudflap \
			--enable-cheaders=c_global "

EXTRA_OECONF_INITIAL = "--disable-libmudflap \
			--disable-libgomp \
			--disable-libssp \
			--enable-decimal-float=no"

EXTRA_OECONF_INTERMEDIATE = "--disable-libmudflap \
				--disable-libgomp \
				--disable-libssp"

EXTRA_OECONF_append_linux-uclibc = " --disable-decimal-float "
EXTRA_OECONF_append_linux-uclibceabi = " --disable-decimal-float "
EXTRA_OECONF_append_linux-uclibcspe = " --disable-decimal-float "
