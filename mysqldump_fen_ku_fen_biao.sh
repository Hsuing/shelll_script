#!/bin/bash -
#===============================================================================
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Xiong.Han
#        E-MAIL: hxopensource.163.com
#  ORGANIZATION:
#   Create Time: 2016年08月22日 星期一 11时04分26秒
# Last Modified: 2016-08-22 11:04
#      REVISION:  ---
#===============================================================================
set -o nounset

BACK_PATH=/data/back_data/back_sql

#mysql env
USER=root
PASSWORD=123456
SOCKET=/data/mysql/3306/mysql.sock

MYSQL_CMD_PATH=/data/application/mysql/mysql-5.6.30/bin/mysql
MYSQL_CMD_MYSQLDUMP_PATH=/data/application/mysql/mysql-5.6.30/bin/mysqldump

MYSQL_CMD="${MYSQL_CMD_PATH} -u$USER -p$PASSWORD -S $SOCKET"
MYSQL_DUMP="${MYSQL_CMD_MYSQLDUMP_PATH} -u$USER -p$PASSWORD -S $SOCKET -x -F -R"
DB_LIST=`${MYSQL_CMD} -e "show databases;" |sed 1d | egrep -v "_schema|mysql|test"`
DATE_TIME=`date +%F`

[ ! -d ${BACK_PATH} ] && mkdir -p ${BACK_PATH}
#
fen_ku(){
        for db_name in $DB_LIST
        do
                ${MYSQL_DUMP} ${db_name} > ${BACK_PATH}/${db_name}_$(date +%F).sql
        done
}
#分库分表备份

fen_ku_fen_biao(){
        for db_name in $DB_LIST
        do
                tb_list=`${MYSQL_CMD} -e "show tables from ${db_name};"|sed 1d`
                for tb_name in ${tb_list}
                do
                        mkdir -p ${BACK_PATH}/${db_name}/${DATE_TIME}
                        ${MYSQL_DUMP} ${db_name} ${tb_name}| gzip > ${BACK_PATH}/${db_name}/${DATE_TIME}/${db_name}_${tb_name}_$(date +%F).sql.gz
                done
        done
}
#表的结构
tabal_str(){
        for db_name in $DB_LIST
        do
                ${MYSQL_DUMP} ${db_name} -d -q --default-character-set=utf8 -u$USER -p$PASSWORD > ${BACK_PATH}/${db_name}/${DATE_TIME}/${db_name}_$(date +%F).stru_sql
        done
}
#main
main(){
        fen_ku_fen_biao
        tabal_str
}
main
