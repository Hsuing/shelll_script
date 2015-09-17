#!/bin/bash - 
#===============================================================================
#
#          FILE: exp_grants.sh
# 
#         USAGE: ./exp_grants.sh 
# 
#   DESCRIPTION: Function export user privileges
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Xiong.Han 
#	     E-MAIL: hxopensource.163.com 
#  ORGANIZATION: 
#       CREATED: 2015年03月13日 16:29
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
password=123
expgrants()
{
  mysql -B -u'root' -p${password}-N $@ -e "SELECT DISTINCT CONCAT(
    'SHOW GRANTS FOR ''', user, '''@''', host, ''';'
    ) AS query FROM mysql.user" | \
  mysql $@ | \
  sed 's/\(GRANT .*\)/\1;/;s/^\(Grants for .*\)/-- \1 /;/--/{x;p;x;}'
}
expgrants > /tmp/grants.sql
echo -ne "\nflush privileges;\n" >> /tmp/grants.sql
