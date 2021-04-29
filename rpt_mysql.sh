#!/bin/bash
#

############################################################################################
#
#  Rapport mail MYSQL
#  CD 02/12/2019 
#
############################################################################################
#Variables


## ajouter stat index principaux

TIME=`date "+%F %T"`

FICHTML=./fic_to_send.html

FROM="xxxx@xxx"
To="xxxx@xxx"
SMTPServer="SMTP"
subject="Rapport des bases MySQL OK"


MYSQL="/usr/bin/mysql"
#query="\s"

#list serveur
LIST_MYSQL=("_master" "_slave_1" "_slave_2" "_slave_3" "_com" "_octo")
#LIST_MYSQL=("_recette" "_dev")

#fonction query
query()
{
result=`$MYSQL --defaults-group-suffix="$1" -Bse "$2" 2> /dev/null`

if [ -z "$result" ];then
        echo "Erreur d'accès ou pas de bases"
        exit 1
	else
	printf '%s\n' "$result"
fi
}

#allRunVers=()
#for h in ${LIST_MYSQL[@]}; do
#RUN_VERS=$(query $h "\s"| grep 'Server version' | awk -F\: '{sub(/^[ \t\r\n]+/, "", $2);print $2}')
#allRunVers+=("$RUN_VERS")
#done
#
#allUptime=()
#for h in ${LIST_MYSQL[@]}; do
#UPTIME=$(query $h "\s"| grep Uptime | awk -F\: '{sub(/^[ \t\r\n]+/, "", $2);print $2}')
#allUptime+=("$UPTIME")
#done
#
#allHost=()
#for h in ${LIST_MYSQL[@]}; do
#HOST=$(query $h "\s"| grep 'Connection:' | awk '{print $2}')
#allHost+=("$HOST")
#done

allStatus=()
for h in ${LIST_MYSQL[@]}; do
STATUS=$(query $h "\s")
sleep 6
allStatus+=("$STATUS")
done

allRunVers=()
for s in ${allStatus[@]}; do
RUN_VERS=$(echo "$s" | grep 'Server version' | awk -F\: '{sub(/^[ \t\r\n]+/, "", $2);print $2}')
sleep 6
allRunVers+=("$RUN_VERS")
done

allUptime=()
for h in ${LIST_MYSQL[@]}; do
UPTIME=$(echo "$s" | grep Uptime | awk -F\: '{sub(/^[ \t\r\n]+/, "", $2);print $2}')
sleep 6
allUptime+=("$UPTIME")
done

allHost=()
for h in ${LIST_MYSQL[@]}; do
HOST=$(echo "$s" | grep 'Connection:' | awk '{print $2}')
sleep 6
allHost+=("$HOST")
done

allTot_tab=()
for h in ${LIST_MYSQL[@]}; do
TOT_TAB=`query $h "SELECT COUNT(*) FROM information_schema.tables ;"`
sleep 6
allTot_tab+=("$TOT_TAB")
done

#allTot_dat_inno=()
#for h in ${LIST_MYSQL[@]}; do
#TOT_DAT_INNO=`query $h "SELECT sys.format_bytes(sum(data_length)) DATA
#       FROM information_schema.TABLES 
#WHERE TABLE_SCHEMA NOT IN ('sys','mysql', 'information_schema', 
#                'performance_schema', 'mysql_innodb_cluster_metadata')
#				AND ENGINE='INNODB';"`
#allTot_dat_inno+=("$TOT_DAT_INNO")
#done

allTot_frag=()
for a in ${LIST_MYSQL[@]}; do
TOT_FRAG=`query $h "SELECT sys.format_bytes(SUM(data_free)) FROM information_schema.TABLES ;"`
sleep 6
allTot_frag+=("$TOT_FRAG")
done

allPas_as=()
for b in ${LIST_MYSQL[@]}; do
PAS_AS=`query $h "select count(authentication_string)  from  mysql.user where host='localhost' and authentication_string=' ' ;"`
sleep 6
allPas_as+=("$PAS_AS")
done

allTot_acc=()
for c in ${LIST_MYSQL[@]}; do
TOT_ACC=`query $h "select count(*) from mysql.user;"`
sleep 6
allTot_acc+=("$TOT_ACC")
done

