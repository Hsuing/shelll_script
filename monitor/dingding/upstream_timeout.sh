#!/bin/bash
#https://ding-doc.dingtalk.com/doc#/serverapi2/potcn9
#########################################################################
#
BIND_IP=`/sbin/ifconfig ${ETH0}| grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -1`
# set variables
TOKEN="https://oapi.dingtalk.com/robot/send?access_token=xxxxx"
cluster="$(hostname)"
name="errorLog"
function SendMsgToDingding() {
TIME=`date +%F_%H:%M`
    curl $TOKEN -H 'Content-Type: application/json' -d "
    {
        'msgtype': 'text',
        'text': {
            'content': ' 告警时间:  $TIME\n 告警主机:  $cluster\n 监控名称：$name\n 告警信息：$Msg <$BIND_IP>，请注意\n'
        },
        'at': {
            'isAtAll': true
        }
    }"
}



LOGERRORCOUNT=2
CURRENTLOGLINES=0
ERRORLINES=0
TYPE=$1
FLAG=1
LOGERROR='upstream timed out'
LOGERROR2='no live upstreams while connecting to upstream'
LOGERROR3='crit'
#LOGERROR3='Connection_refused'
#0 for error
Company=`hostname`

Msg="`tail -1 /data/apps/apisix2.15/logs |sed 's/"/x/g' |sed '/ \+/s//_/g'|sed 's/%/percent/g'`,$Company"

function checkErrorLog(){
    DATES=`date +%Y%m%d`
    COUNTLOGNAME=count.log
    ERRORLOGNAME=error.log
    MONIDIR=/opt/monitor/logs
    LOGDIR=/var/log/nginx

    if [[ -d ${MONIDIR} ]];then
	LASTLINES=`echo ${MONIDIR}/${TYPE}-${COUNTLOGNAME}`
        LASTLOGLINES=`cat ${LASTLINES}`
        TOTALLINES=`cat ${LOGDIR}/${ERRORLOGNAME} | wc -l` 

        if [[ ${TOTALLINES} -lt ${LASTLOGLINES} ]];then #when logrotate reduce
            CURRENTLINES=`echo ${TOTALLINES}`
        elif [[ ${TOTALLINES} -eq ${LASTLOGLINES} ]];then #when log no change
		echo no 1>/dev/null
            exit 0
        else
            CURRENTLINES=`echo ${TOTALLINES}-${LASTLOGLINES} | bc`
        fi

        ERRORLINES=`tail -n ${CURRENTLINES} ${LOGDIR}/${ERRORLOGNAME} | grep -e "${LOGERROR}" -e "${LOGERROR2}" -e "${LOGERROR3}"| wc -l 2>/dev/null`
        if [[ ${ERRORLINES} -gt ${LOGERRORCOUNT} ]];then
            FLAG=0
            ERRORMSG="tail -n ${CURRENTLINES} ${LOGDIR}/${ERRORLOGNAME} | grep -e ${LOGERROR} -e ${LOGERROR2} -e ${LOGERROR3} 2>/dev/null"
        fi
	#echo 11 error
	SendMsgToDingding
    else
        mkdir -p ${MONIDIR}
        touch ${MONIDIR}/${LEVEL}${TYPE}-${COUNTLOGNAME}
        exit 0
    fi

    echo ${TOTALLINES} > ${LASTLINES} #write lines to local
}

checkErrorLog