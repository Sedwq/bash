############################################################
#
# script pour creer une session persistante
#
###########################################################

#!/usr/bin/bash

sqlplus -s /@ctaexprec <<EOF
set echo off heading off

DECLARE
BEGIN
DBMS_LOCK.SLEEP(300);
END;
/

exit;
EOF