allTot_db=()
for d in ${LIST_MYSQL[@]}; do
TOT_DB=`query $h "SELECT sys.format_bytes(SUM(data_length + index_length))  FROM information_schema.tables ;"`
sleep 6
allTot_db+=("$TOT_DB")
done

allTot_all=()
for e in ${LIST_MYSQL[@]}; do
TOT_ALL=`query $h "SELECT sys.format_bytes(SUM(data_length + index_length))  FROM information_schema.tables where table_schema='dbx';"`
sleep 6
allTot_all+=("$TOT_ALL")
done

allTot_his=()
for f in ${LIST_MYSQL[@]}; do
TOT_HIS=`query $h "SELECT sys.format_bytes(SUM(data_length + index_length))  FROM information_schema.tables where table_name='tb_order_history';"`
sleep 6
allTot_his+=("$TOT_HIS")
done

allTot_ord=()
for g in ${LIST_MYSQL[@]}; do
TOT_ORD=`query $h "SELECT sys.format_bytes(SUM(data_length + index_length))  FROM information_schema.tables where table_name='tb_order';"`
sleep 6
allTot_ord+=("$TOT_ORD")
done

allTot_cli=()
for h in ${LIST_MYSQL[@]}; do
TOT_CLI=`query $h "SELECT sys.format_bytes(SUM(data_length + index_length))  FROM information_schema.tables where table_name='tb_client';"`
sleep 6
allTot_cli+=("$TOT_CLI")
done

allQcache_free_percent=()
for i in ${LIST_MYSQL[@]}; do
Qcache_free_percent=`query $h "select ROUND((select VARIABLE_VALUE  from performance_schema.global_status WHERE VARIABLE_NAME='Qcache_free_memory') /(select @@query_cache_size) * 100) AS Qcache_free_percent ;"`
sleep 6
allQcache_free_percent+=("$Qcache_free_percent")
done

allQcache_free_block_percent=()
for j in ${LIST_MYSQL[@]}; do
Qcache_free_block_percent=`query $h "select ROUND((select VARIABLE_VALUE  from performance_schema.global_status WHERE VARIABLE_NAME='Qcache_free_blocks') / (select VARIABLE_VALUE  from performance_schema.global_status WHERE VARIABLE_NAME='Qcache_total_blocks' ) * 100 ) AS Qcache_total_blocks ;"`
sleep 6
allQcache_free_block_percent+=("$Qcache_free_block_percent")
done

#</TR>	
#<TR><TD>Total data in Innodb tables</TD>
#    <TD BGCOLOR=green>"${allTot_dat_inno[0]}"</TD>
#    <TD BGCOLOR=green>"${allTot_dat_inno[1]}"</TD>
#    <TD BGCOLOR=green>"${allTot_dat_inno[2]}"</TD>
#    <TD BGCOLOR=green>"${allTot_dat_inno[3]}"</TD>
#    <TD BGCOLOR=green>"${allTot_dat_inno[4]}"</TD>
#    <TD BGCOLOR=green>"${allTot_dat_inno[5]}"</TD>

#en tête html 
echo "<title>Rapport Bases MYSQL Dbv</title> 
		<HTML><HEAD></HEAD><BODY link=\"white\"> 
		<B><div align=\"left\">Rapport de production du  "$TIME"</div></B>
		<TABLE border=1>
		<TD BGCOLOR=GREEN>GOBAL STATUS</a></TD><BR>
		</TABLE><BR><BR>" > $FICHTML

#Corps
echo "<TABLE border=1 cellspacing=0 cellpadding=10>
<TD bgcolor=#CCCCCC width=180><a id=production></a><i>Technical metrics</i></TD>
<TD BGCOLOR=green width=100>"${allHost[0]}"</TD>
<TD BGCOLOR=green width=100>"${allHost[1]}"</TD>
<TD BGCOLOR=green width=100>"${allHost[2]}"</TD>
<TD BGCOLOR=green width=100>"${allHost[3]}"</TD>
<TD BGCOLOR=green width=100>"${allHost[4]}"</TD>
<TD BGCOLOR=green width=100>"${allHost[5]}"</TD>
<TR><TD>Currently runing version</TD>
    <TD BGCOLOR=green>"${allRunVers[0]}"</TD>
    <TD BGCOLOR=green>"${allRunVers[1]}"</TD>
    <TD BGCOLOR=green>"${allRunVers[2]}"</TD>
    <TD BGCOLOR=green>"${allRunVers[3]}"</TD>
    <TD BGCOLOR=green>"${allRunVers[4]}"</TD>
    <TD BGCOLOR=green>"${allRunVers[5]}"</TD>
