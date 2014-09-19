SUSE_XEN手册
--
>作者:黑洞(heidsoft@sina.com)
 记录时间：2014-09-19
#Adding Virtual CD Readers

	When using a real CD reader , use the following command to assign the CD
	reader to your VM Guest. In this example, the name of the guest is alice:

	xm block-attach alice tap:cdrom:/dev/sr0 xvdb r

	When assigning an image file, use the following command:

	xm block-attach alice file:/path/to/file.iso xvdb r

	ls /sys/block

	mount -o ro /dev/xvdb /mnt

	Enter cat /proc/partitions in the virtual machine's terminal to view
	its block devices.

	First you need to append the dom0_max_vcpus=X to the Xen boot line in /boot/
	grub/menu.lst, where X is the number of VCPUs dedicated to Domain0. An example Kernel boot entry follows:
	title Xen -- SUSE Linux Enterprise Server 11 SP2 - 3.0.4-0.11
	root (hd0,1)
	kernel /boot/xen.gz dom0_max_vcpus=2
	module /boot/vmlinuz-3.0.4-0.11-xen
	module /boot/initrd-3.0.4-0.11-xen

	xm vcpu-pin Domain-0 0 0
	xm vcpu-pin Domain-0 1 1

#基于xen-vm-domain配置参数 
##bootloader 		
	(bootloader /usr/bin/pygrub)
##bootloader_args 
	(bootloader_args -q)
##cpus 			
	 xm vcpu-pin (cpus ((1 2) (1 2)))
##cpu_time 		
	(cpu_time 59.157413326)
##description 	
	(cpu_time 59.157413326)
##devices         
	(device { console | pci | vbd | vfb | vif | vkbd | vusb })
###console
	(console { location | protocol | uuid })
####location
	(location 'localhost:5901')
####protocol
	vt100 Standard vt100 terminal.
	rfb Remote Frame Buffer protocol (for VNC).
	rdp Remote Desktop protocol
####uuid
	Unique identifier for this device. Example:
	(uuid 7892de3d-2713-a48f-c3ba-54a7574e283b)
###pci
	(pci { dev | uuid })
	Defines the device of a PCI device that is dedicated to the given VM Guest. The PCI
	device number is organized as [[[[domain]:]bus]:][slot][.[func]].
####dev
	(dev { bus | domain | func | slot | uuid | vslt })
	Defines the path to the PCI device that is dedicated to the given VM Guest.
	bus
	A PCI device with device number 03:02.1 has the bus number 0x03
	(bus 0x03)
	domain
	Most computers have only one PCI domain. This is then 0x0. T o check the domain
	numbers of the PCI devices, use lspci -D.
	(domain 0x0)
	func
	A PCI device with device number 03:02.1 has the function number
	(func 0x1)
	slot
	A PCI device with device number 03:02.1 has the function number
	(slot 0x02)
	uuid
	Unique identifier for this device. Example:
	(uuid d33733fe-e36f-fa42-75d0-fe8c8bc3b4b7)
	vslt
	Defines the virtual slot for the PCI device in the VM Guest system.
	(vslt 0x0)
###vbd
	(vbd { backend | bootable | dev | mode | protocol | uname | uuid | VDI })
	Defines a virtual block device.

###vfb
####backend
	All paravirtualized virtual devices are implemented by a “split device driver”. This
	expression defines the domain that holds the back-end device that the front-end device
	of the current VM Guest should connect to. Example:
	(backend 0)
####bootable
	Defines if this block device is bootable. Example:
	(bootable 1)
####dev
	Defines the device name of the virtual block device in the VM Guest. Example:
	(dev xvda:disk)
####mode
	Defines if the device is writable. Example:
	(mode w)
	SXP Configuration Options 133
####protocol
	Defines the I/O protocol to use for the VM Guest. Example:
	(protocol x86_64-abi)
####uname
	Defines where the virtual block device really stores its data. See also Section 7.1,
	“Mapping Physical Storage to Virtual Disks” (page 63). Example:
	(uname file:/var/lib/xen/images/sles11/disk1)
