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
	BOOTVMS=("${BOOTSTRING}")
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

array_contains () {
	local array="$1[@]"
	local val=$2
	local in=1
	for element in "${!array}"; do
		if [[ $element == $val ]]; then
			in=0
			break
		fi
	done
	return $in
}

COUNT=1
for CMD in $BOOTVMS; do
	echo "CMD #${COUNT}: '${CMD}'"
	if [[ $CMD =~ ^[0-9]+$ ]] ; then
		echo "Sleeping ${CMD} seconds..."
		sleep $CMD
	else
		if array_contains AVAILVMS $CMD ; then
			echo "Starting VM ${CMD}..."
			virsh start $CMD
		else
			echo "VM ${CMD} not found..."
		fi
	fi
	echo
	COUNT=$[COUNT +1]
done
