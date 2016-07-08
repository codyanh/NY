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

	if [ $# -eq 3 ];then
		expect expect/stop_mta.exp $ip_mta $number_j> $TMP_path/stop_mta_${current_time}_${path_server}_${number_j}.log 2>&1
		if grep -q "$number_j OK 1nonothing" $TMP_path/stop_mta_${current_time}_${path_server}_${number_j}.log ;then
			return 0
		else        
			return 1
		fi
	else                                                                                                                                                      
		echo -e "Parameter Number Error!!!\r"
		exit
	fi

}

#### 更换新的的MTA版本 ####

function mta_replace ()
{
	ip_mta=$1
	number_j=$2
	current_time=$3
	zip_mta=$4

#	echo -e "path_mta_work=$path_mta_work"
#	echo -e "ip_mta=$ip_mta"
#	echo -e "NFS_path=$NFS_path"
#	echo -e "path_file=$path_file"
#	echo -e "path_server=$path_server"
#	echo -e "number_j=$number_j"

	if [ $# -eq 4 ];then
		expect expect/replace_mta.exp $ip_mta $number_j $path_mta_work $zip_mta> $TMP_path/replace_mta_${current_time}_${path_server}_${number_j}.log 2>&1
		if grep -q "$number_j OK 0nonothing" $TMP_path/replace_mta_${current_time}_${path_server}_${number_j}.log ;then
			return 0
		else
			return 1
		fi
	else                                                                                                                                                      
		echo -e "Parameter Number Error!!!\r"
		exit
	fi

}

#### 启动MTA ####

function mta_start ()
{
	ip_mta=$1
	number_j=$2
	current_time=$3
	zip_mta=$4

#	echo -e "path_mta_work=$path_mta_work"
#	echo -e "ip_mta=$ip_mta"
#	echo -e "NFS_path=$NFS_path"
#	echo -e "path_file=$path_file"
#	echo -e "path_server=$path_server"
#	echo -e "number_j=$number_j"

	if [ $# -eq 4 ];then
		for i in {1..2}
		do
			expect expect/start_mta.exp $ip_mta $number_j $path_mta_work $zip_mta> $TMP_path/start_mta_${current_time}_${path_server}_${number_j}_$i.log 2>&1
			if grep -q "$number_j OK 0nonothing" $TMP_path/start_mta_${current_time}_${path_server}_${number_j}_$i.log ;then
				result=0
				break;
			else
				result=1
				continue;
			fi
		done
		return $result
	else
		echo -e "Parameter Number Error!!!\r"
		exit
	fi
}


#### 硬重启MTA ####

function mta_restart ()
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
	if [ $# -eq 3 ];then
		for i in {1..2}
		do
			expect expect/restart_mta.exp $ip_mta $number_j $path_mta_work > $TMP_path/restart_mta_${current_time}_${path_server}_${number_j}_$i.log 2>&1
			if grep -q "$number_j OK cmd_mta_result=0" $TMP_path/restart_mta_${current_time}_${path_server}_${number_j}_$i.log ;then
				result=0
				break;
			else
				result=1
				continue;
			fi
		done
		return $result
	else
		echo -e "Parameter Number Error!!!\r"
		exit
	fi
}

#### 检查本地MTA版本路径 ####

function main_mta ()
{
option_mta=$1
echo -e "按Y或y继续操作:"
echo -e ">>\c"
read choice_Y

#server_number=`cat $TMP_path/choice_server1.csv | wc -l`
awk -F',' '!a[$1]++' $TMP_path/choice_MTA_server1.csv >$TMP_path/choice_MTA_server2.csv
server_number=`cat $TMP_path/choice_MTA_server2.csv | wc -l`
current_time=`date +%H%M%S`

if [ ${choice_Y} == "y" -o ${choice_Y} == "Y" ];then

		echo -e "\n请查看日志文件=== $TMP_path/restart_mta_${current_time}_[BJBGP20_GS01].log ===[ ]内表示对应机柜及物理机\n"

			for i in `seq 1 $server_number`
			do
##############################################
#### 内层for循环 #### 并行执行 #### 单个服同时多进程
#
			temp_fifo_file=$$.info	##以当前进程号，为临时管道取名
			mkfifo $temp_fifo_file	##创建临时管道
			exec 9<>$temp_fifo_file	##创建标识为9，可以对管道进行读写
			rm $temp_fifo_file		##清空管道内容
			temp_thread=12			##并发进程数
			for ((ii=0;ii<$temp_thread;ii++))	##为进程创建相应的占位
			do
				echo				##每个echo输出一个回车，为每个进程创建一个占位
			done >&9				##将占位信息写入标识为9的管道
#
##############################################

				SERVER=`sed -n "$i"p $TMP_path/choice_MTA_server2.csv`
				path_server=`echo $SERVER |awk -F: '{print $1}'`
				sec_IP=`echo $SERVER |awk -F: '{print $2}'`
				ALL_server=`echo $SERVER |awk -F: '{print $3}'`
				Array_server=`echo $ALL_server |awk -F "-|," '{for(i=1;i<=NF;i+=2)$i="";print}'`
				printf "%-13sMTA重启结果：" "$path_server"

				for j in ${Array_server[@]}
				do
					read -u9	##内层多进程时打开
					{			##内层多进程时打开

#					ip_mta=192.168.${sec_IP}.`cat template/${template_file} |awk '/<'gserver'>/,/<\/'gserver'>/{if(i>1)print x;x=$0;i++}' |awk -v j="$j" '/<'$j'>/,/<\/'$j'>/{if(jj>1)print x;x=$0;jj++}' |awk -F= '/IP/{print$2}' |tr -d " "`
#					ip_mta=192.168.${sec_IP}.`echo $ALL_server |awk -F, -v j="$j" '{for(k=1;k<=NF;k++) if ($k~/'$j'/) print $'k'}' |awk -F- '{print $1}'`
					ip_mta=${sec_IP}.`echo $ALL_server |awk -F, -v j="$j" '{for(k=1;k<=NF;k++) if ($k~/'$j'/) print $'k'}' |awk -F- '{print $1}'`

#					echo -e "i=$i"
#					echo -e "j=$j"
#					echo -e "SERVER=$SERVER"
#					echo -e "path_server=$path_server"
#					echo -e "sec_IP=$sec_IP"
#					echo -e "ALL_server=$ALL_server"
#					echo -e "Array_server=$Array_server"
#					echo -e "ip_mta=$ip_mta"
#					echo -e "ALL_server=$ALL_server"
#					echo -e "================================================"
#						num_thread=${TYPE_thread}${j}

						case $option_mta in
						stop)
							mta_stop $ip_mta $j $current_time
							;;
						replace)
							echo -e "请输入已上传的MTA新版本包完整名称并回车（比如:MTA_20150805_1.zip）\n"
							echo -e ">>\c"
							read zip_mta
							mta_replace $ip_mta $j $current_time $zip_mta
							;;
						start)
							mta_start $ip_mta $j $current_time $zip_mta
							;;
						restart)
							mta_restart $ip_mta $j $current_time
							;;
						*)
							;;
						esac

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
        main_mta
fi
}

#restart_mta restart

option_mta=$1
case $1 in
stop|replace|start|restart)
	main_mta $option_mta
	;;
*)
	echo -e "\033[40;31m脚本 main.sh 参数错误！！！\033[0m"
	;;
esac
