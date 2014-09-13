OpenNebula 用户指南 
--
> 作者：黑洞(heidsoft@sina.com)   
> 翻译opennebula-4.8-user-guide  
> 于2014年9月12日

#认识QEMU
	A modified version of QEMU, which is an open-source software program
	that emulates a full computer system, including a processor and various
	peripherals. It provides the ability to host operating systems in full virtualization mode.
	QEMU的修改版本,这是一个开源软件程序模拟一个完整的计算机系统,包括一个处理器和各种外围设备。它提供了宿主操作系统在全虚拟化模式的能力。

#认识基于Xen的虚拟机
##Xen-Based Virtual Machines
	A Xen-based virtual machine, also referred to as a VM Guest or DomU consists
	of the following components:

* At least one virtual disk that contains a bootable operating system. The
virtual disk can be based on a file, partition, volume, or other type of block
device.  
至少一个虚拟磁盘,其中包含一个可引导的操作系统。可以基于一个文件,虚拟磁盘分区,卷,或其它类型的块设备。

* Virtual machine configuration information, which can be modified by exporting a text-based configuration file from Xend or through Virtual Machine
Manager.

* A number of network devices, connected to the virtual network provided
by the controlling domain.


#认识OpenNebula如何定义虚拟机
	Defining a VM in 3 Steps 
	定义虚拟机分为三个部分


	NAME = test-vm
	MEMORY = 128
	CPU = 1
	DISK = [ IMAGE = "Arch Linux" ]
	DISK = [ TYPE = swap,
	SIZE = 1024 ]
	NIC = [ NETWORK = "Public", NETWORK_UNAME="oneadmin" ]
	GRAPHICS = [
	TYPE = "vnc",
	LISTEN = "0.0.0.0"]


##pend Pending
	By default a VM starts in the pending state, waiting for a resource to run on. It will stay in
	this state until the scheduler decides to deploy it, or the user deploys it using the onevm
	deploy command

	默认一个VM开始处于等待状态,等待资源上运行。它会呆在这种状态直到调度器决定部署它,或者使用onevm deploy 命令部署

##hold Hold
	The owner has held the VM and it will not be scheduled until it is released. It can be,
	however, deployed manually
	VM的所有者一直held[?],它将不会安排,直到它被释放。然后可以,手动部署

##prol Prolog 
	The system is transferring the VM files (disk images and the recovery file) to the host in
	which the virtual machine will be running.
	系统传输VM文件(磁盘映像和恢复文件)的主机将运行的虚拟机。
##boot Boot
	OpenNebula is waiting for the hypervisor to create the VM
	opennebula 等候hypervisor创建虚拟机
##runn Running 
	The VM is running (note that this stage includes the internal virtualized machine booting and shutting down phases). In this state, the virtualization driver will periodically monitor it.
	
	VM运行(注意,这个阶段包括内部虚拟机启动和关闭阶段)。在这种状态下,虚拟化驱动程序将定期监控它
##migr Migrate 
	The VM is migrating from one resource to another. This can be a life migration or cold
	migration (the VM is saved and VM files are transferred to the new resource).
	虚拟机从一个资源迁移到另一个。这可能是一个在线迁移或冷迁移(保存虚拟机和虚拟机文件转移到新的资源)。
##hotp Hotplug 
	A disk attach/detach, nic attach/detach operation is in process.
	磁盘附加/分离,nic附加/分离操作过程。
##snap Snapshot
	A system snapshot is being taken
	系统快照

##save Save
	The system is saving the VM files after a migration, stop or suspend operation
	系统保存VM文件迁移后,停止或暂停操作

##epil Epilog
	In this phase the system cleans up the Host used to virtualize the VM, and additionally disk
	images to be saved are copied back to the system datastore.
	在这一阶段系统清理主机用于虚拟化VM,而且磁盘
	图像保存复制回系统数据存储。

