#!/bin/sh
#############################################################################################################################
# Author: Raj Desikavinayagompillai                                                                                                            #
# Purpose: IOPS Monitoring of Servers                                                                                       #
#############################################################################################################################
IO_REPORT_DELAY=1
IO_INTERVAL=2
IOSTAT_CNT1=`iostat  1 1 |wc -l `
IOSTAT_CNT2=`iostat  1 2 |wc -l `
mkdir -p ./logs ./tmp
LOG_DIR="./logs"
IOSTAT_TMP_FILE=./tmp/iostat_tmp_file.IOPS
if [ $IO_INTERVAL -lt 1 ]
then
IO_INTERVAL=2
fi
IOSTAT_DIFFCNT=`expr ${IOSTAT_CNT2} - ${IOSTAT_CNT1} `
iostat  ${IO_REPORT_DELAY} ${IO_INTERVAL} | tail -${IOSTAT_DIFFCNT}  >${IOSTAT_TMP_FILE}
Device_lno=`cat ${IOSTAT_TMP_FILE}  |grep -n Device|cut -d: -f1`
Total_lno=`cat ${IOSTAT_TMP_FILE}  |wc -l`
Total_lno=`expr $Total_lno + 0 `
Device_lno=`expr $Device_lno + 0 `
Disks_lno_tmp=`expr $Total_lno - $Device_lno `
Disks_lno=`expr $Total_lno - $Device_lno `
DATE=`date '+%Y%m%d%H%M'`
REPORT_DATE=`date '+%Y%m%d'`
REPORT_LOG_DIR=${LOG_DIR}/IOPS/logs
mkdir -p ${REPORT_LOG_DIR}
REPORT_DETAILED_LOG=${REPORT_LOG_DIR}/IOPS_detailed_$REPORT_DATE.log
REPORT_LOG=${REPORT_LOG_DIR}/IOPS_$REPORT_DATE.log
if [ $Disks_lno -ge 1 ]
then
Disks_lno=`expr $Disks_lno - 1 `
fi
Tot_IOPS_Writes=0
Tot_IOPS_Reads=0
Tot_IOPS_Writes_Size=0
Tot_IOPS_Reads_Size=0
Tot_IOPS=0
Tot_IOPS_Size=0
DISKS_LIST=`cat ${IOSTAT_TMP_FILE}  |tail -$Disks_lno_tmp|head -$Disks_lno|awk ' { print $1}'`
for disk_name in $DISKS_LIST
do
WKB=`cat ${IOSTAT_TMP_FILE}  |tail -$Disks_lno_tmp|grep "^$disk_name" | awk ' { print $9}'|cut -d"." -f1`
RKB=`cat ${IOSTAT_TMP_FILE}  |tail -$Disks_lno_tmp|grep "^$disk_name" | awk ' { print $8}'|cut -d"." -f1`
RperS=`cat ${IOSTAT_TMP_FILE}  |tail -$Disks_lno_tmp|grep "^$disk_name" | awk ' { print $4}'|cut -d"." -f1`
WperS=`cat ${IOSTAT_TMP_FILE}  |tail -$Disks_lno_tmp|grep "^$disk_name" | awk ' { print $5}'|cut -d"." -f1`
WKB=`expr $WKB + 0 `
RKB=`expr $RKB + 0 `
RperS=`expr $RperS + 0 `
WperS=`expr $WperS + 0 `
if [ $WperS -eq 0 ]
then
WperS=1
fi
if [ $RperS -eq 0 ]
then
RperS=1
fi
IOPS_Writes=`expr $WperS + 0 `
IOPS_Reads=`expr $RperS + 0 `
IOPS_Writes_Size=`expr $WKB / $WperS `
IOPS_Reads_Size=`expr $RKB / $RperS `
IOPS_Size=`expr $IOPS_Writes_Size + $IOPS_Reads_Size `
IOPS=`expr $IOPS_Writes + $IOPS_Reads `
Tot_IOPS_Writes_Size=`expr $IOPS_Writes_Size + $Tot_IOPS_Writes_Size `
Tot_IOPS_Reads_Size=`expr $IOPS_Reads_Size + $Tot_IOPS_Reads_Size `
Tot_IOPS_Writes_Size=`expr $Tot_IOPS_Writes_Size + $IOPS_Writes_Size `
Tot_IOPS_Reads_Size=`expr $Tot_IOPS_Reads_Size + $IOPS_Reads_Size `
Tot_IOPS_Writes=`expr $Tot_IOPS_Writes + $IOPS_Writes `
Tot_IOPS_Reads=`expr $Tot_IOPS_Reads + $IOPS_Reads `
Tot_IOPS_Size=`expr $Tot_IOPS_Size + $IOPS_Size `
Tot_IOPS=`expr $Tot_IOPS + $IOPS `
echo DATE:$DATE DiskName:$disk_name Tot_IOPS_Writes:$Tot_IOPS_Writes Tot_IOPS_Reads:$Tot_IOPS_Reads Tot_IOPS:$Tot_IOPS IOPS:$IOPS Tot_IOPS_Writes_Size:$Tot_IOPS_Writes_Size Tot_IOPS_Reads_Size:$Tot_IOPS_Reads_Size Tot_IOPS_Size:$Tot_IOPS_Size IOPS_Size:$IOPS_Size >>$REPORT_DETAILED_LOG
done
echo DATE:$DATE Tot_IOPS_Writes:$Tot_IOPS_Writes Tot_IOPS_Reads:$Tot_IOPS_Reads Tot_IOPS:$Tot_IOPS Tot_IOPS_Writes_Size:$Tot_IOPS_Writes_Size Tot_IOPS_Reads_Size:$Tot_IOPS_Reads_Size Tot_IOPS_Size:$Tot_IOPS_Size >> $REPORT_LOG
