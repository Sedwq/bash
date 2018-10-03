############################################################
#
# script pour creer une session
#
###########################################################

#!/usr/bin/bash

sqlplus -s /@xxxxxx <<EOF
set echo off heading off

DECLARE
BEGIN
DBMS_LOCK.SLEEP(300);
END;
/

exit;
EOF
