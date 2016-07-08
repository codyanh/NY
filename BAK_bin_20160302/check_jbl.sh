#!/bin/bash

#### 检查聚宝楼报警文件函数 ####

function check_log_alarm ()
{
	alarm_IP=$1
	alarm_path=$2
	name_server=$3
	path_server=$4
	number_arg=$#

	if [ $number_arg -eq 4 ];then
        expect expect/check_jbl.exp $alarm_IP $alarm_path $name_server $path_server> $TMP_path/check_jbl_${path_server}_${name_server}.log 2>&1
        sleep 1
		if grep -q "This server No such file" $TMP_path/check_jbl_${path_server}_${name_server}.log ;then
            return 0
		else
			return 1
        fi
    else
        echo -e "$number_arg Parameter Number Error!!!\r"
    fi
}

#### 检查聚宝楼报警文件(alarm1.log) ####

function check_alarm ()
{

echo -e "继续操作请按y："                                                                                                                                    
read choiceY
if [ ${choiceY} == "Y" -o ${choiceY} == "y" ];then

    server_number=`cat $TMP_path/choice_server1.csv | wc -l`

##############################################
#### 外层for循环 #### 并行执行 #### 同时多个服
#
    temp_fifo_file=$$.info  ##以当前进程号，为临时管道取名
    mkfifo $temp_fifo_file  ##创建临时管道
    exec 9<>$temp_fifo_file ##创建标识为9，可以对管道进行读写
    rm $temp_fifo_file      ##清空管道内容
    temp_thread=3           ##并发进程数
    for ((ii=0;ii<$temp_thread;ii++))   ##为进程创建相应的占位
    do
        echo                ##每个echo输出一个回车，为每个进程创建一个占位
    done >&9                ##将占位信息写入标识为9的管道
#
##############################################

    for i in `seq 1 $server_number`
    do
        read -u9    ##外层多进程时打开
        {           ##外层多进程时打开

        SERVER=`sed -n "$i"p $TMP_path/choice_server1.csv`
        path_server=`echo $SERVER |awk -F, '{print $1}'`
        name_server=`echo $SERVER |awk -F, '{print $2}'`
        TYPE_moban=`echo $SERVER |awk -F, '{print $3}'`
        sec_IP=`echo $SERVER |awk -F, '{print $5}'`
        template_file=`ls template/ |grep "_${TYPE_moban}_" |grep -E "xml$" |grep -E "^template"`   ##匹配模板文件，比如31模板
        alarm_path=`cat template/${template_file} |awk '/<'gmod'>/,/<\/'gmod'>/{if(j>1)print x;x=$0;j++}' |awk '/<'CCS'>/,/<\/'CCS'>/{if(jj>1)print x;x=$0;jj++}' |awk -F= '/alarm_1/{print$2}' |tr -d " "`
        alarm_IP=192.168.${sec_IP}.`cat template/${template_file} |awk '/<'gmod'>/,/<\/'gmod'>/{if(k>1)print x;x=$0;k++}' |awk '/<'CCS'>/,/<\/'CCS'>/{if(kk>1)print x;x=$0;kk++}' |awk -F= '/IP/{print$2}' |tr -d " "`

        check_log_alarm $alarm_IP $alarm_path $name_server $path_server
        ret=$?
		if [ $ret -eq 0 ];then
			printf "%-20s\033[40;32m OK\033[0m\n" $name_server  ##上传成功返回绿色
		else
			printf "%-20s\033[40;31m ERROR \033[0m\n" $name_server  ##上传成功返回绿色
		fi

		echo >&9	##
		}&	##	
	done

		wait    ##
		echo    ##行尾打印服名
		exec 9>&-   ##

else
	exit 0
fi

}

check_alarm
