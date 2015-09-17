#!/bin/bash - 
#===============================================================================
#
#          FILE: master_slave.sh
# 
#         USAGE: ./master_slave.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Hsuing Han 
#	     E-MAIL: hxopensource.163.com 
#  ORGANIZATION: 
#       CREATED: 2015年06月08日 09:56
#      REVISION:  ---
#不要通过Seconds_Behind_Master去判断，该值表示slave上SQL线程和IO线程之间的延迟
#1、首先看 Relay_Master_Log_File 和 Master_Log_File 是否有差异
#2、如果Relay_Master_Log_File 和 Master_Log_File 有差异的话，那说明延迟很大
#3、如果Relay_Master_Log_File 和 Master_Log_File 没有差异，再来看Exec_Master_Log_Pos 和 Read_Master_Log_Pos 的差异，那么更加严谨的做法是同时在主库执行show master status和在从库上面执行show slave status 的输出进行比较。MHA就是这样保证数据一致性的。MMM都没有做到。这也算MHA比MMM更加优秀的地方。
##===============================================================================

set -o nounset                              # Treat unset variables as an error
#slave
s_user=root
s_password=123456
s_port=3306
s_host=localhost

#master
m_user=root
m_password=123456
m_port=3306
m_host=localhost

slave_ip=`ifconfig |sed -n '/inet /{s/.*addr://;s/ .*//;p}' | head -n1`
while true
do
    sleep 1
    echo -e "\e[1;33m###################################\e[0m"
    master_log_file=$(mysql -u$s_user -p$s_password -h$s_host -P$s_port -e "show slave status\G" |grep -w Master_Log_File |awk -F": " '{print $2}')
    
    relay_master_log_file=$(mysql -u$s_user -p$s_password -h$s_host -P$s_port -e "show slave status\G" |grep -w Relay_Master_Log_File |awk -F": " '{print $2}')

    read_master_log_pos=$(mysql -u$s_user -p$s_password -h$s_host -P$s_port -e "show slave status\G" |grep -w Read_Master_Log_File |awk -F": " '{print $2}')


    exec_master_log_pos=$(mysql -u$s_user -p$s_password -h$s_host -P$s_port -e "show slave status\G" |grep -w Exec_Master_Log_Pos | awk -F": " '{print $2}' | sed 's/[ \t]*$//g')

    master_log_file_num=`echo master_log_file |awk -F '.' '{print $2}' | sed 's/^0\+//'`
    master_file=$(mysql -u$m_user -p$m_password -h$m_host -P$m_port -Nse "show master status" | awk '{print $1}')
    master_pos=$(mysql -u$m_user -p$m_password -h$m_host -P$m_port -Nse "show master status" | awk '{print $2}'|sed 's/[ \t]*$//g')
    master_file_num=`echo $master_file |awk -F '.' '{print $2}' | sed 's/^0\+//'`

    if [ -z $master_log_file ] && [ -z $relay_master_log_file ] && [ -z $read_master_log_pos ] && [ -z $exec_master_log_pos ]
    then
        echo -e "\e[1;31mSLAVE 没有取到值，请检查参数设置!\e[0m]]"
        exit 1
    fi

    if [ $master_log_file = $relay_master_log_file ] && [ $read_master_log_pos = $exec_master_log_pos ]
    then
        if [ $master_log_file = $master_file ] && [ $exec_master_log_pos = $master_pos ]
        then
            echo -e "\e[1;32mMaster-slave 复制无延迟 ^_^\e[0m]]"
        else
            if [ $master_log_file_num -gt $master_file_num ] || [ $master_pos -gt $master_log_file_num ]
                then
                    log_count=$(expr $master_log_file_num - $master_file_num)
                    pos_count=$(expr $master_pos - $exec_master_log_pos)
                    echo -e "\e[1;31mMaster-slave 复制延迟 !!!\e[0m]]"
                    echo -e "\e[1;31mMaster:$m_host Slave:$slave_wan_ip\e[0m]]"
                    echo -e "\e[1;31mMaster当前binlog: $Master_File]"
                    echo -e "\e[1;31mSlave当前binlog:  $Master_Log_File]"
                     echo -e "\e[1;31mbinlog相差文件数: $log_count\e[0m]]"
                     echo -e "\e[1;31mPos点相差:        $pos_count\e[0m]]"
            fi
        fi
    fi
done

