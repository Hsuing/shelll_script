#!/bin/bash - 
#===============================================================================
#
#          FILE: bc_mysql_data.sh
# 
#         USAGE: ./bc_mysql_data.sh 
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
#       CREATED: 2015年04月30日 13:44
#      REVISION:  ---
#===============================================================================
set -o nounset                              # Treat unset variables as an error
db_user="root"
db_pass="123456"
db_name="information_schema"
#数组
array=(
	cacti             
	hello             
	mysql             
	performance_schema
	ppp               
)
for i in ${array[*]}
do
	echo -e "$i\t" `mysql -u${db_user} -p${db_pass} ${db_name} -e "select concat(round(sum(DATA_LENGTH/1024/1024),2),'MB') as data from TABLES where table_schema='$i'"`
done
