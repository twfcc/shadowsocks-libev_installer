# shadowsocks-libev_installer
Install shadowsocks-libev on Debian Base OS

說明

ss-libev-install.sh是一個bash腳本，安裝shadowsocks-libev在Debian Base OS.
ss-libev-upgrade.sh 是更新服務器bash腳本
ss-tor.sh 用來安裝shadowsocks-libev和洋葱路由(TOR)客戶端
ss-tor-menu.sh是遠程控制shadowsocks流量是否經TOR訪問互聯網客戶端

以上可在Ubuntu 14.04/15.04 或 Debian 7/8 獨立IPv4的VPS或是NAT Share IPv4 VPS
請選擇ss-libev-install.sh或ss-tor.sh其中之一安裝服務器
ss-tor-menu是本地Linux電腦控制服務器TOR開關圖型腳本

使用方法

以root登錄VPS，下載適合的腳本，執行chmod +x script_name.sh ,根據你的VPS類型，
如果是NAT Share IPv4 VPS ,執行 ./script_name.sh -n , 獨立IPv4的VPS執行 
./script_name.sh -s

ss-tor-menu.sh 請訪問https://victor-notes.blogspot.com/2016/05/shadowsockstor.html
參考使用方法

Explanation

ss-libev-install.sh is a bash script for install shadowsocks-libev on Debian Base OS
ss-libev-upgrade.sh is an 'upgrade shadowsocks-libev server bash script'
ss-tor.sh is used for install shadowsocks-libev and TOR client on VPS
These scripts are worked on Ubuntu 14.04/15.04 or Debian 7/8 'Dedicated IPv4 VPS' or 
'NAT Share IPv4 VPS'
Please select ss-libev-install.sh or ss-tor.sh to install server on VPS.

Usage

Login your VPS with user 'root' via ssh client and downloading the script, select one
script which is suitable for your VPS. Input: chmod +x script_name.sh 
Input: ./script_name.sh -n if your vps' type is 'NAT Share IPv4 VPS' or
Input: ./script_name.sh -s if your vps' type is 'Dedicated IPv4 VPS'

shadowsock-libev github at https://github.com/shadowsocks/shadowsocks-libev
TOR Project at https://www.torproject.org/
for ss-tor-menu.sh, please visit: https://victor-notes.blogspot.com/2016/05/shadowsockstor.html
for more details.

shadowsocks-libev github 
