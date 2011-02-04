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
#More to come soon ;)

def uboot_machine(a, d):
    import re

    board = bb.data.getVar('XILINX_BOARD', d, 1)
    target = bb.data.getVar('TARGET_CPU', d, 1)
    if re.match('powerpc', a):
        if board == 'ml507':
            return 'ml507_config'
        elif board == 'ml405':
            return 'ml405_config'
        else:
            return 'xilinx-ppc' + target + '-generic_config'
    else:
        return target + '-generic_config'

def uboot_target(a, d):
    import re

    board = bb.data.getVar('XILINX_BOARD', d, 1)
    target = bb.data.getVar('TARGET_CPU', d, 1) + '-generic'
    if re.match('powerpc', a):
        if board == 'ml507':
            return 'ml507'
        elif board == 'ml405':
            return 'ml405'
        else:
            return 'ppc' + target
    else:
        return target

do_configure_prepend() {
#first check that the XILINX_BSP_PATH and XILINX_BOARD have been defined in local.conf
#now depending on the board type and arch do what is nessesary
if [ -n "${XILINX_BSP_PATH}" ]; then
	if [ -n "${XILINX_BOARD}" ]; then
		if [ -d "${S}/board/xilinx" ]; then
			oenote "Replacing xparameters header to match hardware model"
			if [ "${TARGET_ARCH}" == "powerpc" ]; then
				xparam="${XILINX_BSP_PATH}/ppc${TARGET_CPU}_0/include/xparameters.h"
				cpu="PPC`echo ${TARGET_CPU} | tr '[:lower:]' '[:upper:]'`"
			else
				xparam="${XILINX_BSP_PATH}/${TARGET_CPU}_0/include/xparameters.h"
				cpu=`echo ${TARGET_CPU} | tr '[:lower:]' '[:upper:]'`
			fi
			if [ -e "$xparam" ]; then
				cp ${xparam} ${S}/board/xilinx/${UBOOT_TARGET}
				echo "/*** Cannonical definitions ***/
#define XPAR_PLB_CLOCK_FREQ_HZ XPAR_PROC_BUS_0_FREQ_HZ
#define XPAR_CORE_CLOCK_FREQ_HZ XPAR_CPU_${cpu}_CORE_CLOCK_FREQ_HZ
#ifndef XPAR_DDR2_SDRAM_MEM_BASEADDR
# define XPAR_DDR2_SDRAM_MEM_BASEADDR XPAR_DDR_SDRAM_MPMC_BASEADDR
#endif
#define XPAR_PCI_0_CLOCK_FREQ_HZ    0" >> ${S}/board/xilinx/${UBOOT_TARGET}/xparameters.h
			else
				oefatal "No xparameters header file found, missing hardware ref design?"
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
	fi
fi
}
