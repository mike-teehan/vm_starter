#!/bin/bash

if [ $(whoami) != "root" ] ; then
	echo "Installer must be run as root!"
	echo "Hint: $ sudo ./install.sh"
	exit 1
fi

MODE="install"
if [ "$1" == "-u" ] ; then
	MODE="uninstall"
fi
if [ "$1" == "-d" ] ; then
	MODE="deautostart"
fi

if [ "$MODE" == "install" ] ; then
	echo "Installing:"
	echo "vm_starter.sh -> /bin"
	cp vm_starter.sh /bin/
	if ! [ -f /etc/vm_starter.conf ] ; then
		echo "vm_starter.conf -> /etc"
		cp vm_starter.conf /etc/
	fi
	if ! [ -f /etc/default/vm_starter ] ; then
		echo "vm_starter -> /etc/default"
		cp vm_starter /etc/default/
	fi
	echo
	echo "Remember to:"
	echo "- set VM_START=true in /etc/default/vm_starter"
	echo "- configure a boot string in /etc/vm_starter.conf"
	echo "- add '/bin/vm_starter.sh' to the end of /etc/rc.local"
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

if [ "$MODE" == "uninstall" ] ; then
	echo "Unnstalling:"
	echo "rm /bin/vm_starter.sh"
	rm /bin/vm_starter.sh
	echo "rm /etc/vm_starter.conf"
	rm /etc/vm_starter.conf
	echo "rm /etc/default/vm_starter"
	rm /etc/default/vm_starter
	echo
	echo "Remember to:"
	echo "- remove '/bin/vm_starter.sh' from /etc/rc.local"
	exit 0
fi

if [ "$MODE" == "deautostart" ] ; then
	VMS=$(virsh list --autostart | tail -n+3 | awk '{ print $2 }' | grep -v '^$')
	for VM in $VMS; do
		virsh autostart $VM --disable
	done
	exit 0
fi
