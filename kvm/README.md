
<a name="KVM Installation on CentOS 6.x"></a>

#KVM Installation on CentOS 6.x


---

###Table of Contents

1. <a href="#Preliminary Check - Check Hardware Virtualization Support.">Preliminary Check - Check Hardware Virtualization Support.</a>
2. <a href="#Disable SELinux">Disable SELinux</a>
3. <a href="#Install KVM, QEMU and RPMs/packages.">Install KVM, QEMU and RPMs/packages.</a>
	 * <a href="#Install KVM, QEMU and user-space tools.">Install KVM, QEMU and user-space tools.</a>
	 * <a href="#Start libvirtd daemon, and set it to auto-start:">Start libvirtd daemon, and set it to auto-start:</a>
	 * <a href="#Check if KVM has successfully been installed.">Check if KVM has successfully been installed.</a>
	 * <a href="#Also we can do a `group install` (Optional)">Also we can do a `group install` (Optional)</a>
4. <a href="#Configure Linux Bridge for VM Networking">Configure Linux Bridge for VM Networking</a>
	 * <a href="#Install `bridge-utils`">Install `bridge-utils`</a>
	 * <a href="#Disable Network Manager.">Disable Network Manager.</a>
	 * <a href="#Create `bridge`">Create `bridge`</a>
5. <a href="#Install VirtManager">Install VirtManager</a>
	 * <a href="#To install VirtManager:">To install VirtManager:</a>
	 * <a href="#Launch VirtManager Remotely.">Launch VirtManager Remotely.</a>
	 * <a href="#Create `wrapper` for `virt-manager`">Create `wrapper` for `virt-manager`</a>
6. <a href="#Installing vnc-server.">Installing vnc-server.</a>
	 * <a href="#Initial Installation">Initial Installation</a>
	 * <a href="#Adding VNC user and setting `vncpasswd`">Adding VNC user and setting `vncpasswd`</a>
	 * <a href="#Logging in from Remote machine.">Logging in from Remote machine.</a>
	 * <a href="#Screenshot">Screenshot</a>
7. <a href="#Troubleshooting KVM and VirtManager setup">Troubleshooting KVM and VirtManager setup</a>
8. <a href="#Useful Links">Useful Links</a>

---



`KVM` is a `kernel-based Virutal Machine` which grows quickly in maturity and popularity in the Linux server market. Red Hat officially dropped `Xen` in favor of `KVM` since `RHEL 6`. With `KVM` being officially supported by Red Hat, installing `KVM` on RedHat-based systems should be a breeze.


<a name="Preliminary Check - Check Hardware Virtualization Support."></a>

##Preliminary Check - Check Hardware Virtualization Support.

We can check the `cpuinfo` details to check if our `h/w` can do VM.

	$ egrep -i 'vmx|svm' --color=always /proc/cpuinfo

If CPU flags contain "vmx" or "svm", it means hardware virtualization support is available.
IF NOT THEN DO NOT PROCEED.



<a name="Disable SELinux"></a>

##Disable SELinux

Before installing KVM, be aware that there are several SELinux booleans that can affect the behavior of KVM and libvirt. We will set `disable` in SELinux 

	#To disable SELinux on CentOS:
	$ sudo -e /etc/selinux/config
	
	SELINUX=disabled

Now reboot the server.



<a name="Install KVM, QEMU and RPMs/packages."></a>

##Install KVM, QEMU and RPMs/packages.

Install `KVM` and `virtinst` (a tool to create VMs).


<a name="Install KVM, QEMU and user-space tools."></a>

###Install KVM, QEMU and user-space tools.

	$ sudo yum install kvm libvirt python-virtinst qemu-kvm


<a name="Start libvirtd daemon, and set it to auto-start:"></a>

###Start libvirtd daemon, and set it to auto-start:
	
	$ sudo service libvirtd start
	$ sudo chkconfig libvirtd on


<a name="Check if KVM has successfully been installed."></a>

###Check if KVM has successfully been installed.
	
	$ sudo virsh -c qemu:///system list

	 Id    Name                           State
	----------------------------------------------------


<a name="Also we can do a `group install` (Optional)"></a>

###Also we can do a `group install` (Optional)

	$ sudo yum groupinstall "Virtualisation Tools" "Virtualization Platform"
	$ sudo yum install python-virtinst



