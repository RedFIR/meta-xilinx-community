require glibc_${PV}.bb
require recipes-core/glibc/glibc-initial.inc

do_configure_prepend () {
	unset CFLAGS
}
