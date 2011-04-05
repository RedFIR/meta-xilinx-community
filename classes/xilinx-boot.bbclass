# Copyright (C) 2007, Stelios Koroneos - Digital OPSiS, All Rights Reserved
# Copyright (C) 2010, Adrian Alonso <aalonso00@gmail.com>
# Released under the MIT license (see packages/COPYING)
#
#This class handles all the intricasies of getting the required files from the
#ISE/EDK/project to the kernel and prepare u-boot bootloader for compilation.
#The Xilinx EDK supports 2 different architectures : PowerPC (ppc 405,440) and Microblaze
#Only the PowerPC BSP has been tested so far
#For this to work correctly you need to add XILINX_BSP_PATH and XILINX_BOARD to your
#local.conf
#XILINX_BSP_PATH should have the complete path to your project dir
#XILINX_BOARD should have the board type i.e ML403
#
#Currently tested on
#Xilinx ML405
#Xilinx ML507
#Xilinx ML403 configured as ML405 same processor core only changes FPGA density
#Xilinx ML510 configured as ML507
#More to come soon ;)

python __anonymous () {
    import re

    arch = bb.data.getVar('TARGET_ARCH', d, 1)
    board = bb.data.getVar('XILINX_BOARD', d, 1)
    cpu = bb.data.getVar('TARGET_CPU', d, 1)
    target = cpu + '-generic'

    if re.match('powerpc', arch):
        if board in ['ml507', 'ml510']:
            uboot_target = 'ml507'
            uboot_config = 'ml507_config'
        elif board in ['ml403', 'ml405']:
            uboot_target = 'ml405'
            uboot_config = 'ml405_config'
        else:
            uboot_target = 'pcc' + target
            uboot_config = 'xilinx-pcc' + cpu + '-generic_config'
    else:
        uboot_target = target
        uboot_config = arch + '-generic_config'

    bb.data.setVar('UBOOT_TARGET', uboot_target, d)
    bb.data.setVar('UBOOT_MACHINE', uboot_config, d)
}

# Find xparameters.h header in hardware project
find_xparam() {
# Search for xparameter header
headers=`find ${XILINX_BSP_PATH} -path "*/include/xparameters.h" -print`
# trim if multiple version are found
param=`echo ${headers} | cut -d ' ' -f1`

if [ -e "$param" ]; then
	echo "$param"
else
	echo "0"
fi
}

do_export_xparam() {
oenote "Replacing xparameters header to match hardware model"
xparam=$1
if [ "${TARGET_ARCH}" == "powerpc" ]; then
	cpu="PPC`echo ${TARGET_CPU} | tr '[:lower:]' '[:upper:]'`"
else
	cpu=`echo ${TARGET_CPU} | tr '[:lower:]' '[:upper:]'`
fi
cp ${xparam} ${S}/board/xilinx/${UBOOT_TARGET}
echo "/*** Cannonical definitions ***/
#define XPAR_PLB_CLOCK_FREQ_HZ XPAR_PROC_BUS_0_FREQ_HZ
#define XPAR_CORE_CLOCK_FREQ_HZ XPAR_CPU_${cpu}_CORE_CLOCK_FREQ_HZ
#ifndef XPAR_DDR2_SDRAM_MEM_BASEADDR
# define XPAR_DDR2_SDRAM_MEM_BASEADDR XPAR_DDR_SDRAM_MPMC_BASEADDR
#endif
#define XPAR_PCI_0_CLOCK_FREQ_HZ    0" >> ${S}/board/xilinx/${UBOOT_TARGET}/xparameters.h
}

