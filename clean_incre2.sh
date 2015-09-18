#!/bin/bash
#===============================================================================
#
#          FILE: clean_incre2.sh
# 
#         USAGE: ./clean_incre2.sh 
# 
#   DESCRIPTION: this is hot backup mysql
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Xiong.Han 
#            E-MAIL: hxopensource.163.com 
#  ORGANIZATION: 
#       CREATED: 2015年07月26日 09:32
#      REVISION:  ---
#===============================================================================

#code
RemoveDir=/data/hot_bak_db/mysql_hot_3306/incre2
dt=`date +%Y-%m-%d_%H-%M-%S -d '3 day ago'`

for subdir in `ls -tl ${RemoveDir} | awk '{print $9}'`
do
    if [ "`ls -A $RemoveDir`" = "" ]
    then 
        echo "$RemoveDir is empty"
        exit 0
        #rsync --delete-before --progress --stats -avH /opt/empty $RemoveDir/$subdir
    elif [ "${subdir}" \< "${dt}" ]
    then
        rm -rf $RemoveDir/$subdir
    else
        echo "is not empty!!!"
    fi
done

