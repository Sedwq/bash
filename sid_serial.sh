############################################################
#
# script pour obtenir sid et serial
#
###########################################################

#!/usr/bin/bash

#usage
if [ $# -ne 1 ] ; then
        echo "usage : $0 <id_session>"
        echo "ex. : $0 1234567890"
        exit
fi

sqlplus -s /@XXXXX <<EOF
set echo off heading off
select a.sid, a.serial# from v\$session a, v\$process b where  a.paddr=b.addr and a.process='$1' ;
exit;
EOF

