#!/bin/bash
# Opennebula network contextualization initscript for debian
# Copy in /etc/init.d and install:
# update-rc.d vmcontext.sh start 01 S

### BEGIN INIT INFO
# Provides:       vmcontext
# Required-Start: mountkernfs $local_fs
# Required-Stop:
# Default-Stop:
# Default-Start:  S
# X-Start-Before: ifupdown networking
# Short-Description: Start the Opennebula context.
### END INIT INFO

# -------------------------------------------------------------------------- #
# Copyright 2002-2014, OpenNebula Project (OpenNebula.org), C12G Labs        #
#                                                                            #
# Licensed under the Apache License, Version 2.0 (the "License"); you may    #
# not use this file except in compliance with the License. You may obtain    #
# a copy of the License at                                                   #
#                                                                            #
# http://www.apache.org/licenses/LICENSE-2.0                                 #
#                                                                            #
# Unless required by applicable law or agreed to in writing, software        #
# distributed under the License is distributed on an "AS IS" BASIS,          #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
# See the License for the specific language governing permissions and        #
# limitations under the License.                                             #
#--------------------------------------------------------------------------- #

. /lib/lsb/init-functions

# Gets IP address from a given MAC
mac2ip() {
    mac=$1

    let ip_a=0x`echo $mac | cut -d: -f 3`
    let ip_b=0x`echo $mac | cut -d: -f 4`
    let ip_c=0x`echo $mac | cut -d: -f 5`
    let ip_d=0x`echo $mac | cut -d: -f 6`

    ip="$ip_a.$ip_b.$ip_c.$ip_d"

    echo $ip
}

# Gets the network part of an IP
get_network() {
    IP=$1

    echo $IP | cut -d'.' -f1,2,3
}

get_interfaces() {
    IFCMD="/sbin/ifconfig -a"

    $IFCMD | grep ^eth | sed 's/ *Link encap:Ethernet.*HWaddr /-/g'
}

get_dev() {
    echo $1 | cut -d'-' -f 1
}

get_mac() {
    echo $1 | cut -d'-' -f 2
}

gen_hosts() {
    NETWORK=$1
    echo "127.0.0.1 localhost"
    for n in `seq -w 01 99`; do
        n2=`echo $n | sed 's/^0*//'`
        echo ${NETWORK}.$n2 cluster${n}
    done
}

gen_exports() {
    NETWORK=$1
    echo "/images ${NETWORK}.0/255.255.255.0(rw,async,no_subtree_check)"
}

gen_hostname() {
    MAC=$1
    NUM=`mac2ip $MAC | cut -d'.' -f4`
    NUM2=`echo 000000$NUM | sed 's/.*\(..\)/\1/'`
    echo cluster$NUM2
}

#生成网卡接口配置文件
gen_interface() {
 DEV_MAC=$1
 DEV=`get_dev $DEV_MAC`
 MAC=`get_mac $DEV_MAC`
 IP=`mac2ip $MAC`
 NETWORK=`get_network $IP` 
 
cat <<EOT
BOOTPROTO='static'
BROADCAST=''
ETHTOOL_OPTIONS=''
IFPLUGD_PRIORITY='20'
IPADDR='$IP/24'
MTU=''
NAME='79c970 [PCnet32 LANCE]'
NETMASK=''
NETWORK=''
REMOTE_IPADDR=''
STARTMODE='auto'
USERCONTROL='no'
EOT

echo ""
}

#配置网络IP地址，支持多网卡
configure_network()
{
    IFACES=`get_interfaces`

	for i in $IFACES; do
	    MASTER_DEV_MAC=$i
	    DEV=`get_dev $i`
	    MAC=`get_mac $i`
	    IP=`mac2ip $MAC`
	    NETWORK=`get_network $IP`

		gen_interface $i > /etc/sysconfig/network/ifcfg-${DEV}
		if [ $DEV == "eth0" ]; then
			echo "default $NETWORK.254" > /etc/sysconfig/network/routes
		fi
	done

    service network restart

    sleep 2
}

#到出另一个脚本中的变量
function export_rc_vars
{
    if [ -f $1 ] ; then
        ONE_VARS=`cat $1 | egrep -e '^[a-zA-Z\-\_0-9]*=' | sed 's/=.*$//'`
	echo $ONE_VARS
        . $1

        for v in $ONE_VARS; do
            export $v
        done
    fi
}

#判断是否挂载context iso文件，如果挂载则利用该文件的中内容
get_context_from_iso(){
	if [ -e "/dev/disk/by-label/CONTEXT" ]; then
		#如果存在则将iso挂载到mnt目录
        mount -t iso9660 -L CONTEXT  -o ro /mnt
        if [ -f /mnt/context.sh ]; then
            export_rc_vars /mnt/context.sh
        fi

        config_username

        umount /mnt
    else
		echo " no do thing "
    fi
}

#配置用户和密码名称
config_username(){
	#添加用户
	
	PEOPLE=`cat /etc/passwd|grep $DCLOUD_USER`
	# -z 字符串的长度为零则为真
	if [ -z $PEOPLE ];then
		useradd $DCLOUD_USER
		#设置用户密码
		echo $DCLOUD_PASSWORD
		echo $DCLOUD_PASSWORD | passwd --stdin $DCLOUD_USER
	fi
	
	
}


#启动判断
case "$1" in
  start)
	echo "start config dcloud vm"
	
	configure_network
	get_context_from_iso

	;;
  restart|reload|force-reload)
		echo "Error: argument '$1' not supported" >&2
        exit 3
        ;;
  stop)
        ;;
  *)
        echo "Usage: $0 start|stop" >&2
        exit 3
        ;;
esac
