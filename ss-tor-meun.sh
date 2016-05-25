#! /bin/bash
# $Author: twfcc@twitter
# $PROG ss-tor-menu.sh
# $description: start or stop redirecting traffic to TOR on remote vps
# Public domain use as your own risk!
# /root/toriptables2/toriptables2.py must be exist.  

if ! which zenity > /dev/null 2>&1 
	then
		echo "Zenity is needed for this script" >&2 ;
		echo "Input: 'sudo apt-get install zenity' first." >&2
		exit 1
fi
host="My_VPS" # change to your vps IP or hostname
rport=22   # change to vps sshd's port if not 22
ans=$(zenity  --list  --text "TOR Traffic Menu" \
      --radiolist  --column "Pick" \
      --column "Action" \
      TRUE "Shadowsocks via TOR" FALSE "Use Shadowsocks Only")

case "$ans" in
	Shadowsocks*) ssh root@"$host" -p $rport '/root/toriptables2/toriptables2.py -l' ;
	              if [ $? -eq 0 ] ; then
				zenity --info --text \
				"Redirect traffic to TOR success."
	              fi
	              ;;
	           *) ssh root@"$host" -p $rport '/root/toriptables2/toriptables2.py -f' ;
	              if [ $? -eq 0 ] ; then
				zenity --error --text \
				"Stop redirect traffic to TOR success."
	              fi
	              ;;
esac
exit 0
