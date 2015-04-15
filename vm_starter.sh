#!/bin/bash

VM_START=false
if [ -f /etc/default/vm_starter ] ; then
	. /etc/default/vm_starter
	if ! $VM_START; then
		echo "VM_START is false, not starting VMs..."
		exit 0
	fi
fi

BOOTSTRING=""
BOOTVMS=()
if [ -f /etc/vm_starter.conf ] ; then
	. /etc/vm_starter.conf
fi
if [ ${#BOOTSTRING} -gt 0 ] ; then
	BOOTVMS=(${BOOTSTRING})
fi

VMCNT="${#BOOTVMS[@]}"
echo "VMCNT: ${VMCNT}"
if ! [ $VMCNT -gt 0 ] ; then
	echo "No VMs to boot..."
	exit 0
fi

while true; do
	virsh list > /dev/null 2>&1
	[ $? -gt 0 ] || break
	echo "Virsh not started yet..."
	sleep 1
done

AVAILVMS=$(virsh list --all | tail -n+3 | awk '{ print $2 }' | grep -v '^$')

COUNT=1
for CMD in "${BOOTVMS[@]}"; do
	echo "CMD #${COUNT}: '${CMD}'"
	if [[ $CMD =~ ^[0-9]+$ ]] ; then
		echo "Sleeping ${CMD} seconds..."
		sleep $CMD
	else
		if [ $(echo "${AVAILVMS}" | grep "${CMD}" | wc -l) -gt 0 ] ; then
			echo "Starting VM ${CMD}..."
			virsh start $CMD
		else
			echo "VM ${CMD} not found..."
		fi
	fi
	echo
	COUNT=$[COUNT +1]
done
