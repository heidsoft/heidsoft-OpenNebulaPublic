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


#VNC日志

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
1. 制作完 OpenNebula 的 Ubuntu
虚拟机镜像后需要对镜像配置一下以适应所在的网络运行环境，因为我们的 OpenNebula 虚拟机使用的是网桥的方式，所以虚拟机启动后会使用现有网络，并企图从 DHCP 服务器那里获得 IP 地址，如果 DHCP 服务器不做绑定的话这样随便获得的 IP 地址并不符合我们在 small_network.net (onevnet create small_network.net) 定义的要求，我们希望虚拟机启动后能从 small_network.net 这个网络配置文件中获得相应的 IP 地址。OpenNebula 里面的 Contextualizing 部分就是用来对付这种情况的，不过 VPSee 在这里介绍一个更简单的偷懒办法：直接用一个启动脚本来搞定。OpenNebula 已经为我们准备了类似的脚本，只需要根据自己的要求调整一下就可以了，这里介绍 for ubuntu 和 for centos 两个版本的脚本，还有 for debian 和 opensuse 的。
2. Ubuntu 虚拟机
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


##虚拟机创建失败问题分析
1. 虚拟机如果创建失败，那么他所利用的镜像也将error,出现error后，得重新将镜像enable才能
    将Image 的状态改为ready,然后才能再次使用，这个错误未找到原因。

        Tue Aug 12 05:55:46 2014 [DiM][I]: New VM state is ACTIVE.
        Tue Aug 12 05:55:46 2014 [LCM][I]: New VM state is PROLOG.
        Tue Aug 12 05:55:46 2014 [VM][I]: Virtual Machine has no context
        Tue Aug 12 05:55:46 2014 [LCM][I]: New VM state is BOOT
        Tue Aug 12 05:55:46 2014 [VMM][I]: Generating deployment file: /var/lib/one/opennebula/var/vms/238/deployment.0
        Tue Aug 12 05:55:46 2014 [VMM][I]: ExitCode: 0
        Tue Aug 12 05:55:46 2014 [VMM][I]: Successfully execute network driver operation: pre.
        Tue Aug 12 05:55:47 2014 [VMM][I]: Command execution fail: cat << EOT | /var/tmp/one/vmm/xen4/deploy '/var/lib/one/opennebula/var//datastores/0/238/deployment.0' '192.168.70.70' 238 192.168.70.70
        Tue Aug 12 05:55:47 2014 [VMM][I]: Error: Unable to find number for device (xvd)
        Tue Aug 12 05:55:47 2014 [VMM][E]: Unable
        Tue Aug 12 05:55:47 2014 [VMM][I]: ExitCode: 1
        Tue Aug 12 05:55:47 2014 [VMM][I]: Failed to execute virtualization driver operation: deploy.
        Tue Aug 12 05:55:47 2014 [VMM][E]: Error deploying virtual machine: Unable
        Tue Aug 12 05:55:47 2014 [DiM][I]: New VM state is FAILED




##在sunstore中必须保证OS是第一块盘
- 发送xml数据中os盘必须是位于最后一块盘，这样才能对应界面是第一块系统盘
- 目前模板支持创建多块盘，但必须盘是可用
- 由于调度指定了某台物理，调度程序会帅选物理机上可用的存储，如果当前物理机是位于某个集群
中，那么将出现，如下错误。

##虚拟机一直处于Pengding状态的调度日志
    Tue Aug 12 05:37:46 2014 [SCHED][D]: VM 234: Host 0 filtered out. It does not fulfill SCHED_REQUIREMENTS.
    Tue Aug 12 05:37:46 2014 [SCHED][D]: VM 234: Host 47 filtered out. It does not fulfill SCHED_REQUIREMENTS.
    Tue Aug 12 05:37:46 2014 [SCHED][I]: Scheduling Results:
    Virtual Machine: 234

	PRI	ID - HOSTS
	------------------------
	-1	30  
	表示找个一个主机，主机的id是30

	PRI	ID - DATASTORES
	------------------------
	1	127
	1	0
	0	120
	表示找到三个存储，分布式127,0,120
    Tue Aug 12 05:37:46 2014 [SCHED][I]: VM 234: No suitable System DS found for      Host: 30. Filtering out host.

