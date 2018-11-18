#!/bin/bash
SUBJECT="Named status"
MAILTO=$(cat cat /root/.forward)

grep 'client' /var/log/named/misc.log | awk -F' ' '{print $5}' | awk -F'#' '{print $1}' | sort | uniq -c | sort -nr | head -20 >> /tmp/sendNamedStatus.txt

MESSAGE=$(cat /tmp/sendNamedStatus.txt)

(
echo "From: root";
echo "To: root";
echo "Subject: ${SUBJECT}";
echo "";
echo "${MESSAGE}"
) | sendmail -t

rm -f /tmp/sendNamedStatus.txt