</TR>
<TR><TD>Uptime mysql</TD>
    <TD BGCOLOR=green>"${allUptime[0]}"</TD>
    <TD BGCOLOR=green>"${allUptime[1]}"</TD>
    <TD BGCOLOR=green>"${allUptime[2]}"</TD>
    <TD BGCOLOR=green>"${allUptime[3]}"</TD>
    <TD BGCOLOR=green>"${allUptime[4]}"</TD>
    <TD BGCOLOR=green>"${allUptime[5]}"</TD>
</TR>
<TR><TD>Qcache_free_percent</TD>
    <TD BGCOLOR=green>"${allQcache_free_percent[0]}"%</TD>
    <TD BGCOLOR=green>"${allQcache_free_percent[1]}"%</TD>
    <TD BGCOLOR=green>"${allQcache_free_percent[2]}"%</TD>
    <TD BGCOLOR=green>"${allQcache_free_percent[3]}"%</TD>
    <TD BGCOLOR=green>"${allQcache_free_percent[4]}"%</TD>
    <TD BGCOLOR=green>"${allQcache_free_percent[5]}"%</TD>
</TR>
<TR><TD>Qcache_free_block_percent</TD>
    <TD BGCOLOR=green>"${allQcache_free_block_percent[0]}"%</TD>
    <TD BGCOLOR=green>"${allQcache_free_block_percent[1]}"%</TD>
    <TD BGCOLOR=green>"${allQcache_free_block_percent[2]}"%</TD>
    <TD BGCOLOR=green>"${allQcache_free_block_percent[3]}"%</TD>
    <TD BGCOLOR=green>"${allQcache_free_block_percent[4]}"%</TD>
    <TD BGCOLOR=green>"${allQcache_free_block_percent[5]}"%</TD>
</TR>
<TD bgcolor=#CCCCCC width=180><a id=production></a><i>Storage Engine Statistics</i></TD>
    <TD BGCOLOR=green>"OK / NOK"</TD>
    <TD BGCOLOR=green>"OK / NOK"</TD>
    <TD BGCOLOR=green>"OK / NOK"</TD>
    <TD BGCOLOR=green>"OK / NOK"</TD>
    <TD BGCOLOR=green>"OK / NOK"</TD>
    <TD BGCOLOR=green>"OK / NOK"</TD>
</TR>
<TR><TD>Total size mysql</TD>
    <TD BGCOLOR=green>"${allTot_db[0]}"</TD>
    <TD BGCOLOR=green>"${allTot_db[1]}"</TD>
    <TD BGCOLOR=green>"${allTot_db[2]}"</TD>
    <TD BGCOLOR=green>"${allTot_db[3]}"</TD>
    <TD BGCOLOR=green>"${allTot_db[4]}"</TD>
    <TD BGCOLOR=green>"${allTot_db[5]}"</TD>
</TR>	
<TR><TD>Total size Dbx DB</TD>
    <TD BGCOLOR=green>"${allTot_all[0]}"</TD>
    <TD BGCOLOR=green>"${allTot_all[1]}"</TD>
    <TD BGCOLOR=green>"${allTot_all[2]}"</TD>
    <TD BGCOLOR=green>"${allTot_all[3]}"</TD>
    <TD BGCOLOR=green>"${allTot_all[4]}"</TD>
    <TD BGCOLOR=green>"${allTot_all[5]}"</TD>
</TR>	
<TR><TD>Total size tb_order_history tab</TD>
    <TD BGCOLOR=green>"${allTot_his[0]}"</TD>
    <TD BGCOLOR=green>"${allTot_his[1]}"</TD>
    <TD BGCOLOR=green>"${allTot_his[2]}"</TD>
    <TD BGCOLOR=green>"${allTot_his[3]}"</TD>
    <TD BGCOLOR=green>"${allTot_his[4]}"</TD>
    <TD BGCOLOR=green>"${allTot_his[5]}"</TD>