####uuid
	Unique identifier for the current virtual block device. Example:
	(uuid 7892de3d-2713-a48f-c3ba-54a7574e283b)
####VDI
	Defines if the current virtual block device is a virtual disk image (VDI). This is a readonly setting. Example:
	(VDI)

###vif
	(vif { backend | bridge | mac | model | script | uuid })
	The virtual interface definition is used to create and set up virtual network devices. T o
	list, add, or remove network interfaces during runtime, you can use xm with the commands network-list, network-attach, and network-detach.
####backend
	Defines the back-end domain that is used for paravirtualized network interfaces. Example:
	(backend 0)
	SXP Configuration Options 135
####bridge
	Defines the bridge where the virtual network interface should connect to. Example:
	(bridge br0)
####mac
	Defines the mac address of the virtual network interface. The mac addresses reserved
	for Xen virtual network interfaces look like 00:16:3E:xx:xx:xx. Example:
	(mac 00:16:3e:32:e7:81)
####model
	When using emulated IO, this defines the network interface that should be presented
	to the VM Guest. See also Section 6.2, “Network Devices for Guest Systems” (page 53).
	Example:
	(model rtl8139)
####script
	Defines the script to use to bring the network interface up or down. Example:
	(script /etc/xen/scripts/vif-bridge)
####uuid
	Unique identifier for the current virtual network device. Example:
	(uuid cc0d3351-6206-0f7c-d95f-3cecffec793f)
###vkbd
	(vkbd { backend })
	Defines a virtual keyboard and mouse device. This is needed for paravirtualized VM
	Guest systems and must be defined before vfb devices.
#####backend
	Defines the backend domain that is used for paravirtualized keyboard interfaces. Example:
	(backend 0)
###vusb
	(vusb { backend | num-ports | usb-ver | port-? })
	Defines a virtual USB controller for the VM Guest. This is needed before any USB
	device can be assigned to the guest.
####backend
	Defines the back-end domain that is used for USB devices. Example:
	(backend 0)
####num-ports
	Defines the number of ports that the virtual USB host controller provides for the VM
	Guest. Example:
	(num-ports 8)
####usb-ver
	Define which USB revision should be used. Note, that unlike the real USB revision
	numbers, this is only an integer . Example:
	(usb-ver 2)
####port-?
	Starting with port-1, depending on num-ports there are several port-? sections
	available. If a USB device is assigned to the VM Guest, the respective device number
	is added to the port number . Example:
	(port-1 4-2)
