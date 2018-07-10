############################################################
#
# script pour tester l'etat d'une bdd suite au reboot CD 2018-07-05
#
###########################################################

#!/bin/bash


#usage
if [ $# -ne 0 ] ; then
        echo "usage : $0"
        exit 1
fi

# tableau de hostname
declare -A SERV_NAME
SERV_NAME["srv-xxx-1"]="user/pwd@bdd"
SERV_NAME["srv-xxx-2"]="user/pwd@bdd"

#host=$(hostname -s) or  ${host%%.*} for host=`hostname`
#echo ${SERV_NAME["$host"]}

CNX=${SERV_NAME["$(hostname -s"]} <<!

set echo off

SELECT INSTANCE_NAME, STATUS, DATABASE_STATUS FROM V\$INSTANCE;
exit;
!