##shut Shutdown
	OpenNebula has sent the VM the shutdown ACPI signal, and is waiting for it to complete
	the shutdown process. If after a timeout period the VM does not disappear, OpenNebula will
	assume that the guest OS ignored the ACPI signal and the VM state will be changed to
	running, instead of done.
	OpenNebula 发送信号ACPI关闭VM,等待它完成关闭过程。如果在超过时间VM不消失,OpenNebula将
	假设客户机操作系统忽略了ACPI和VM状态将改变为运行时,而不去关闭。

##stop Stopped 
	The VM is stopped. VM state has been saved and it has been transferred back along with the
	disk images to the system datastore.
	VM停止。VM状态被保存和转移回一起系统数据存储磁盘映像。
##susp Suspende
	Same as stopped, but the files are left in the host to later resume the VM there (i.e. there is no need to re-schedule the VM).
	类似停止虚拟机,但主机恢复虚拟机文件都在上面(即有不需要重新安排VM)。

##poff PowerOff
	Same as suspended, but no checkpoint file is generated. Note that the files are left in the host to later boot the VM there.
	When the VM guest is shutdown, OpenNebula will put the VM in this state.
	类似暂停,但没有检查文件生成。注意文件的主机后启动VM。
	当关闭客户机操作系统,OpenNebula将VM在这种状态。

##unde Undeploy
	The VM is shut down. The VM disks are transfered to the system datastore. The VM can be
	resumed later.
	虚拟机是关闭的。虚拟机磁盘转移到系统数据存储。VM可以 以后恢复。

##fail Failed
	The VM failed.

##unkn Unknown 
	The VM couldn’t be reached, it is in an unknown state.
	无法联系到VM,它处于未知状态。

##done Done
	The VM is done. VMs in this state won’t be shown with onevm list but are kept in the
	database for accounting purposes. You can still get their information with the onevm show
	command.
	done即为做完了

#认识VM的生命周期
#state
	'INIT','PENDING','HOLD','ACTIVE','STOPPED','SUSPENDED',
	'DONE','FAILED','POWEROFF','UNDEPLOYED'

##lcm_state 
	'LCM_INIT','PROLOG','BOOT','RUNNING','MIGRATE',
	'SAVE_STOP','SAVE_SUSPEND','SAVE_MIGRATE',
	'PROLOG_MIGRATE','PROLOG_RESUME','EPILOG_STOP',
	'EPILOG','SHUTDOWN','CANCEL','FAILURE','CLEANUP_RESUBMIT','UNKNOWN',
	'HOTPLUG','SHUTDOWN_POWEROFF','BOOT_UNKNOWN','BOOT_POWEROFF',
	'BOOT_SUSPENDED','BOOT_STOPPED','CLEANUP_DELETE','HOTPLUG_SNAPSHOT',
	'HOTPLUG_NIC','HOTPLUG_SAVEAS','HOTPLUG_SAVEAS_POWEROFF',
	'HOTPLUG_SAVEAS_SUSPENDED','SHUTDOWN_UNDEPLOY',
	'EPILOG_UNDEPLOY','PROLOG_UNDEPLOY','BOOT_UNDEPLOY'


#认识VM状态变化的特征

	任何状态都能执行的操作：delete:{failure,done}

##变为running状态的流程
	1、	【ANY{suspended,poweroff,done}】 ---------------------->【pending】
		
	2、	【pending】-------------------------------------------->【hold】
		
	3、	【pending】-------------------------------------------->【prolog】
		
	4、	【prolog】--------------------------------------------->【boot】
		
	5、	【boot】----------------------------------------------->【running】   boot初始化后，启动VM
	


##变为suspended状态
	【boot】状态---------------------执行resume动作-------------------------->【suspended】状态   boot初始化后，启动VM
	【save】状态---------------------执行suspend动作-------------------------->【suspended】状态   boot初始化后，启动VM


##变为save状态
	【running】---------------------执行stop动作-------------------------->【save】
	【running】---------------------执行suspend动作-------------------------->【save】
	【running】---------------------执行migrate动作-------------------------->【save】

##变为migrate状态
	【save】---------------------执行migrate动作-------------------------->【migrate】

##变为hotplug

##变为snopshort