do_mk_xparam() {
oenote "Replacing xparameters.mk configuration file"
xparam=$1
if [ "${TARGET_ARCH}" == "powerpc" ]; then
    if grep -qoe XPAR_IIC_0_DEVICE_ID ${xparam}; then
        echo -e "XPAR_IIC        := y" > ${S}/board/xilinx/${UBOOT_TARGET}/xparameters.mk
    else
        echo -e "XPAR_IIC        := n" > ${S}/board/xilinx/${UBOOT_TARGET}/xparameters.mk
    fi

    if grep -qoe XPAR_LLTEMAC_0_DEVICE_ID ${xparam}; then
        echo -e "XPAR_LLTEMAC    := y" >> ${S}/board/xilinx/${UBOOT_TARGET}/xparameters.mk
    else
        echo -e "XPAR_LLTEMAC    := n" >> ${S}/board/xilinx/${UBOOT_TARGET}/xparameters.mk
    fi

    if grep -qoe XPAR_SYSACE_0_DEVICE_ID ${xparam}; then
        echo -e "XPAR_SYSACE     := y" >> ${S}/board/xilinx/${UBOOT_TARGET}/xparameters.mk
    else
        echo -e "XPAR_SYSACE     := n" >> ${S}/board/xilinx/${UBOOT_TARGET}/xparameters.mk
    fi
fi
}

do_mk_sysace() {
oenote "Generate system ace image"
# Set Xilinx EDK tools
if [ -z ${XILINX_EDK} ]; then
	# Get Xilinx version
	if [ ${BUILD_ARCH} == "x86_64" ]; then
		EDK_SRCIPT="settings64.sh"
	else
		EDK_SRCIPT="settings.sh"
	fi
	# Strip EDK version
	XILINX_VER=`echo ${XILINX_LOC} | tr -d '[:alpha:]/_'`
	if [ "${XILINX_VER}" \> "13" ]; then
		source ${XILINX_LOC}/${EDK_SRCIPT} ${XILINX_LOC}
	else
		# EDK version prior to 13.1 require to additionaly source this scripts
		source ${XILINX_LOC}/${EDK_SRCIPT} ${XILINX_LOC}
		source ${XILINX_LOC}/ISE/${EDK_SRCIPT} ${XILINX_LOC}/ISE
		source ${XILINX_LOC}/EDK/${EDK_SRCIPT} ${XILINX_LOC}/EDK
	fi
fi

# The system ace image generation assumes that user had
# configure the project to use pcc440_0_bootloop software
# project to initialize bram
#
# Note:
# This could be ovirrided by setting in ${XILINX_BSP_PATH}/system_incl.make
# BRAMINIT_ELF_FILES = $(PPC440_0_BOOTLOOP)
# BRAMINIT_ELF_FILES_ARGS = -pe ppc440_0 $(PPC440_0_BOOTLOOP)
# For Xilinx EDK 13.1 Bootlop is set by default
#
cd ${XILINX_BSP_PATH}
if [ ! -f implementation/download.bit ]; then
	# Bitstream not found generate it
	make -f ${XILINX_BSP_PATH}/system.make init_bram
fi

if [ "${TARGET_ARCH}" == "powerpc" ]; then
	# Find u-boot start address
	start_address=`${TARGET_PREFIX}objdump -x u-boot | grep -w "start address" | cut -d ' ' -f3`
	# Generate ACE image
	xmd -tcl genace.tcl -hw implementation/download.bit -elf u-boot \
	-target ppc_hw -start_address ${start_address} -ace u-boot-${XILINX_BOARD}.ace \
	-board ${XILINX_BOARD}
fi
}

do_configure_prepend() {
#first check that the XILINX_BSP_PATH and XILINX_BOARD have been defined in local.conf
#now depending on the board type and arch do what is nessesary
if [ -n "${XILINX_BSP_PATH}" ]; then
	if [ -n "${XILINX_BOARD}" ]; then
        if [ -d "${S}/board/xilinx" ]; then
			xparam=$(find_xparam)
			if [ "$xparam" != "0" ]; then
				do_export_xparam $xparam
				do_mk_xparam $xparam
			else
				oefatal "No xparameters header file found, missing Xilinx SDK project"
				exit 1
			fi
        fi
	else
		oefatal "XILINX_BOARD not defined ! Exit"
		exit 1
	fi
else
	oefatal "XILINX_BSP_PATH not defined ! Exit"
	exit 1
fi
}

do_deploy_prepend() {
# Install u-boot elf image
if [ -d "${XILINX_BSP_PATH}" ]; then
	if [ -e "${S}/u-boot" ]; then
		install ${S}/u-boot ${XILINX_BSP_PATH}
		do_mk_sysace
		install ${XILINX_BSP_PATH}/u-boot-${XILINX_BOARD}.ace ${DEPLOYDIR}
	fi
fi
}
