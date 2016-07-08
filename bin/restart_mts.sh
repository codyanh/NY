#!/bin/bash

function mts_restart ()
{
	ip_mts=$1
	number_j=$2
	current_time=$3

	if [ $# -eq 3 ];then
		for i in {1..2}
		do
			expect expect/restart_mts.exp $ip_mts $number_j $path_mts_work > $TMP_path/restart_mts_${current_time}_${path_server}_${number_j}_$i.log 2>&1
			if grep -q "$number_j OK cmd_mts_result=0" $TMP_path/restart_mts_${current_time}_${path_server}_${number_j}_$i.log ;then
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

#### 检查本地MTS版本路径 ####

function restart_mts ()
{
echo -e "按Y或y继续操作，硬重启MTS：\n"
echo -e ">>\c"
read choice_Y

current_time=`date +%H%M%S`

if [ ${choice_Y} == "y" -o ${choice_Y} == "Y" ];then

		echo -e "\n请查看日志文件=== $TMP_path/restart_mts_${current_time}_[BJBGP20_GS01].log ===[ ]内表示对应机柜及物理机\n"

		path_server="HNDX15"
		name_server="MTS"
		printf "%-11s重启结果：" "$name_server""($path_server)"

		ip_mts=192.168.30.216
#		ip_mts=192.168.10.132

		mts_restart $ip_mts $name_server $current_time

		ret=$?

		if [ $ret -eq 0 ];then
				echo -e "\033[40;32m$name_server \033[0m\c"	##重启成功返回绿色
				echo
					cd /home/FS_server/STP/STP/
					pkill -9 STP.bin
#					printf "STP(10.38)%-1s重启结果："
					sh run_stp.sh ;sleep 2
				if grep -q "begin create thread finish" stp.log ;then
					echo -e "STP(10.38) 重启结果：\033[40;32mSTP \033[0m\c" ##重启成功返回绿色
				else
					echo -e "STP(10.38) 重启结果：\033[40;31mSTP \033[0m\c" ##重启失败返回红色
				fi
		else
				echo -e "\033[40;31m$name_server \033[0m\c"	##重启失败返回红色
		fi

else
        echo -e "请重新输入!!!"
        echo
        restart_mts
fi
}

restart_mts