</TR>
<TR><TD>Total size tb_order tab</TD>
    <TD BGCOLOR=green>"${allTot_ord[0]}"</TD>
    <TD BGCOLOR=green>"${allTot_ord[1]}"</TD>
    <TD BGCOLOR=green>"${allTot_ord[2]}"</TD>
    <TD BGCOLOR=green>"${allTot_ord[3]}"</TD>
    <TD BGCOLOR=green>"${allTot_ord[4]}"</TD>
    <TD BGCOLOR=green>"${allTot_ord[5]}"</TD>
</TR>
<TR><TD>Total size tb_client tab</TD>
    <TD BGCOLOR=green>"${allTot_cli[0]}"</TD>
    <TD BGCOLOR=green>"${allTot_cli[1]}"</TD>
    <TD BGCOLOR=green>"${allTot_cli[2]}"</TD>
    <TD BGCOLOR=green>"${allTot_cli[3]}"</TD>
    <TD BGCOLOR=green>"${allTot_cli[4]}"</TD>
    <TD BGCOLOR=green>"${allTot_cli[5]}"</TD>
</TR>	
<TR><TD>Total tables</TD>
    <TD BGCOLOR=green>"${allTot_tab[0]}"</TD>
    <TD BGCOLOR=green>"${allTot_tab[1]}"</TD>
    <TD BGCOLOR=green>"${allTot_tab[2]}"</TD>
    <TD BGCOLOR=green>"${allTot_tab[3]}"</TD>
    <TD BGCOLOR=green>"${allTot_tab[4]}"</TD>
    <TD BGCOLOR=green>"${allTot_tab[5]}"</TD>
</TR>
<TR><TD>Datafree from fragmented tables</TD>
    <TD BGCOLOR=green>"${allTot_frag[0]}"</TD>
    <TD BGCOLOR=green>"${allTot_frag[1]}"</TD>
    <TD BGCOLOR=green>"${allTot_frag[2]}"</TD>
    <TD BGCOLOR=green>"${allTot_frag[3]}"</TD>
    <TD BGCOLOR=green>"${allTot_frag[4]}"</TD>
    <TD BGCOLOR=green>"${allTot_frag[5]}"</TD>
</TR>
<TD bgcolor=#CCCCCC width=180><a id=production></a><i>Security Recommandations</i></TD>
    <TD BGCOLOR=green>"OK / NOK"</TD>
    <TD BGCOLOR=green>"OK / NOK"</TD>
    <TD BGCOLOR=green>"OK / NOK"</TD>
    <TD BGCOLOR=green>"OK / NOK"</TD>
    <TD BGCOLOR=green>"OK / NOK"</TD>
    <TD BGCOLOR=green>"OK / NOK"</TD>
</TR>
<TR><TD>Users without passwords assigned</TD>
    <TD BGCOLOR=green>"${allPas_as[0]}"</TD>
    <TD BGCOLOR=green>"${allPas_as[1]}"</TD>
    <TD BGCOLOR=green>"${allPas_as[2]}"</TD>
    <TD BGCOLOR=green>"${allPas_as[3]}"</TD>
    <TD BGCOLOR=green>"${allPas_as[4]}"</TD>
    <TD BGCOLOR=green>"${allPas_as[5]}"</TD>
</TR>
<TR><TD>Total users</TD>
    <TD BGCOLOR=green>"${allTot_acc[0]}"</TD>
    <TD BGCOLOR=green>"${allTot_acc[1]}"</TD>
    <TD BGCOLOR=green>"${allTot_acc[2]}"</TD>
    <TD BGCOLOR=green>"${allTot_acc[3]}"</TD>
    <TD BGCOLOR=green>"${allTot_acc[4]}"</TD>
    <TD BGCOLOR=green>"${allTot_acc[5]}"</TD>
</TR>
</TABLE>
<BR><BR><BR></BODY></HTML>" >> $FICHTML



#mailx -a 'Content-Type: text/html' -s "rpt" $To < $FICHTML