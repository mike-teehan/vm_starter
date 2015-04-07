#!/bin/bash

BOOTSTRING=""
if [ -f /etc/vm_starter.conf ] ; then
	. /etc/vm_starter.conf
fi
BOOTVMS=("${BOOTSTRING}")

AVAILVMS=$(virsh list --all | tail -n+3 | awk '{ print $2 }' | grep -v '^$')

if [ -f /tmp/no_vm_start ] ; then
	Echo "/tmp/no_vm_start exists, not starting VMs..."
	return 0
fi

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
