#!/bin/bash
while read line 
do
    curl -x $line www.baidu.com -m 5 --connect-timeout 5 -o /dev/null -s -w "$line "%{http_code}"\n"
done<ip.txt
