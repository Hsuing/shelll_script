#!/bin/bash
#===============================================================================
#
#          FILE: arr_sql_separatb_bak.sh
# 
#         USAGE: ./arr_sql_separatb_bak.sh
# 
#   DESCRIPTION:  mysql数据库备份
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
DB_PASSWORD="123456"

MAXIMUM_BACKUP_FILES=10              #最大备份文件数
BACKUP_FOLDERNAME="/data/local_sql"  #数据库备份文件的主目录
DATABASES=(
	ssl
	hello
	go
)
echo "Bash Database Backup Tool"

CURRENT_DATE=$(date +%H)              #定义当前日期为变量
BACKUP_FOLDER="${BACKUP_FOLDERNAME}_${CURRENT_DATE}" #存放数据库备份文件的目录
if [ ! -d ${BACKUP_FOLDERNAME} ]
then
        mkdir -p $BACKUP_FOLDER #创建数据库备份文件目录
fi
#二次执行脚本产生存放数据库备份文件的目录
if [ ! -d ${BACKUP_FOLDER} ];then
        mkdir -p $BACKUP_FOLDER 
else 
	break;
fi
#创建各自数据库的目录
DATA_YOU="/data/you"
for G in ${DATABASES[@]};do
	if [ ! -d ${DATA_YOU}/$G ];then
		mkdir -p ${DATA_YOU}/${G}
	else 
		break;
	fi
done
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


#各自数据库单独分离,还有点缺限，就是每次多出的数据库名，需要手动添加
for S in ${DATABASES[@]}
do
	if [ $S == "hello" ]
	then
		mv ${BACKUP_FOLDER}/${S}.*sql ${DATA_YOU}/$S
		continue;
	elif [ $S == "ssl" ];then
		mv ${BACKUP_FOLDER}/${S}.*sql ${DATA_YOU}/$S
		continue;
	elif [ $S == "go" ];then
		mv ${BACKUP_FOLDER}/${S}.*sql ${DATA_YOU}/$S
		continue;
	else
		exit 0
	fi
done

#打包
LIST_DIR=`ls ${DATA_YOU} | awk '{print $1}'`
for Y in ${LIST_DIR}
do
	tar -cv ${DATA_YOU}/${Y} | bzip2 > ${BACKUP_FOLDER}/${Y}.tar.bz2 
done
#

#set -x
#数组
ALL_BACKUP_FILES=($(ls -t ${BACKUP_FOLDER}/*.tar.bz2)) 
#
BACK_SQL="/data/local_sql"
DATE=$(date +%Y-%m-%d)
for i in ${ALL_BACKUP_FILES[@]}
do
	if [ ! -d ${BACKUP_FOLDERNAME} ]
	then
        	mkdir -p $BACK_SQL/$DATE #创建数据库备份文件目录
	fi
	#mv ${ALL_BACKUP_FILES} ${BACK_SQL}/${DATE}			
	mv ${i} ${BACK_SQL}/${DATE}			
done
#set +x
#删除
rm -rf  ${DATA_YOU}
rm -rf ${BACKUP_FOLDER}
