-------------------
OpenNebula 深入分析
-------------------

#容量清单

	属性	 描述
	NAME	 如果名字是空的，那么默认名字是：one-<VID>
	MEMORY	 单位是Mb，是为虚拟机RAM分配的内存大小
	CPU	 Percentage of CPU divided by 100 required for the Virtual Machine. Half a processor is written 0.5.
	VCPU	 Number of virtual cpus. This value is optional, the default hypervisor behavior is used, usually one virtual CPU

	#镜像类型
	opennebula有三种类型的镜像，可以通过oneimage chtype改变镜像的类型。
	OS：此种镜像包含一个完整的os，每一个virtual template必须包含一个OS型的镜像作为root disk
	CDROM：此种镜像包含只读的数据
	DATABLOCK：此种镜像作为数据的存储，能够被不同的vm访问和修改

    当镜像状态处于Error状态时，重新Enable 转为Ready状态


#镜像加入Context后，创建VM报错
	=======================================================================================
	Thu Aug 7 22:17:06 2014 [DiM][I]: New VM state is ACTIVE.
	Thu Aug 7 22:17:06 2014 [LCM][I]: New VM state is PROLOG.
	Thu Aug 7 22:17:07 2014 [LCM][I]: New VM state is BOOT
	Thu Aug 7 22:17:07 2014 [VMM][I]: Generating deployment file: /var/lib/one/opennebula/var/vms/213/deployment.0
	Thu Aug 7 22:17:07 2014 [VMM][I]: ExitCode: 0
	Thu Aug 7 22:17:07 2014 [VMM][I]: Successfully execute network driver operation: pre.
	Thu Aug 7 22:17:09 2014 [VMM][I]: Command execution fail: cat << EOT | /var/tmp/one/vmm/xen4/deploy '/var/lib/one/opennebula/var/datastores/0/213/deployment.0' '192.168.70.70' 213 192.168.70.70
	Thu Aug 7 22:17:09 2014 [VMM][I]: Error: Block device type "raw" is invalid.
	Thu Aug 7 22:17:09 2014 [VMM][E]: Unable
	Thu Aug 7 22:17:09 2014 [VMM][I]: ExitCode: 1
	Thu Aug 7 22:17:09 2014 [VMM][I]: Failed to execute virtualization driver operation: deploy.
	Thu Aug 7 22:17:09 2014 [VMM][E]: Error deploying virtual machine: Unable
	Thu Aug 7 22:17:09 2014 [DiM][I]: New VM state is FAILED
	=========================================================================================

