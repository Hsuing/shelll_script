#!/bin/bash
# used to static mysql space
# carl 20150305 1st
# PATH 

# define some variables
InputFile="hello.txt"   ##这里写前面导出的数据库文件
OuputFile="lala.txt"                   ##这里是各分表合并统计完成的大小

# function start
cat /dev/null > ${OuputFile}
cat ${InputFile}|while read line
do
	echo $line|awk '{print $1}'|grep "_[0-9][0-9]" > /dev/null
	if [ $? == 0 ];then
		table=`echo $line|awk '{print $1}'|sed "s/_[0-9][0-9]//"`
		data_length=`echo $line|awk '{print $2}'`
		index_length=`echo $line|awk '{print $3}'`
		cat ${OuputFile}|grep -w ^${table} > /dev/null
		if [ $? == 0 ];then
			data_length_tmp=`cat ${OuputFile}|grep -w ^${table}|awk '{print $2}'`		
			index_length_tmp=`cat ${OuputFile}|grep -w ^${table}|awk '{print $3}'`
			data_length=$(($data_length+$data_length_tmp))
			index_length=$(($index_length+$index_length_tmp))
			sed -i "s/^${table}\t.*$/${table}\t${data_length}\t${index_length}/" ${OuputFile}
		else
			echo -e "${table}\t${data_length}\t${index_length}" >> ${OuputFile}
		fi
	else
		echo $line >> ${OuputFile} 
	fi
done
 