##image
	(image { linux | HVM })
	This is the container for the main machine configuration. The actual image type is either
	Linux or HVM for fully virtualized guests. HVM is only available if your computer
	supports VMX and also activates this feature during boot.
	1 linux
	(linux { args | device_model | kernel | notes })
	The linux image definition is used for paravirtualized Linux installations.
	1.1 args
	When booting a kernel from the image definition, args defines extra boot parameters
	for the kernel. Example:
	(args ' sax2=1')
	1.2 device_model
	The device model used by the VM Guest. This defaults to qemu-dm. Example:
	(device_model /usr/lib/xen/bin/qemu-dm)
	1.3 kernel
	Defines the path to the kernel image this VM Guest should boot. Defaults to no image.
	Example:
	(kernel /boot/vmlinuz)
	1.4 notes
	Displays several settings and features available to the current VM Guest.
	2 hvm
	(hvm { acpi | apic | boot | device_model | extid | guest_os_type | hap | hpet
	| isa | kernel | keymap | loader | localtime | monitor | nographic | notes
	138 Virtualization with Xen
	| pae | pci | rtc_timeoffset | serial | stdvga | timer_mode | usb | usbdevice
	| vnc | vncunused | xauthority })
	The HVM image definition is used for all fully virtualized installations.
	2.1 acpi
	Defines if ACPI (Advanced Configuration and Power Interface) functionality should
	be available to the VM Guest. Example:
	(acpi 1)
	2.2 apic
	Defines if ACPI (Advanced Programmable Interrupt Controller) functionality should
	be available to the VM Guest. Example:
	(apic 1)
	2.3 boot
	Defines the drive letter to boot from. Example:
	(boot c)
	2.4 device_model
	The device model used by the VM Guest. This defaults to qemu-dm. Example:
	(device_model /usr/lib/xen/bin/qemu-dm)
	2.5 extid
	Defines whether a guest should use Hyper-V extensions. Only applies to guests types
	that support Hyper-V . Example:
	(extid 1)
	2.6 guest_os_type
	Defines the guest operating system type. Allowed values are default, linux, and
	windows. Currently, this has only an effect on Itanium systems. Example:
	(guest_os_type default)
	SXP Configuration Options 139
	2.7 hap
	Defines if hardware assisted paging should be enabled. Enabled with value 1, disabled
	with value 0. Example:
	(hap 1)
	2.8 hpet
	Defines if the emulated multimedia timer hpet should be activated. Enabled with
	value 1, disabled with value 0. Example:
	(hpet 0)
	2.9 isa
	Defines if an ISA-only system should be emulated. Example:
	(isa 0)
	2.10 kernel
	Defines the path to the kernel image this VM Guest should boot. Defaults to no image.
	Example:
	(kernel )
	2.11 keymap
	Defines the language to use for the input. Example:
	(keymap de)
	2.12 loader
	Defines the path to the HVM boot loader . Example:
	(loader /usr/lib/xen/boot/hvmloader)
	2.13 localtime
	Defines if the emulated RTC uses the local time. Example:
	(localtime 1)
	140 Virtualization with Xen
	2.14 monitor
	Defines if the device model (for example, qemu-dm) should use monitor. Use Ctrl +
	Alt + 2 in the VNC viewer to connect to the monitor. Example:
	(monitor 0)
	2.15 nographic
	Defines if the device model should disable the graphics support. Example:
	(nographic 0)
	2.16 notes
	Displays several settings and features available to the current VM Guest. Example:
	(notes (SUSPEND_CANCEL 1))
	2.17 pae
	Enable or disable P AE (Physical Address Extension) of the HVM VM Guest. Example:
	(pae 1)
	2.18 pci
	(pci Bus:Slot.Function
	Add a given PCI device to a VM Guest. This must be supported by the hardware and
	can be added multiple times. Example:
	(pci 03:02.1)
	2.19 rtc_timeoffset
	Defines the offset between local time and hardware clock. Example:
	(rtc_timeoffset 3600)
	2.20 serial
	Defines Domain0 serial device that will be connected to the hvm VM Guest. T o connect
	/dev/ttyS0 of Domain0 to the HVM VM Guest, use:
	SXP Configuration Options 141
	(serial /dev/ttyS0)
	2.21 stdvga
	Defines if a standard vga (cirrus logic) device should be used. Example:
	(stdvga 0)
	2.22 timer_mode
	Defines if the timer should be delayed when ticks are missed or if the real time should
	always be used. 0 delays the virtual time, 1 always uses the real time.
	(timer_mode 0)
	2.23 usb
	Defines if USB devices should be emulated. Example:
	(usb 1)
	2.24 usbdevice
	Adds the specified USB device to the VM Guest.
	(usbdevice tablet)
	2.25 vnc
	Defines if VNC should be enabled for graphics. Example:
	(vnc 1)
	2.26 vncunused
	If not set to 0, this option enables the VNC server on the first unused port above 5900.
	(vncunused 1)
	2.27 xauthority
	When using SDL, the specified file is used to define access rights. If not set, the value
	from the XAUTHORITY environment variable is used. Example:
	(xauthority /root/.Xauthority)

##案例
	Example 7.1: Example: V irtual Machine Output fr om Xend
	(vbd
	(dev xvda:disk)
	(uname file:/var/lib/xen/images/sles11/disk0)
	(mode w)
	(type disk)
	(backend 0)
	)

