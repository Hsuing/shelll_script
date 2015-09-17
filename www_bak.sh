#!/bin/bash - 
#===============================================================================
#
#          FILE: www_bak.sh
# 
#         USAGE: ./www_bak.sh 
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
#       CREATED: 2015年06月12日 09:29
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
bakdir=/data/web_bak
month=`date +%m`
day=`date +%d`
year=`date +%Y`
dirname=$year-$month-$day

#FILENAME=$(ls -tl /var/www/html | awk '{print $9}' | sed '1d' > $bakdir/tmp.txt)
#create 
if [ ! -d $bakdir ]
then
    mkdir -p $bakdir/$dirname/conf
    mkdir -p $bakdir/$dirname/web
else
    mkdir -p $bakdir/$dirname/conf
    mkdir -p $bakdir/$dirname/web
fi
#configure
conf=/etc/httpd/vhost
cp -af $conf $bakdir/$dirname/conf

while read LINE
do
    #ignore the directory 
    #use parameter  --exclude
    tar jcvf  $bakdir/$LINE.tar.bz2 /var/www/$LINE  --exclude v_log
done < /data/bak_scripts/tmp.txt

#rm -rf $bakdir/tmp.txt 
#array
all_backup_file=(
    $(ls -t ${bakdir}/*.tar.bz2)
)
for i in ${all_backup_file[*]}
do
    if [ ! -d ${bakdir} ]
    then
        mkdir -p $bakdir/$dirname/web
    else
        mkdir -p $bakdir/$dirname/web
    fi
    #move backup
    mv ${i} $bakdir/$dirname/web
done
DIR_NAME=/data/web_bak
find $DIR_NAME -maxdepth 1 -mtime +2  |xargs rm -rf

