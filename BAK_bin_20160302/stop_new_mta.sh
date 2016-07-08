#!/bin/bash

#### 关闭MTA进程，并删除旧的MTA版本 expect函数 ####

function mta_stop ()
{
	ip_mta=$1
	number_j=$2
	current_time=$3

#	echo -e "path_mta_work=$path_mta_work"
#	echo -e "ip_mta=$ip_mta"
#	echo -e "NFS_path=$NFS_path"
#	echo -e "path_file=$path_file"
#	echo -e "path_server=$path_server"
#	echo -e "number_j=$number_j"

	expect expect/stop_mta.exp $ip_mta $number_j> $TMP_path/stop_mta_${current_time}_${path_server}_${number_j}.log 2>&1
	if grep -q "$number_j OK 1nonothing" $TMP_path/stop_mta_${current_time}_${path_server}_${number_j}.log ;then
		return 0
	else		
		return 1
	fi

}

#### 关闭MTA进程 ####

function stop_mta ()
{
echo -e "按Y或y继续操作，关闭MTA进程：\n"
echo -e ">>\c"
read choice_Y

#server_number=`cat $TMP_path/choice_server1.csv | wc -l`
awk -F',' '!a[$1]++' $TMP_path/choice_MTA_server1.csv >$TMP_path/choice_MTA_server2.csv
server_number=`cat $TMP_path/choice_MTA_server2.csv | wc -l`
current_time=`date +%H%M%S`
path_mta_work=/home/MT_agent

if [ ${choice_Y} == "y" -o ${choice_Y} == "Y" ];then

			echo -e "\n请查看日志文件=== $TMP_path/stop_mta_${current_time}_[BJBGP20_GS01].log ===[ ]内表示对应机柜及物理机\n"

			for i in `seq 1 $server_number`
			do
##############################################
#### 内层for循环 #### 并行执行 #### 单个服同时多进程
#
			temp_fifo_file=$$.info	##以当前进程号，为临时管道取名
			mkfifo $temp_fifo_file	##创建临时管道
			exec 9<>$temp_fifo_file	##创建标识为9，可以对管道进行读写
			rm $temp_fifo_file		##清空管道内容
			temp_thread=6			##并发进程数
			for ((ii=0;ii<$temp_thread;ii++))	##为进程创建相应的占位
			do
				echo				##每个echo输出一个回车，为每个进程创建一个占位
			done >&9				##将占位信息写入标识为9的管道
#
##############################################

				SERVER=`sed -n "$i"p $TMP_path/choice_MTA_server2.csv`
				path_server=`echo $SERVER |awk -F, '{print $1}'`
				sec_IP=`echo $SERVER |awk -F: '{print $2}'`
				ALL_server=`echo $SERVER |awk -F: '{print $3}'`
				Array_server=`echo $ALL_server |awk -F "-|," '{for(i=1;i<=NF;i+=2)$i="";print}'`

				name_server=`echo $SERVER |awk -F, '{print $2}'`
				TYPE_moban=`echo $SERVER |awk -F, '{print $3}'`
				template_file=`ls template/ |grep "_${TYPE_moban}_" |grep -E "xml$" |grep -E "^template"`   ##匹配模板文件，比如31模板
				NFS_path=`cat template/${template_file} |awk '/<'gdir'>/,/<\/'gdir'>/{if(j>1)print x;x=$0;j++}' |awk '/<'verdir'>/,/<\/'verdir'>/{if(jj>1)print x;x=$0;jj++}' |awk -F= '/nfsdir/{print$2}' |tr -d " "`
				NFS_IP=192.168.${sec_IP}.`cat template/${template_file} |awk '/<'gdir'>/,/<\/'gdir'>/{if(k>1)print x;x=$0;k++}' |awk '/<'verdir'>/,/<\/'verdir'>/{if(kk>1)print x;x=$0;kk++}' |awk -F= '/IP/{print$2}' |tr -d " "`
				all_server=`cat template/${template_file} |awk '/<'PHY_SERVER'>/,/<\/'PHY_SERVER'>/{if(i>1)print x;x=$0;i++}' |awk -F= '/ALL_server/{print$2}'|tr -d "\r"`
				Array_server=${all_server}

#				echo -e "\n请查看日志文件=== $TMP_path/stop_mta_${current_time}_[BJBGP20_GS01].log ===[ ]内表示对应机柜及物理机\n"

				printf "%-27sMTA关闭结果：" "$name_server""($path_server)"

				for j in ${Array_server[@]}
				do
					read -u9	##内层多进程时打开
					{			##内层多进程时打开

#					echo "j=$j"
					path_upload=`cat template/${template_file} |awk '/<'gserver'>/,/<\/'gserver'>/{if(i>1)print x;x=$0;i++}' |awk '/<'MTA'>/,/<\/'MTA'>/{if(ii>1)print x;x=$0;ii++}' |awk -F= '/path/{print$2}' |tr -d " "`
					ip_mta=192.168.${sec_IP}.`cat template/${template_file} |awk '/<'gserver'>/,/<\/'gserver'>/{if(i>1)print x;x=$0;i++}' |awk -v j="$j" '/<'$j'>/,/<\/'$j'>/{if(jj>1)print x;x=$0;jj++}' |awk -F= '/IP/{print$2}' |tr -d " "`

#					echo -e "path_upload=$path_upload"
#					echo -e "ip_mta=$ip_mta"
#						num_thread=${TYPE_thread}${j}
						mta_stop $ip_mta $j $current_time

						ret=$?

						if [ $ret -eq 0 ];then
							echo -e "\033[40;32m$j \033[0m\c"	##上传成功返回绿色
						else
							echo -e "\033[40;31m$j \033[0m\c"	##上传失败返回红色
						fi
				echo >&9
				}&
				done

				wait	##
				echo	##行尾打印服名
				exec 9>&-	##

			done


##############################################

else
        echo -e "请重新输入!!!"
        echo
        stop_mta
fi
}

stop_mta
