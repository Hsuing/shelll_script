#!/bin/bash
#date 2015-02-08
#name: Xiong.Han
#clean mysql process sleep more than 3600
#170 on server
echo "`date` killing mysql sleep process..." >> /data/scripts_shell/crontab.log
for id in `mysql -e "show processlist"|grep -i sleep |awk '{if($6>3600){print $1}}'`
do
	echo "killing pid $id ">>/data/scripts_shell/crontab.log
	echo `mysql -e "kill $id"`
done