##虚拟机调度
###选择主机调度

 - ID="30"
 - 
###选择集群调度


#计划内容
##虚拟机对容量、网络、存储进行调整

####CPU
  - 增加CPU
  - 减少CPU
####内存
  - 增加内存
  - 减少内存
###网络
  - 增加网卡
  - 减少网卡
###存储
  - 增加镜像
  - 卸载镜像


#VNC实现
##VNC 一般性认识
- 一般VNC 使用的端口是VNC_BASE_PORT = 5900
- http://192.168.70.77:9869/vnc?host=192.168.70.70&port=29876&token=e67elmsca0d83hr3ziqf&password=null&encrypt=no&title=ok

##了解Sunstore VNC
- sunstore VNC 代理开启方法

  /var/lib/one/opennebula/bin/novnc-server  start

- sunstore VNC 代理停止方法
   
   /var/lib/one/opennebula/bin/novnc-server  stop


 ./websockify --web=../ --target-config=/var/lib/one/opennebula/var/sunstone_vnc_tokens 29876

#目前只支持一个用户登录访问

     VNC 成功连接日志
     http://192.168.70.77:29876/vnc_auto.html
    
     72: 192.168.21.52: Plain non-SSL (ws://) WebSocket connection
     72: 192.168.21.52: Version hybi-13, base64: 'False'
     72: 192.168.21.52: Path: '/websockify/?token=958wdtcvjngb2bk8d5b6'
     72: connecting to: 192.168.70.70:6139
    ^Z
    [1]+  Stopped                 ./websocketproxy.py --web=../ --target-config=/var/lib/one/opennebula/var/sunstone_vnc_tokens 29876
    oneadmin@dntcloud-mgr01:~/opennebula/share/websockify> 
    http://localhost:8080/dmonitor-webapp/vnc/vnc_auto.html

##虚拟机的token 并不需要特别算法，只是一个标志
    例如我将one-239文件中的token

    oneadmin@dntcloud-mgr01:~/opennebula/var/sunstone_vnc_tokens> cat one-239 
    123456: 192.168.70.70:6139
    oneadmin@dntcloud-mgr01:~/opennebula/var/sunstone_vnc_tokens> 
    
    但格式必须是token:host:port 
    这个格式是代理程序的参数要求。
    该文件代表一个具体的虚拟机
    
###websockify代理程序参数
    oneadmin@dntcloud-mgr01:~/noVNC/utils> ./websockify --help
    Usage: 
        websockify [options] [source_addr:]source_port [target_addr:target_port]
        websockify [options] [source_addr:]source_port -- WRAP_COMMAND_LINE
    
    Options:
      -h, --help            show this help message and exit
      -v, --verbose         verbose messages
      --traffic             per frame traffic
      --record=FILE         record sessions to FILE.[session_number]
      -D, --daemon          become a daemon (background process)
      --run-once            handle a single WebSocket connection and exit
      --timeout=TIMEOUT     after TIMEOUT seconds exit when not connected
      --idle-timeout=IDLE_TIMEOUT
                            server exits after TIMEOUT seconds if there are no
                            active connections
      --cert=CERT           SSL certificate file
      --key=KEY             SSL key file (if separate from cert)
      --ssl-only            disallow non-encrypted client connections
      --ssl-target          connect to SSL target as SSL client
      --unix-target=FILE    connect to unix socket target
      --web=DIR             run webserver on same port. Serve files from DIR.
      --wrap-mode=MODE      action to take when the wrapped program exits or
                            daemonizes: exit (default), ignore, respawn
      -6, --prefer-ipv6     prefer IPv6 when resolving source_addr
      --target-config=FILE  Configuration file containing valid targets in the
                            form 'token: host:port' or, alternatively, a directory
                            containing configuration files of this form
      --libserver           use Python library SocketServer engine


##VNC本地集成实现
    http://192.168.70.77:9869/vm/243/startvnc
    
    sunstore 配置的VNC代理程序端口
    :vnc_proxy_port: 29876  
    
    sunstore 手动开启开启代理
    python /var/lib/one/opennebula/share/websockify/websocketproxy.py --target-config=/var/lib/one/opennebula/var/sunstone_vnc_tokens 29876
    
    python websockify 8000 localhost:5900
    
##VNC端口 
    6142

##开启案例
###代理本地VNC
    python /var/lib/one/opennebula/share/websockify/websockify 8000 localhost:5900
###代理其他服务VNC
    python /var/lib/one/opennebula/share/websockify/websockify 8000 websockify.py 8000 192.168.70.71:6143


###noVNC 
    ./utils/launch.sh --vnc 192.168.70.71:6143
    
    http://192.168.70.77:6080/vnc.html?host=192.168.70.77&port=6080


###查看操作系统使用的VNC服务
    oneadmin@dntcloud-mgr01:~/opennebula/share/websockify> rpm -qa|grep vnc
    tightvnc-1.3.9-81.13.1
    xorg-x11-Xvnc-7.4-27.60.5
    oneadmin@dntcloud-mgr01:~/opennebula/share/websockify> 
    



###生成VNC token文件程序分析

    当第一次打开VNC的时候 会生产tokenfile
    def proxy(vm_resource)
        # Check configurations and VM attributes
        if !is_running?
            return error(400, "VNC Proxy is not running")
        end

        if !VNC_STATES.include?(vm_resource['LCM_STATE'])
            return error(400,"Wrong state (#{vm_resource['LCM_STATE']}) to open a VNC session")
        end

        if vm_resource['TEMPLATE/GRAPHICS/TYPE'].nil? ||
           vm_resource['TEMPLATE/GRAPHICS/TYPE'].downcase != "vnc"
            return error(400,"VM has no VNC configured")
        end

        # Proxy data
        host     = vm_resource['/VM/HISTORY_RECORDS/HISTORY[last()]/HOSTNAME']
        vnc_port = vm_resource['TEMPLATE/GRAPHICS/PORT']
        vnc_pw = vm_resource['TEMPLATE/GRAPHICS/PASSWD']

        # Generate token random_str: host:port
        random_str = rand(36**20).to_s(36) #random string a-z0-9 length 20
        token = "#{random_str}: #{host}:#{vnc_port}"
        token_file = 'one-'+vm_resource['ID']

        # Create token file
        begin
            f = File.open(File.join(@token_folder, token_file), 'w')
            f.write(token)
            f.close
        rescue Exception => e
            @logger.error e.message
            return error(500, "Cannot create VNC proxy token")
        end

        info   = {
            :password => vnc_pw,
            :token => random_str,
            :vm_name => vm_resource['NAME']
        }

        return [200, info.to_json]
    end


###打开VNC  
###生成vnc_file
    oneadmin@dntcloud-mgr01:~/opennebula/var/sunstone_vnc_tokens> more one-242 
    otjmw08g8xv27ru1eies: 192.168.70.70:6142
    oneadmin@dntcloud-mgr01:~/opennebula/var/sunstone_vnc_tokens> 




#noVNC的工作原理

    noVNC提供一种在网页上通过html5的Canvas，访问机器上vncserver提供的vnc服务，需要做tcp到websocket的转化，才能在html5中显示出来。网页就是一个客户端，类似win下面的vncviewer，只是此时填的不是裸露的vnc服务的ip+port，而是由noVNC提供的websockets的代理，在noVNC代理服务器上要配置每个vnc服务，noVNC提供一个标识，去反向代理所配置的vnc服务。

 

    我们的计算节点有 192.168.1.101 192.168.1.102 。。。
    
    noVNC代理 放在 192.168.1.11  websockify代理通过内网带宽把qemu-kvm的vnc tcp转化成websockets 在6080上提供反向代理服务
    
    在192.168.1.11写好所有虚拟机的配置文件，任意放在一个目录下比如：/srv/nfs4/vnc_tokens，这个目录下一台虚拟机提供一个配置文件，配置文件的内容
    
    02f63e037a3c485c8fd5c0164c6ef67b: 192.168.1.101:5908
    然后启动代理服务
    
    nohup python /root/noVNC/utils/websockify --web /root/noVNC --target-config=/srv/nfs4/vnc_tokens 6080 >> /root/noVNC/novnc.log &
    这样在内网中，我们通过noVNC提供的vnc_auto.html写上
    
    host=192.168.1.11
    
    port=6080
    
    path=02f63e037a3c485c8fd5c0164c6ef67b
    然后通过192.168.1.11:6080/vnc_auto.html就可以访问192.168.1.101:5908的这台机器的界面了。
    
     
    
    以上是一般的demo，下面讲如何在以上的基础上集成到已有的项目：
    
    1.我在路由器上把公网的6080端口映射到192.168.1.11的6080端口上来。
    
    2.把noVNC下面的vnc_auto.html以及一些对应的css,js和images拷到已有的项目中
    
    3.在已有的项目中加一个action，每次点击远程桌面的时候，页面会传一个vm的标识到action中，action判断这个vm是否属于登录的这个用户，然后在数据库中取出这台vm的vnc服务的ip+port，写成一个配置文件target-config指定目录下，最后把websockets代理机器的ip+port以及vm vnc的password通过action传到vnc_auto.html中
    
    4.此时就可以通过web访问vnc界面了， enjoy~
    
    http://192.168.70.77:9869/vm/239/startvnc


##虚拟机

###虚拟机内存
    虚拟机模板标签的内存只是创建VM时分配的内存，而标签外的内存是只当前vm运行时的内存状态
    具体数值来源和获取方法，暂未知晓

###虚拟机附加一块磁盘
    {
        "action": {
            "perform": "attachdisk",
            "params": {
                "disk_template": {
                    "DISK": {
                        "IMAGE": "blk-5g",
                        "IMAGE_UNAME": "oneadmin",
                        "DRIVER": "file",
                        "DEV_PREFIX": "xvd",
                        "SIZE": "10240",
                        "TYPE": "fs"
                    }
                }
            }
        },
        "csrftoken": "ce21aea2dee93e80664a1a8eb290ddb3"
    }: 

其磁盘模板格式是：
    "disk_template": {
          "DISK": {
              "IMAGE": "blk-5g",
              "IMAGE_UNAME": "oneadmin",
              "DRIVER": "file",
              "DEV_PREFIX": "xvd",
              "SIZE": "10240",
              "TYPE": "fs"
          }
    }


###虚拟机卸载一快磁盘
    {
        "action": {
            "perform": "detachdisk", 
            "params": {
                "disk_id": "2"
            }
        }, 
        "csrftoken": "ce21aea2dee93e80664a1a8eb290ddb3"
    }

###虚拟机添加一张网卡
    {
        "action": {
            "perform": "attachnic", 
            "params": {
                "nic_template": {
                    "NIC": {
                        "NETWORK": "public", 
                        "NETWORK_UNAME": "oneadmin"
                    }
                }
            }
        }, 
        "csrftoken": "510186022eb56ba1e1389dac7d5d24d8"
    }

###虚拟机卸载一张网卡
    {
        "action": {
            "perform": "detachnic", 
            "params": {
                "nic_id": "1"
            }
        }, 
        "csrftoken": "510186022eb56ba1e1389dac7d5d24d8"
    }







