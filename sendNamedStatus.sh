#!/bin/bash
SUBJECT="Named banned ip"
SOURCEFILE="/var/log/named/misc.log"
TMPFILE="/tmp/sendNamedStatus.txt"
CONFFILE="/etc/named.conf"
THRESHOLD=1000

grep 'client' ${SOURCEFILE} | awk -F' ' '{print $5}' | awk -F'#' '{print $1}' | sort | uniq -c | sort -nr | head -20 >> ${TMPFILE}

while read ROW; do
	if [ $(echo "${ROW}" | awk -F' ' '{print $1}') -gt ${THRESHOLD} ]; then
		IP=$(echo "${ROW}" | awk -F' ' '{print $2}')
		if [ $(grep -c "${IP}" ${CONFFILE}) -eq 0 ]; then
			INFOIP=$(curl -s 'ipinfo.io/'${IP} | jq -c [.country,.org])
			sed -i "/acl \"blackhats\"/a\ \ \ \ ${IP}; # ${INFOIP}" "${CONFFILE}"
			MESSAGE+=${ROW}' '${INFOIP}'\r\n' 
		fi
	fi
done < ${TMPFILE}

systemctl reload named

if [ ! -z "${MESSAGE}" ]; then
	(
		echo "From: root";
		echo "To: root";
		echo "Subject: ${SUBJECT}";
		echo "";
		echo -e "${MESSAGE}"
	) | sendmail -t
fi

rm -f ${TMPFILE}