#VNC日志
	=========================================================================================
	 378: 192.168.21.52: Plain non-SSL (ws://) WebSocket connection
	 378: 192.168.21.52: Version hybi-13, base64: 'False'
	 378: 192.168.21.52: Path: '/?token=2cga46s9piy1cde4qggj'
	 378: connecting to: 192.168.70.70:6105
	 385: handler exception: (9, 'Bad file descriptor')
	 379: 192.168.21.52: Plain non-SSL (ws://) WebSocket connection
	 379: 192.168.21.52: Version hybi-13, base64: 'False'
	 379: 192.168.21.52: Path: '/?token=gokz7mftkedb0x09l084'
	 379: connecting to: 192.168.70.70:6104
	 373: 192.168.21.52: Plain non-SSL (ws://) WebSocket connection
	 373: 192.168.21.52: Version hybi-13, base64: 'False'
	 373: 192.168.21.52: Path: '/?token=30qt4r6tmg0ldklbzslf'
	 373: connecting to: 192.168.70.70:6105
	==========================================================================================

#OpenNebula Context
>在iaas平台中，当用户创建一个虚拟机后，必须按照用户自定义的信息对虚拟机进行初始化，比如：主机名，用户名/密码，ip地址，mac地址等，另外，可能用户还想在虚拟机启动后，某些服务就已经被自动配置好了，比如ssh登录等。 所有这些对Virtual Machine的定制，在opennebula中是通过一个叫Context iso的文件来完成的。

>1. context iso的原理和功能
  opennebula把所有的用户对Virtual Machine的定制化信息都做成一个iso文件，然后在Virtual Machine启动的时候，将此iso文件挂载到VM的光驱中，然后执行光驱中的相对应的脚本来完成对VM的定制，整个过程非常类似VMWare的vmware-tools。

>2. context iso的生成过程
  opennebula生成context iso是由/opennebula-4.6.0/src/tm_mad/common/context脚本来实现的，下面详细分析此脚本的内容。

#md5码
>MD5中的MD代表Message Digest，就是信息摘要的意思，不过这个信息摘要不是信息内容的缩写，而是根据公开的MD5算法对原信息进行数学变换后得到的一个128位(bit)的特征码。

#Alpine Linux
	 A security-oriented, lightweight Linux distribution based on musl libc and Busybox.
     http://alpinelinux.org/
#radvd
	 Linux IPv6 Router Advertisement Daemon (radvd)
     http://www.litech.org/radvd/

#如何让 OpenNebula 虚拟机自动获得 IP 等网络配置信息？
>制作完 OpenNebula 的 Ubuntu 虚拟机镜像后需要对镜像配置一下以适应所在的网络运行环境，因为我们的 OpenNebula 虚拟机使用的是网桥的方式，所以虚拟机启动后会使用现有网络，并企图从 DHCP 服务器那里获得 IP 地址，如果 DHCP 服务器不做绑定的话这样随便获得的 IP 地址并不符合我们在 small_network.net (onevnet create small_network.net) 定义的要求，我们希望虚拟机启动后能从 small_network.net 这个网络配置文件中获得相应的 IP 地址。OpenNebula 里面的 Contextualizing 部分就是用来对付这种情况的，不过 VPSee 在这里介绍一个更简单的偷懒办法：直接用一个启动脚本来搞定。OpenNebula 已经为我们准备了类似的脚本，只需要根据自己的要求调整一下就可以了，这里介绍 for ubuntu 和 for centos 两个版本的脚本，还有 for debian 和 opensuse 的。

>Ubuntu 虚拟机
下载 for ubuntu 的 context 文件后放在合适的地方，这个脚本有点问题需要在下载的 vmcontext.sh 文件最后加上重启网络（/etc/init.d/networking restart）这行：

		$ wget http://dev.opennebula.org/attachments/download/378/vmcontext.sh 
		$ sudo -i
		# mv vmcontext.sh /etc/init.d/vmcontext
		# chmod +x /etc/init.d/vmcontext
		# ln -sf /etc/init.d/vmcontext /etc/rc2.d/S01vmcontext
		# echo "/etc/init.d/networking restart" >> /etc/init.d/vmcontext
		CentOS 虚拟机
		下载 for centos 的 context 文件后放在合适的地方：
		# wget http://dev.opennebula.org/projects/opennebula/repository/revisions/master/raw/share/scripts/centos-5/net-vmcontext/vmcontext
		# mv vmcontext.sh /etc/init.d/vmcontext
		# chmod +x /etc/init.d/vmcontext
		# chkconfig --add vmcontext
		# reboot
		还记得上次说的给 OpenNebula 虚拟机增加 swap 分区的问题吗，直接把激活 swap 的部分放在 vmcontext 里就不必每次创建虚拟机后再增加 swap 的繁琐工作了。


##模板Context中配置驱动错误日志
		=========================================================================================
		Fri Aug 8 01:39:46 2014 [DiM][I]: New VM state is ACTIVE.
		Fri Aug 8 01:39:46 2014 [LCM][I]: New VM state is PROLOG.
		Fri Aug 8 01:39:47 2014 [LCM][I]: New VM state is BOOT
		Fri Aug 8 01:39:47 2014 [VMM][I]: Generating deployment file: /var/lib/one/opennebula/var/vms/224/deployment.0
		Fri Aug 8 01:39:47 2014 [VMM][I]: ExitCode: 0
		Fri Aug 8 01:39:47 2014 [VMM][I]: Successfully execute network driver operation: pre.
		Fri Aug 8 01:39:49 2014 [VMM][I]: Command execution fail: cat << EOT | /var/tmp/one/vmm/xen4/deploy '/var/lib/one/opennebula/var//datastores/0/224/deployment.0' '192.168.70.70' 224 192.168.70.70
		Fri Aug 8 01:39:49 2014 [VMM][I]: Error: Device 51728 (vbd) could not be connected. /var/lib/one/opennebula/var//datastores/0/224/disk.2 is not a block device.
		Fri Aug 8 01:39:49 2014 [VMM][E]: Unable
		Fri Aug 8 01:39:49 2014 [VMM][I]: ExitCode: 1
		Fri Aug 8 01:39:49 2014 [VMM][I]: Failed to execute virtualization driver operation: deploy.
		Fri Aug 8 01:39:49 2014 [VMM][E]: Error deploying virtual machine: Unable
		Fri Aug 8 01:39:49 2014 [DiM][I]: New VM state is FAILED
		=========================================================================================

###cdrom是sr0的软链接

###Xen 命令
	xm create deployment.0

	xedit                xen-tmem-list-parse  xenlockprof          xenstore-exists      xentop
	xen-bugtool          xen-vmresync         xenmon.py            xenstore-list        xentrace
	xen-destroy          xenalyze             xenperf              xenstore-ls          xentrace_format
	xen-hptool           xenalyze.dump-raw    xenpm                xenstore-read        xentrace_setmask
	xen-hvmcrash         xenbaked             xenpmd               xenstore-rm          xentrace_setsize
	xen-hvmctx           xencons              xenstore             xenstore-watch       xenwatchdogd
	xen-list             xenconsoled          xenstore-chmod       xenstore-write       xev
	xen-python-path      xend                 xenstore-control     xenstored            xeyes

####解决not a block device，
######设置TARGET：xvdc:cdrom   
######设置DRIVER：file

	linux-xen01:/var/lib/one/opennebula/var/datastores/0/226 # cat d
	deployment.0  disk.0        disk.1        disk.2        disk.2.iso    
	linux-xen01:/var/lib/one/opennebula/var/datastores/0/226 # cat deployment.0 
	name = 'one-226'
	#O CPU_CREDITS = 256
	memory  = '2048'
	builder = 'hvm'
	boot = 'c'
	disk = [
	    'file:/var/lib/one/opennebula/var//datastores/0/226/disk.0,xvdb,w',
	    'file:/var/lib/one/opennebula/var//datastores/0/226/disk.1,xvda,w',
	    'file:/var/lib/one/opennebula/var//datastores/0/226/disk.2,xvdc:cdrom,r',
	]
	vif = [
	    ' mac=02:00:c0:a8:46:96,ip=192.168.70.150,bridge=br0',
	]
	vnc = '1'
	vnclisten = '0.0.0.0'
	vncunused = '0'
	vncdisplay = '226'

##模板Context
	#!/bin/sh -e
	mount -t iso9660 /dev/sdc /mnt
	if [ -f /mnt/context.sh ]; then
	  . /mnt/init.sh
	fi
	umount /mnt
	exit 0

##VM创建流程
- 上传镜像到存储

- 利用已经上传的镜像，制作一个包含ISO镜像的模板，同时该模板包括一个数据盘（此数据盘用于系统安装后的RootDisk）

- 通过该模板创建一个虚拟机

- 通过VNC控制台安装并配置虚拟机

- 将此时安装好的虚拟机删除掉(因为之前配置的DataBlock是设置了持久化的)

- 将原来安装了系统的Datablock 的镜像类型改为OS类型，并将持久化改为非持久化（以便持续对该OS使用，但是非持久化比持久化创建VM要慢很多）

