#!/bin/bash

# read command line option
SHUTDOWN=false
if [ "$1" == "--shutdown" ]; then
	SHUTDOWN=true
fi

# check defaults to see if we are enabled
VM_START=false
if [ -f /etc/default/vm_starter ] ; then
	. /etc/default/vm_starter
	if ! $VM_START; then
		echo "VM_START is false, not starting VMs..."
		exit 0
	fi
fi

# parse the conf file
BOOTSTRING=""
BOOTVMS=()
if [ -f /etc/vm_starter.conf ] ; then
	. /etc/vm_starter.conf
fi
# if we are shutting down, reverse the boot string
if [ $SHUTDOWN = true ]; then
	BOOTSTRING=$(echo "${BOOTSTRING}" | awk '{ for(i=NF; i>0; i--) printf("%s ", $i); }')
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
			if ! $SHUTDOWN; then
				echo "Starting VM ${CMD}..."
				virsh start $CMD
			else
				echo "Shutting down VM ${CMD}..."
				virsh shutdown $CMD
			fi
		else
			echo "VM ${CMD} not found..."
		fi
	fi
	echo
	COUNT=$[COUNT +1]
done
