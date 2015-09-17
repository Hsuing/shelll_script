#!/bin/bash - 
#===============================================================================
#
#          FILE: mysql_AB.sh
# 
#         USAGE: ./mysql_AB.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Hsuing Han 
#	 E-MAIL: hxopensource.163.com 
#  ORGANIZATION: 
#       CREATED: 04/10/2014 11:21
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
#!/bin/sh 
declare -a    slave_is 
slave_is=($(cd /data/mysql/nagios; /data/mysql/nagios/bin/mysql --sock=logs/mysql.sock  -unagios -p123456  -e "show slave status \G"|grep Running |awk '{
print $2}'))
if [ "${slave_is[0]}" = "Yes" -a "${slave_is[1]}" = "Yes" ]
then
	echo "OK -slave is running"
	exit 0
else
	echo "Crltlcal -slave is error"
	exit 2
fi