<a name="Configure Linux Bridge for VM Networking"></a>

##Configure Linux Bridge for VM Networking

Installing KVM alone does not allow VMs to communicate with each other or access external networks. 
We will create a "bridged networking" via Linux bridge.


<a name="Install `bridge-utils`"></a>

###Install `bridge-utils`

Install a package needed to create and manage bridge devices:

	$ sudo yum install bridge-utils


<a name="Disable Network Manager."></a>

###Disable Network Manager.

Disable Network Manager service if it's enabled, and switch to default net manager as follows.

	$ sudo service NetworkManager stop
	$ sudo chkconfig NetworkManager off
	$ sudo chkconfig network on
	$ sudo service network start  


<a name="Create `bridge`"></a>

###Create `bridge`

To create a `bridge` we need to configure an active `network interface` like `eth0`.
Here we have a `static` IP assignment. 

Note : `copy` file `ifcfg-eth0` as `ifcfg-br0`, and edit them. 

	sudo vim /etc/sysconfig/network-scripts/ifcfg-eth0 

Add the below lines, we have added a `BRIDGE=br0`.


	DEVICE="eth0"
	NM_CONTROLLED="no"
	ONBOOT="yes"
	TYPE="Ethernet"
	BRIDGE=br0

Next we create a bridge `br0`

	sudo vim /etc/sysconfig/network-scripts/ifcfg-br0

Add below lines. Need to look out for - `DEVICE`, `BOOTPROTO`, `TYPE`

	DEVICE="br0"
	BOOTPROTO="static"
	NM_CONTROLLED="no"
	ONBOOT="yes"
	TYPE="Bridge"
	NETMASK=255.255.255.192
	IPADDR=10.10.18.36
	GATEWAY=10.10.18.1 

Now lets restart `network`

	$ sudo service network restart 

This will restart the Network. IMPORTANT : make sure we have the `bridge` configured correctly, else we will loose connectivity if we are on `ssh`.

	[ahmed@zahmed-server ~]$ ifconfig
	br0       Link encap:Ethernet  HWaddr A0:D3:C1:FA:25:C8
	          inet addr:10.10.18.36  Bcast:10.130.18.63  Mask:255.255.255.192
	          inet6 addr: fe80::a2d3:c1ff:fefa:25c8/64 Scope:Link
	          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
	          RX packets:2056649 errors:0 dropped:0 overruns:0 frame:0
	          TX packets:2027594 errors:0 dropped:0 overruns:0 carrier:0
	          collisions:0 txqueuelen:0
	          RX bytes:294572910 (280.9 MiB)  TX bytes:115946202 (110.5 MiB)
	
	eth0      Link encap:Ethernet  HWaddr A0:D3:C1:FA:25:C8
	          inet6 addr: fe80::a2d3:c1ff:fefa:25c8/64 Scope:Link
	          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
	          RX packets:2148683 errors:0 dropped:0 overruns:0 frame:0
	          TX packets:2030336 errors:0 dropped:0 overruns:0 carrier:0
	          collisions:0 txqueuelen:1000
	          RX bytes:338047294 (322.3 MiB)  TX bytes:136116027 (129.8 MiB)
	          Interrupt:32
	
	lo        Link encap:Local Loopback
	          inet addr:127.0.0.1  Mask:255.0.0.0
	          inet6 addr: ::1/128 Scope:Host
	          UP LOOPBACK RUNNING  MTU:16436  Metric:1
	          RX packets:6546 errors:0 dropped:0 overruns:0 frame:0
	          TX packets:6546 errors:0 dropped:0 overruns:0 carrier:0
	          collisions:0 txqueuelen:0
	          RX bytes:393148 (383.9 KiB)  TX bytes:393148 (383.9 KiB)
	
	virbr0    Link encap:Ethernet  HWaddr 52:54:00:C7:5E:B6
	          inet addr:192.168.122.1  Bcast:192.168.122.255  Mask:255.255.255.0
	          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
	          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
	          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
	          collisions:0 txqueuelen:0
	          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
	

<a name="Install VirtManager"></a>

##Install VirtManager

The final step is to install a desktop UI called VirtManager for managing virtual machines (VMs) through libvirt.



<a name="To install VirtManager:"></a>

###To install VirtManager:

	$ sudo yum install virt-manager libvirt qemu-system-x86 openss



