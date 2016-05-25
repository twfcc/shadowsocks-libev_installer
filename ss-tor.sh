#! /bin/bash
# Author twfcc@twitter
# $PROG: ss-tor.sh
# discriotion: intall shadowsocks + TOR for anonymity surfing
# Public domain use as your own risk!
# target on debian7/8 , ubuntu 1404/1504 , openvz vps [nat|standard]
msg1="$0 {-n|-s}"
msg2="-n install ss+tor on ovz nat ipv4 share vps"
msg3="-s install ss+tor on ovz standard vps"

[ $(pwd) != "/root" ] && cd "$HOME"

[ $UID -ne 0 ] && {
	echo "Execute this script must be root." >&2 ;
	exit 1 ;
}

case "$1" in
	-n) flag=0 ;;
	-s) flag=1 ;;
	 *) echo "$msg1" >&2 ; 
	    echo "$msg2" >&2 ;
	    echo "$msg3" >&2 ;
	    exit 1
		;;
esac

if [ $flag -eq 0 ]
	then
		 internal_ip=$(ifconfig venet0:0 \
		 | awk -F: '$2 ~ /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/{print $2}' \
		 | cut -d" " -f1)
		 port=$(echo -e ${internal_ip##*.})01
else
		 pick=($(for i in {19800..19899} ;do echo $i ;done))
		 count=${#pick[@]}
		 port=${pick[$((RANDOM%count-1))]}
fi

myip=$(wget -qO - v4.ifconfig.co)
source_list="/etc/apt/sources.list"
os_version=$(lsb_release -c | awk '{print $2}')
if [[ $os_version =~ jessie ]] || \
   [[ $os_version =~ wheezy ]] || \
   [[ $os_version =~ [Vv]ivid ]] || \
   [[ $os_version =~ trusty ]] ; then
	:
else
	echo "Sorry,work on debian base os only." >&2
	exit 1
fi

case "$os_version" in
	trusty) echo "deb http://deb.torproject.org/torproject.org trusty main" \
		>> "$source_list" ;
		echo "deb-src http://deb.torproject.org/torproject.org trusty main" \
		>> "$source_list" ;
		gpg --keyserver keys.gnupg.net --recv 886DDD89 ;
		gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add - ;
		;;
	wheezy) echo "deb http://ftp.debian.org/debian wheezy-backports main" \
		>> "$source_list"
		;;
	jessie) echo "deb http://ftp.debian.org/debian jessie-backports main" \
		>> "$source_list"
		;;
             *) : 
		;;
esac

apt-get update && apt-get upgrade -y
apt-get install python -y
apt-get install git build-essential autoconf libtool libssl-dev \
	gawk debhelper dh-systemd init-system-helpers pkg-config -y
pw=$(head -c 512 /dev/urandom | md5sum | base64 | cut -c4-19)

git clone https://github.com/shadowsocks/shadowsocks-libev.git 
rt_status=$?
if [ $rt_status -ne 0 ] 
	then
		echo "Fail to clone shadowsocks" >&2
		exit $rt_status
fi

unset rt_status

git clone https://github.com/ruped24/toriptables2.git
rt_status=$?
if [ $rt_status -ne 0 ]
	then
		echo "Fail to clone toriptables2" >&2
		exit $rt_status
fi

if [ "$os_version" = "trusty" ] 
	then
		apt-get install tor deb.torproject.org-keyring -y
	else
		apt-get install tor -y
fi

tor_config="/etc/tor/torrc"
if [ -e "$tor_config" ] 
	then
		echo "ClientOnly 0" >> "$tor_config"
		echo "StrictNodes 1" >> "$tor_config"
		echo "ExcludeNodes {hk},{cn},{mo},{ru}" >> "$tor_config"
		echo "ExitNodes {us},{jp},{sg},{kp},{gb},{nz},{au},{tw}" >> "$tor_config"
else
	echo "$tor_config not found." >&2
	exit 1
fi

[ -d shadowsocks-libev ] && {
	cd shadowsocks-libev ;
	dpkg-buildpackage -b -us -uc -i ; wait ;
	cd .. ;
	dpkg -i shadowsocks-libev*.deb ;
}

ss_config="/etc/shadowsocks-libev/config.json"
if [ $flag -eq 0 ] 
	then
		echo "{" > "$ss_config"
		echo -e "\t\"server\":\"${internal_ip}\"," >> "$ss_config"
		echo -e "\t\"server_port\":${port},"  >> "$ss_config"
		echo -e "\t\"local_port\":1080," >> "$ss_config"
		echo -e "\t\"password\":\"${pw}\"," >> "$ss_config"
		echo -e "\t\"timeout\":300," >> "$ss_config"
		echo -e "\t\"method\":\"chacha20\"" >> "$ss_config"
		echo "}" >> "$ss_config"
	else
		echo "{" > "$ss_config"
		echo -e "\t\"server\":\"0.0.0.0\"," >> "$ss_config"
		echo -e "\t\"server_port\":${port},"  >> "$ss_config"
		echo -e "\t\"local_port\":1080," >> "$ss_config"
		echo -e "\t\"password\":\"${pw}\"," >> "$ss_config"
		echo -e "\t\"timeout\":300," >> "$ss_config"
		echo -e "\t\"method\":\"chacha20\"" >> "$ss_config"
		echo "}" >> "$ss_config"
fi

/etc/init.d/shadowsocks-libev restart ; wait

if [ $flag -eq 0 ]
	then
		netstat -nlp | grep -q "${internal_ip}:${port}"
		[ $? -eq 0 ] && echo "Shadowsocks server is running." || \
		{
			echo "Fail to install shadowsocks." >&2 ;
			exit 1 ;
		}
	else
		netstat -nlp | grep -q "0.0.0.0:${port}"
		[ $? -eq 0 ] && echo "Shadowsocks server is running." || \
		{
			echo "Fail to install shadowsocks." >&2 ;
			exit 1 ;
		}
fi

[ -d toriptables2 ] && {
	cd toriptables2
	chmod +x toriptables2.py
	./toriptables2.py -l
}
echo ""
echo "Now all incoming traffic is redirected to TOR."
echo "To stop redirecting traffic to TOR," 
echo "goto toriptables2 directory by input: ./toriptables2.py -f"
echo "To start redirecting traffic by input: ./toriptables2.py -l"
echo ""
echo "Shadowsocks client infomation as below."
echo ""
echo -e "Public IP:\t${myip}"
echo -e "Port:\t\t${port}"
echo -e "Password:\t${pw}"
echo -e "Method:\t\tchacha20"
echo ""
echo "Enjoy."
exit 0

