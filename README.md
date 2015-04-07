# vm_starter  
A simple utility to start libvirt VMs in a sensible manner when the server boots.  
### 1 - Installation:  
```
$ git clone https://github.com/mike-teehan/vm_starter
$ cd vm_starter
$ sudo ./install.sh
```
Use the text editor of your choice to manually add the following line to /etc/rc.local before the 'exit 0' line:
> /bin/vm_starter.sh  

### 2 - Configuration:
#### /etc/vm_starter.conf:
The BOOTSTRING is a space separated list of VM names and time delays. The list is evaluated left to right. 
All numeric values are treated as seconds to pause, and everything else is the name of a VM to be started.
##### Example:
Boot the VM called **fw**, wait 10 seconds, and then boot the VM called **windows**.  
```
BOOTSTRING="fw 10 windows"
```
#### /etc/default/vm_starter
The VM_START varible controls whether or not the VMs will be started at boot. Its default value, if undefined, is false.  
Be sure to use only "true" or "false", as Bash doesn't have the greatest handling of booleans...
```
VM_START=(false|true)
```
### 3 - Removal:
Use the install script with a '-u' parameter to permanently the files previously installed. 
```
$ sudo ./install.sh -u
```

### 4 - License:
This software is copyright Mike Teehan (<mike.teehan@gmail.com>) in the year 2015.  
It is licensed under the GPL v2. Please see the included LICENSE file and know your rights.

