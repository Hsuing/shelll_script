#!/bin/bash - 
#===============================================================================
#
#          FILE: batch_modify_passwd.sh
# 
#         USAGE: ./batch_modify_passwd.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Xiong.Han 
#	     E-MAIL: hxopensource.163.com 
#  ORGANIZATION: 
#       CREATED: 2015年04月27日 09:32
#      REVISION:  ---
#===============================================================================
ip_list=`cat /home/han/ip_list.txt` 
port=2112
#定义一个自动生成随机密码的函数.----------------------- 
function pwdgen { 
    strUp="ABCDEFGHIJKLMNOPQRSTUVWXYZ" 
    strLow="abcdefghijklmnopqrstuvwxyz" 
    strNum="0123456789" 
    #12位
    passLen="12" 
    while [ "${#pass}" -le "$passLen" ] 
    do 
        passUp="${strUp:$(($RANDOM%${#strUp})):1}" 
        passLow="${strLow:$(($RANDOM%${#strLow})):1}" 
        passNum="${strNum:$(($RANDOM%${#strNum})):1}" 
        pass="$pass$passUp$passLow$passNum" 
    done 
    echo ${pass:0:$passLen} 
} 
#选择改密码的方式.------------------------------------- 
read -p "密码随机生成输入a | 密码手动设置输入b: " hello 
if [ $hello = a ];then 
	TMP_PWD=`pwdgen` 
elif [ $hello = b ]; then 
	read -p "请输入您要设置的密码: " TMP_PWD 
else 
	echo " 输入错误 " 
	exit 
fi 
#密码修改执行.----------------------------------------- 
for IP in $ip_list; do 
	echo $TMP_PWD > TMP_PWD.txt 
	#passwd root --stdin < TMP_PWD.txt  &>/dev/null
    ssh -p$port root@$IP passwd root --stdin < TMP_PWD.txt 
	if [ $? = 0 ] ; then 
    		echo -e "$(date "+%Y-%m-%d %H:%M:%S")\t${IP}\t${TMP_PWD}\t" >> pwd_success$(date +%Y-%m-%d).log 
else 
    		echo -e "$(date "+%Y-%m-%d %H:%M:%S")\t${IP} Password change fails\tplease check!\t" >> fails_$(date +%Y-%m-%d).log 
	fi 
done 
	rm -f TMP_PWD.txt 
echo "所有主机的密码修改已完成,请查看pwd_success$(date +%Y-%m-%d).log"
