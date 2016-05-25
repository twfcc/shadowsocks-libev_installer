#! /bin/bash
# $author: twfcc@twitter
# $PROG: ss-libev-install.sh
# $description: install ss-libev on debian base os
# $date: May 14, 2016
# Public domain use as your own risk!
# works on ubuntu 14.04/15.04 debian 7/8
# $usage: $0 {-n|-s} 
# -n install ss-libev on nat share ipv4 vps
# -s install ss-libev on standard dedicated ip vps

cleanup(){
	rm -rf $HOME/shadowsocks-libev ;
	rm -f $HOME/shadowsocks-libev*.deb ;
	exit 1 ;
}

trap cleanup INT  

[ $UID -ne 0 ] && {
	echo "Execute this script must be root." >&2 ;
	exit 1 ;
}

[ $(pwd) != "/root" ] && cd "$HOME"

case "$1" in
	-n) flag=0 ;;
	-s) flag=1 ;;
	 *) echo "Usage: ${0##*/} {-n|-s}" >&2 ;
	    echo "-n means install ss-libev on nat vps" >&2 ;
	    echo "-s means install ss-libev on standard vps" >&2 ；
	    exit 1 ;
	    ;;
esac

myip=$(wget -qO - v4.ifconfig.co)
myos=$(lsb_release -c | awk '{print $2}')
pw=$(head -c 512 /dev/urandom | md5sum | base64 | cut -c4-19)
source_list="/etc/apt/sources.list"
ss_config="/etc/shadowsocks-libev/config.json"

if [ $flag -eq 0 ] ; then
	internal_ip=$(ifconfig venet0:0 \
	| awk -F: '$2 ~ /[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/{print $2}' \
	| cut -d" " -f1)
	port=${internal_ip##*.}01
else
	pick=($(for i in {18801..18899} ;do echo $i ;done))
	count=${#pick[@]}
	port=${pick[$((RANDOM%count-1))]}
fi

case "$myos" in
	wheezy) echo "deb http://ftp.debian.org/debian wheezy-backports main" \
		>> "$source_list"
		;;
	jessie) echo "deb http://ftp.debian.org/debian jessie-backports main" \
		>> "$source_list"
		;;
	trusty) : 
		;;
	 vivid) :
		;;
	     *) echo "This script works on debian base os only." >&2 ;
		exit 1 ;
		;;
esac

apt-get update && apt-get upgrade -y
apt-get install git build-essential autoconf libtool libssl-dev \
		gawk debhelper dh-systemd init-system-helpers pkg-config -y 

if git clone https://github.com/shadowsocks/shadowsocks-libev.git
	then
		cd shadowsocks-libev 
		dpkg-buildpackage -b -us -uc -i 
		cd .. 
		dpkg -i shadowsocks-libev*.deb 
	else
		echo "Clone shadowsocks-libev.git failed." >&2 
		exit 1
fi

echo "{" > "$ss_config"
if [ $flag -eq 0 ] ; then
	echo -e "\t\"server\":\"${internal_ip}\"," >> "$ss_config"
else
	echo -e "\t\"server\":\"0.0.0.0\"," >> "$ss_config"
fi
echo -e "\t\"server_port\":${port},"  >> "$ss_config"
echo -e "\t\"local_port\":1080," >> "$ss_config"
echo -e "\t\"password\":\"${pw}\"," >> "$ss_config"
echo -e "\t\"timeout\":300," >> "$ss_config"
echo -e "\t\"method\":\"chacha20\"" >> "$ss_config"
echo "}" >> "$ss_config"

/etc/init.d/shadowsocks-libev restart

if [ $flag -eq 0 ] ; then
	netstat -nlp | grep -q "${internal_ip}:${port}"
	ret=$?
else
	netstat -nlp | grep -q "0.0.0.0:${port}"
	ret=$?
fi

if [ $ret -eq 0 ] ; then
	echo "Here is shadowsocks clinet info as below."
	echo ""
	echo "Public IP:  $myip"
	echo "Port:  $port"
	echo "Method:  chacha20"
	echo "Password:  $pw"
	echo ""
	echo "Enjoy."
else
	echo "Install shadowsocks-libev failed." >&2
	exit 1
fi
exit 0

