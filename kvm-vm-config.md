<domain type='kvm' xmlns:qemu='http://libvirt.org/schemas/domain/qemu/1.0'>
	<name>one-2</name>
	<cputune>
		<shares>1024</shares>
	</cputune>
	<memory>524288</memory>
	<os>
		<type arch='x86_64'>hvm</type>
		<boot dev='cdrom'/>
	</os>
	<devices>
		<emulator>/usr/bin/kvm</emulator>
		<disk type='file' device='cdrom'>
			<source file='/home/oneadmin/var//datastores/0/2/disk.0'/>
			<target dev='vda'/>
			<readonly/>
			<driver name='qemu' type='raw' cache='none'/>
		</disk>
		<disk type='file' device='disk'>
			<source file='/home/oneadmin/var//datastores/0/2/disk.1'/>
			<target dev='vdb'/>
			<readonly/>
			<driver name='qemu' type='qcow2' cache='none'/>
		</disk>
		<interface type='bridge'>
			<source bridge='br0'/>
			<mac address='02:00:c0:a8:01:02'/>
		</interface>
	</devices>
	<features>
		<acpi/>
	</features>
</domain>
