############################################################
#
# script pour killer les sessions vtom
#
###########################################################

#!/usr/bin/bash

#usage
if [[ $# -ne 1 ]] ; then
        echo "usage $0 <id_session>"
        echo "ex. $0 1234567890"
        exit
fi

cd /home/vtom/expl

if [[ ! -e ./sid_serial.sh ]] ; then
        echo "Il manque le ficher sid_serial.sh ..."
        exit
fi

SID_SERIAL=$(./sid_serial.sh $1)

if [ `expr match "$SID_SERIAL" '.*[a-z].*'` -gt 0 ] ; then
	echo "$SID_SERIAL"
	echo "Il n'existe pas de session ORACLE pour ce process UNIX !"
	exit 1
fi


SID=$(echo $SID_SERIAL | awk '{print $1}')
SERIAL=$(echo $SID_SERIAL | awk '{print $2}')

#echo $SID_SERIAL
#echo $SID
#echo $SERIAL

sqlplus /@XXXXX  << EOF
set echo off
set heading off
ALTER SYSTEM KILL SESSION '$SID,$SERIAL' IMMEDIATE;
exit;
EOF



