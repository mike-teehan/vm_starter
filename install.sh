#!/bin/bash

#INSTALLDIR="/bin"
INSTALLDIR="/opt/vm_starter"

if [ $(whoami) != "root" ] ; then
	echo "Installer must be run as root!"
	echo "Hint: $ sudo ./install.sh"
	exit 1
fi

SYSTEMD="FALSE"
if [[ $(systemctl) =~ -\.mount ]] ; then
	SYSTEMD="TRUE"
fi

MODE="install"

# UNINSTALL (-u) to uninstall
if [ "$1" == "-u" ] ; then
	MODE="uninstall"
fi

# PURGE (-p) to UNINSTALL and delete /etc/vm_starter.conf too
if [ "$!" == "-p" ] ; then
	MODE="purge"
fi

# DEAUTOSTART (-d) and VMs currently marked 'autostart' by libvirt
if [ "$1" == "-d" ] ; then
	MODE="deautostart"
fi

# INSTALL
if [ "$MODE" == "install" ] ; then
	# make the install directory if it doesn't exist
	if [ ! -d "${INSTALLDIR}" ] ; then
		mkdir -p "${INSTALLDIR}"
	fi
	echo "Installing:"
	echo "vm_starter.sh -> ${INSTALLDIR}"
	cp vm_starter.sh "${INSTALLDIR}/"

	if ! [ -f /etc/vm_starter.conf ] ; then
		echo "vm_starter.conf -> /etc"
		cp vm_starter.conf /etc/
	fi

	if ! [ -f /etc/default/vm_starter ] ; then
		echo "vm_starter -> /etc/default"
		cp vm_starter /etc/default/
	fi

	if [ "${SYSTEMD}" == "TRUE" ] ; then
		cp vm_starter.service /etc/systemd/system/
	fi

	echo
	echo "Remember to:"
	echo "- set VM_START=true in /etc/default/vm_starter"
	echo "- configure a boot string in /etc/vm_starter.conf"
	if [ "${SYSTEMD}" == "FALSE" ]; then
		echo "- add '/bin/vm_starter.sh' to the end of /etc/rc.local"
	else
		echo "- run 'systemctl enable vm_starter'"
	fi
	VMS=$(virsh list --autostart | tail -n+3 | awk '{ print $2 }' | grep -v '^$')
	if [ ${#VMS} -gt 0 ] ; then
		echo
		echo "The following VMs are set to autostart by libvirt:"
		for VM in $VMS; do
			echo "- ${VM}"
		done
		echo "Disable them with 'install.sh -d'"
	fi
	echo
	exit 0
fi

if [ "$MODE" == "uninstall" ] || [ "$MODE" == "purge" ] ; then
	echo "Unnstalling:"
	echo "rm ${INSTALLDIR}/vm_starter.sh"
	rm "${INSTALLDIR}/vm_starter.sh"
	echo "rm /etc/default/vm_starter"
	rm /etc/default/vm_starter
	if [ "$MODE" == "purge" ] ; then
		echo "rm /etc/vm_starter.conf"
		rm /etc/vm_starter.conf
	fi
	echo
	echo "Remember to:"
	if [ "${SYSTEMD}" == "FALSE" ] ; then
		echo "- remove '/bin/vm_starter.sh' from /etc/rc.local"
	else
		echo "systemctl disable vm_starter"
		systemctl disable vm_starter
		echo "rm /etc/systemd/system/vm_starter.service"
		rm /etc/systemd/system/vm_starter.service
	fi
	exit 0
fi

if [ "$MODE" == "deautostart" ] ; then
	VMS=$(virsh list --autostart | tail -n+3 | awk '{ print $2 }' | grep -v '^$')
	for VM in $VMS; do
		virsh autostart $VM --disable
	done
	exit 0
fi
