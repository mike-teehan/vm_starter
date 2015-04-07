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

if [ "$MODE" == "install" ] ; then
	echo "Installing:"
	echo "vm_starter.sh -> /bin"
	cp vm_starter.sh /bin/
	echo "vm_starter.conf -> /etc"
	cp vm_starter.conf /etc/
	echo "vm_starter -> /etc/default"
	cp vm_starter /etc/default/
	echo
	echo "Remeber to:"
	echo "- set VM_START=true in /etc/default/vm_starter"
	echo "- configure a boot string in /etc/vm_starter.conf"
	echo "- add '/bin/vm_starter.sh' to the end of /etc/rc.local"
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
