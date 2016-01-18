#!/bin/bash
#2016年 01月 18日 星期一 10:02:24 CST
#0 */2 * * * /data/local-ap/shadowsock_ip.sh >> /data/local-ap/sslocal.record 2>&1

TMP_FILE=tmp.txt
TXT=google_ip.txt
SHADOWSOCK_CONFIG=shadowsocks-config
SERVER_PASSWD=server_passwd.txt
LOCAL_PASSWD=local_passwd.txt

SSLOCAL_BIN=/usr/bin/sslocal
#获取代理服务器帐号密码端口
curl -s http://www.ishadowsocks.com | grep -Ea "(A密码|端口|A服务器地址|加密方式)" | sed -n '1,4p'> $TMP_FILE

awk -F: '{gsub(/<>/,"");print $0}' $TMP_FILE |awk -F">" '{print $2}' | awk -F"<" '{print $1}' >$TXT

#服务端shadowsocks-config 中的password
sed -n '3p' $TXT | awk -F":" '{print $2}' >$SERVER_PASSWD
sed -i 's/^/"/' $SERVER_PASSWD
sed -i 's/$/"/' $SERVER_PASSWD

server_passwd=`sed -n '3p' $TXT | awk -F":" '{print $2}'`
#过滤本地shadowsocks-config 中的password
local_passwd=`grep password $SHADOWSOCK_CONFIG | awk -F":" '{print $2}' | awk -F"," '{print $1}' >$LOCAL_PASSWD`
#
LOCAL=`cat $LOCAL_PASSWD`
rm -rf $TMP_FILE

for i in `cat $SERVER_PASSWD`
do
    if [ `cat $LOCAL_PASSWD` != $i  ]
    then    
        sed -i "s/$LOCAL/$i/g" $SHADOWSOCK_CONFIG
        set -x
        kill `pgrep sslocal`
        set +x
        nohup $SSLOCAL_BIN -c $SHADOWSOCK_CONFIG &

    else
        echo "不需要修改"
        exit 1
        
    fi
done