<a name="Launch VirtManager Remotely."></a>

###Launch VirtManager Remotely.

	$ sudo yum install xauth 
	$ sudo vim /etc/ssh/sshd_config

Make sure we have the below line uncommented in `sshd_config`

	X11Forwarding yes



<a name="Create `wrapper` for `virt-manager`"></a>

###Create `wrapper` for `virt-manager`

Create a following executable `wrapper` script for virt-manager.

	$ sudo -e /usr/bin/vm

Add below lines to the file `vm`

	#! /bin/bash
	xauth list | while read line; do
		sudo -i xauth add $line
	done
	sudo -i virt-manager

Let give it `exe` permissions.

	$ sudo chmod +x /usr/bin/vm


<a name="Installing vnc-server."></a>

## Installing vnc-server.


<a name="Initial Installation"></a>

###Initial Installation

Installing base libraries for `vncserver` to work.

	sudo su
	yum groupinstall Desktop

Further install 
 	
	yum install gnome-core xfce4
	yum install tigervnc-server

Now make the service on after every reboot

	chkconfig vncserver on


<a name="Adding VNC user and setting `vncpasswd`"></a>

###Adding VNC user and setting `vncpasswd`

Assuming we already have a user on the server `ahmed`

	[root@ahmed-server ~]# su - ahmed
	[ahmed@ahmed-server ~]$ vncpasswd 
	Password:******
	Verify:******
	[ahmed@ahmed-server ~]$

Now lets configure `vncserver`

	sudo vim /etc/sysconfig/vncservers

Uncomment the line and add as below

	VNCSERVERS="2:ahmed"
	VNCSERVERARGS[2]="-geometry 1024x768"

Now restart `vncserver`.

	[root@ahmed-server ~]# service vncserver restart
	Shutting down VNC server:                                  [  OK  ]
	Starting VNC server: 2:ahmed xauth:  creating new authority file /home/ahmed/.Xauthority
	
	New 'ahmed-server:2 (ahmed)' desktop is ahmed-server:2
	
	Creating default startup script /home/ahmed/.vnc/xstartup
	Starting applications specified in /home/ahmed/.vnc/xstartup
	Log file is /home/ahmed/.vnc/ahmed-server:2.log
	
	                                                           [  OK  ]
	[root@server1 ~]# 


<a name="Logging in from Remote machine."></a>

###Logging in from Remote machine.

Install `vnc-viewer` and enter the `ip` address of `ahmed-server` followed `:2`, which is where the `vncserver` is listing.

	10.10.18.36:2

And the `password` will be the `vncpasswd` set during the configuration above.



<a name="Screenshot"></a>

### Screenshot

![Screen Shot](https://lh4.googleusercontent.com/-Bua9uz3zd-0/VOTXB_xPgqI/AAAAAAAAkeM/42LlKQ3_zVM/w622-h484-no/CompleteInstallation.PNG "VNC Screen Shot")


<a name="Troubleshooting KVM and VirtManager setup"></a>

##Troubleshooting KVM and VirtManager setup

>a. If you see the following error when attempting to launch VirtManager remotely, make sure that you use the wrapper script (vm) to launch it, as described above.

	X11 connection rejected because of wrong authentication.
	Traceback (most recent call last):
	  File "/usr/share/virt-manager/virt-manager.py", line 383, in 
	    main()
	  File "/usr/share/virt-manager/virt-manager.py", line 286, in main
	    raise gtk_error
	RuntimeError: could not open display

>b. If you see the following D-Bus error:

	D-Bus library appears to be incorrectly set up; failed to read machine
	uuid: UUID file '/var/lib/dbus/machine-id'

Then run the command below and reboot the host machine.

	$ sudo sh -c 'dbus-uuidgen > /var/lib/dbus/machine-id' 

>c. If you have font issue while running VirtManager, install the following font, and relaunch it.

	$ sudo yum install dejavu-lgc-sans-fonts 




<a name="Useful Links"></a>

## Useful Links

	http://xmodulo.com/install-configure-kvm-centos.html
	http://www.cyberciti.biz/faq/kvm-virtualization-in-redhat-centos-scientific-linux-6/
	https://www.howtoforge.com/vnc-server-installation-centos-6.5
	https://www.howtoforge.com/virtualization-with-kvm-on-a-centos-6.4-server-p4
	