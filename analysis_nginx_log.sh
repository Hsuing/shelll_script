#!/bin/bash - 
#===============================================================================
#
#          FILE: nginx_log_monitor.sh
# 
#	  时间范围段[]
#         USAGE: ./monitor_nginx_log.sh  xxx.log  "17/Apr/2015:0[8-9]" 
#	  or
#	  整点
#         USAGE: ./monitor_nginx_log.sh xxx.log  "17/Apr/2015:09" 
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
#       CREATED: 2015年04月17日 14:46
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
#log=/root/xkh.log
tmp=/root/temp.txt
#logdate=`date -d "yesterday" +%Y:%m:%d`

#as root running
if [ $UID -ne 0 ]
then
	echo "Please as root running!!!!"
	exit 0;
fi
	if [ $# != 2 ]
	then
		echo  "Please input 2 parameter"
		echo "[]代表时间段"
		echo "exmaple: ./monitor_nginx_log.sh  xxx.log  '17/Apr/2015:0[8-9]'"
		echo -e "or\n"
		echo "整点"
		echo "exmaple: ./monitor_nginx_log.sh xxx.log   '17/Apr/2015:8'"
		exit 1; 
	fi
#传递参数
logfile=$1
time1=$2
#统计访问量最大的元素
	#printf   "%-5s %-10s %-4s\n" counts\(file出现次数\)	KB	file  		
	echo "-----------------------------统计访问量最大的元素-----------------------------"
	echo   "counts(file出现次数)	平均每个大小	总大小(KB)	file	refer"
	egrep $time1 $logfile | awk '{a[$9/1024"	"$6"	"$10]++}END{for (i in a)print a[i],i/a[i],i}' | sort -nr -k6
if [ ! -f $tmp ]
then
	#egrep  $time1 $logfile | awk '{a[$9/1024"	"$6"	"]++}END{for (i in a)print a[i],i }' |sort -nr -k 1 > $tmp
	egrep $time1 $logfile | awk '{a[$9/1024"	"$6"	"$10]++}END{for (i in a)print a[i],i/a[i],i}' | sort -nr -k 1 > $tmp
fi
	echo " "
	printf "%-10s %-35s %-20s %-10s\n" "次数" "平均每个出现大小(KB)" "总大小(KB)" "file" 
#输出大小超出100KB文件
	awk '{if($3>1000){printf( "%-8s %-27s %-17s %-5s",$1,$2,$3,$4);}}' $tmp | sort -nr
#删除临时文件
	rm -rf $tmp
#统计网站流量
#total_bandwidth=`cat $1 |awk '{sum+=$9} END {print sum/1024/1024/1024}'`  
#echo -e "总带宽:${total_bandwidth}G"
##查找较多time_wait连接 
echo "查找较多time_wait连接(head 20)"
netstat  -n |grep TIME_WAIT | awk '{print $5}' | sort|uniq -c |sort -nr | head -n20
