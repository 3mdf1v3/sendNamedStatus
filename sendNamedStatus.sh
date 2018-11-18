#!/bin/bash
SUBJECT="Named status"
FROM="${USERNAME}@${HOSTNAME}"

grep 'client' /var/log/named/misc.log | awk -F' ' '{print $5}' | awk -F'#' '{print $1}' | sort | uniq -c | sort -nr | head -20 >> /tmp/sendNamedStatus.txt

MESSAGE=$(cat /tmp/sendNamedStatus.txt)

(
echo "From: ${FROM}";
echo "To: ${USERNAME}";
echo "Subject: ${SUBJECT}";
echo "";
echo "${MESSAGE}"
) | sendmail -t

rm -f /tmp/sendNamedStatus.txt
