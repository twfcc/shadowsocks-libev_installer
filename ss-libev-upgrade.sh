#! /bin/bash
# $author: twfcc@twitter
# $PROG: ss-libev-upgrade.sh
# $description: check newer version of ss-libev from github
# $usage: $0
# works on debian base os
# target os: debian 7/8, ubuntu 14.04/15.04
# this script is part of ss-libev-install.sh for upgrade
# Public domain use as your own risk!

[ $(pwd) != "/root" ] && cd "$HOME"
[ $UID -ne 0 ] && {
        echo "Execute this script must be root." >&2 ;
        exit 1 ;
}

if ! which curl > /dev/null 2>&1 ; then
        apt-get update && apt-get install curl -y
fi
ss_install_script="https://www.dropbox.com/s/mtare61xbd7brim/ss-libev-install.sh?dl=0"
if ! which ss-server > /dev/null 2>&1 ; then
        echo "shadowsocks-libev is not installed on system yet." >&2
        echo "The install script download by input" >&2
        echo "wget --no-check-certificate -O ss-libev-install.sh $ss_install_script" >&2
        echo "chmod +x ./ss-libev-install.sh" >&2
        echo "./ss-libev-install.sh -s" >&2
        echo "or" >&2
        echo "./ss-libev-install.sh -n" >&2
        echo "-s install ss-libev on standard dedicated IP vps" >&2
        echo "-n install ss-libev on nat share ipv4 vps." >&2
        exit 1
fi

github_url="https://github.com/shadowsocks/shadowsocks-libev/blob/master/configure"
my_ss_ver=$(ss-server -h | sed -n '2p' | cut -d" " -f2)
git_ver=$(curl -s "$github_url" | sed -n \
        '/PACKAGE_VERSION=/{
        N
        H
        s/<[^>][^>]*>//g
        P
        }' | grep -oE '[0-9]{1,2}\.[0-9]{1,2}\.?[0-9]{0,2}')

if [ "$my_ss_ver" != "$git_ver" ] ; then
        flag="upgrade"
else
        flag="up-to-date"
fi

case "$flag" in
        upgrade) my_ss_deb=$(ls | grep 'shadowsocks-libev..*\.deb')
                 if [ -n "$my_ss_deb" ] ; then
                        mkdir ss-build_"$my_ss_ver"
                        mv -f shadowsocks-libev*.deb ss-build_"$my_ss_ver" 2> /dev/null
                        mv -f *shadowsocks-libev*.deb ss-build_"$my_ss_ver" 2> /dev/null
                        mv -f shadowsocks-libev*.tar.gz ss-build_"$my_ss_ver" 2> /dev/null
                 else
                        :
                 fi
                 [ -d shadowsocks-libev ] && rm -rf shadowsocks-libev
                 if git clone https://github.com/shadowsocks/shadowsocks-libev.git
                        then
                                cd shadowsocks-libev
                                dpkg-buildpackage -b -us -uc -i
                                cd ..
                                dpkg -i shadowsocks-libev*.deb
                                ret=$?
                        else
                                echo "Upgrade ss-libev failed" >&2
                                exit 1
                 fi
                 if [ $ret -eq 0 ] ; then
                        /etc/init.d/shadowsocks-libev restart
                        echo "Shadowsocks-libev upgraded."
                 else
                        echo "Upgrade shadowsocks-libev failed." >&2
                        exit 1
                 fi
                 ;;
              *) echo "Current shadowsocks-libev is the newest version."
                 ;;
esac
exit 0
