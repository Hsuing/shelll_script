#!/bin/bash
#===============================================================================
#
#          FILE: array_mysql_sql_bak.sh
# 
#         USAGE: ./array_mysql_sql_bak.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Xiong.Han 
#            E-MAIL: hxopensource.163.com 
#  ORGANIZATION: 
#       CREATED: 2015年04月29日 13:52
#      REVISION:  ---
#===============================================================================
DB_HOSTNAME="localhost"
DB_USERNAME="root"
DB_PASSWORD="e39bd7adcmysql"

MAXIMUM_BACKUP_FILES=10              #最大备份文件数
BACKUP_FOLDERNAME="/data/local_db_bak"  #数据库备份文件的主目录
DATABASES=(
           yb_39
)
echo "Bash Database Backup Tool"

CURRENT_DATE=$(date +%H)              #定义当前日期为变量
BACKUP_FOLDER="${BACKUP_FOLDERNAME}_${CURRENT_DATE}" #存放数据库备份文件的目录
if [ ! -d ${BACKUP_FOLDERNAME} ]
then
        mkdir -p $BACKUP_FOLDER #创建数据库备份文件目录
fi
#统计需要被备份的数据库
count=0
while [ "x${DATABASES[count]}" != "x" ];do
    count=$(( count + 1 ))
done
echo "[+] ${count} databases will be backuped..."
#循环这个数据库名称列表然后逐个备份这些数据库
for DATABASE in ${DATABASES[@]};do
    echo "[+] Mysql-Dumping: ${DATABASE}"
    echo -n "   Began:  ";echo $(date)
    if $(mysqldump --default-character-set=utf8 -d -h ${DB_HOSTNAME} -u${DB_USERNAME} -p${DB_PASSWORD} ${DATABASE} > "${BACKUP_FOLDER}/${DATABASE}.stru.sql") && $(mysqldump --default-character-set=utf8 -t -h ${DB_HOSTNAME} -u${DB_USERNAME} -p${DB_PASSWORD} ${DATABASE} > "${BACKUP_FOLDER}/${DATABASE}.data.sql")
	then
        	echo "  Dumped successfully!"
    	else
        	echo "  Failed dumping this database!"
    	fi
        	echo -n "   Finished: ";echo $(date)
done
echo
echo "[+] Packaging and compressing the backup folder..."
tar -cv ${BACKUP_FOLDER} | bzip2 > ${BACKUP_FOLDER}.tar.bz2 && rm -rf $BACKUP_FOLDER
#
ALL_BACKUP_FILES=($(ls -t ${BACKUP_FOLDERNAME}*.tar.bz2)) 
BACK_SQL="/data/local_sql"
DATE=$(date +%m-%d)
for i in ${ALL_BACKUP_FILES}
do
	if [ ! -d ${BACKUP_FOLDERNAME} ]
	then
        	mkdir -p $BACK_SQL/$DATE #创建数据库备份文件目录
	fi
	mv ${ALL_BACKUP_FILES} ${BACK_SQL}/${DATE}			
done
