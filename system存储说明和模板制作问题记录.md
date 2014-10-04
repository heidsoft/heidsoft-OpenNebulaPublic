1、通过ISO制作模板时,安装机器后，使用非持久化磁盘安装后，无法从硬盘引导；使用持久化磁盘可以。
2、system 存储，当opennebula 初次部署时，会生成0（system）,1(image),2(datablock)
system 用于存储虚拟机的配置文件，如下：
oneadmin@dntcloud-mgr01:~/opennebula/var/datastores/160/398> ls
deployment.0  disk.0  disk.1
oneadmin@dntcloud-mgr01:~/opennebula/var/datastores/160/398> 

证明使用非持久化时，其OS盘是使用的软链接方式
oneadmin@dntcloud-mgr01:~/opennebula/var/datastores/160/398> ls -l
total 8
-rw-r--r-- 1 oneadmin oneadmin        393 Sep 23 04:33 deployment.0
lrwxrwxrwx 1 oneadmin oneadmin         75 Sep 23 04:33 disk.0 -> /var/lib/one/opennebula/var/datastores/100/d607efc04831e561fca72c41468e727d
-rw-r--r-- 1 oneadmin oneadmin 2147483649 Sep 23 04:33 disk.1
oneadmin@dntcloud-mgr01:~/opennebula/var/datastores/160/398> 

证明使用持久化磁盘时，其磁盘将重新拷贝一份
oneadmin@dntcloud-mgr01:~/opennebula/var/datastores/0/396> ls -lh
total 4.4G
-rw-r--r-- 1 oneadmin oneadmin  384 Sep 23 04:31 deployment.0
-rw-r--r-- 1 oneadmin oneadmin 7.9G Sep 23  2014 disk.0
-rw-r--r-- 1 oneadmin oneadmin 3.1M Sep 23 04:31 disk.1
oneadmin@dntcloud-mgr01:~/opennebula/var/datastores/0/396> 
它对应的配置文件格式
oneadmin@dntcloud-mgr01:~/opennebula/var/datastores/0/396> cat deployment.0 
name = 'one-396'
#O CPU_CREDITS = 256
memory  = '1024'
builder = 'hvm'
boot = 'c'
disk = [
    'file:/var/lib/one/opennebula/var/datastores/0/396/disk.0,xvda,w',
    'file:/var/lib/one/opennebula/var/datastores/0/396/disk.1,xvdb,w',
]
vif = [
    'model=virtio,mac=02:00:c0:a8:46:98,ip=192.168.70.152,bridge=br0',
]
vnc = '1'
vnclisten = '0.0.0.0'
vncunused = '0'
vncdisplay = '396'

3、当创建vm时，如果模板中没有选择vm具体到哪个集群（也表示没有选择具体创建到哪个system），那么默认将创建到id=0的system
4、如果想指定vm创建到自己的system中，那么需要在集群中绑定指定的system，然后通过模板调度策略配置，指定为该集群。
5、在挂载存储时，应该将发布的存储目录，挂载到datastore，而不是其中的子目录，否则容易出现故障。
6、如果通过ui创建system存储时，创建后不会再datastore目录中生成相应文件夹，而是在等到vm创建，如果vm是使用该system时，那么此时system中将创建vm的相关目录和文件。

xen3解决方案：经研究确认，该需求可通过修改各个host上xen的配置来解决。具体修改方式为：
编辑配置文件  /etc/xen/xend-config.sxp， 设置以下几项参数
(xend-relocation-server yes)
(xend-relocation-port 8002)
(xend-relocation-address '')
(xend-relocation-hosts-allow '')
保存并重启xen服务。
