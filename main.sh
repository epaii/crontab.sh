#!/usr/bin/env bash


#echo `ps -ef |grep crontab/main.sh | grep -v grep`;

ProcNumber=`ps -ef |grep crontab/main.sh| grep -v grep |wc -l`

if [ $ProcNumber -gt 2 ];then
    echo "$ProcNumber has runing"
    exit
fi




thisdir=`dirname $0`/config

source $thisdir/config.ini
`umask 0000`
while [ true ]
do
	logdate=`date +"%Y%m%d"`
	now=`date +"%Y-%m-%d %H:%M:%S"`

	logfile=$logdir$logdate".log"


	if [ ! -d $logdir ]; then
		mkdir -p $logdir
	fi

	source $thisdir/source.ini
	if [ "$ctl" = "start" ]; then
		find=$($sh_find)
		tmp_pre="${find%\|*}"

		if [ "$tmp_pre"  = "success" ]
		then

			find="${find#*\|}"

			now=`date +"%Y-%m-%d %H:%M:%S"`
			echo "" $now "新的任务： $find "  >> $logfile

			if [ "$find"  != "" ]
			then
				ii=1
				while [ true ]; do
					tmp=`echo $find | cut  -d ";"  -f $ii`

					if [ "$tmp" = "" ]; then
						break;
					elif [ "$tmp" = "$find" ]; then
						`$tmp  >> $logfile  2>>${logfile}.error.log &`
						break;
					else

						`$tmp  >> $logfile  2>>${logfile}.error.log &`

						((ii++))
					fi

				done
			fi

		fi
	elif [ "$ctl" = "exit" ]; then
		now=`date +"%Y-%m-%d %H:%M:%S"`
		echo "" $now "程序结束 "  >> $logfile
		exit 1
	fi
	sleep $step
done
exit
