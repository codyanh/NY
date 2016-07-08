#!/bin/bash

#### �ر�MTA���̣���ɾ���ɵ�MTA�汾 expect���� ####

function mta_stop ()
{
	ip_mta=$1
	number_j=$2
	current_time=$3

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

#### �����µĵ�MTA�汾 ####

function mta_replace ()
{
	ip_mta=$1
	number_j=$2
	current_time=$3
	zip_mta=$4

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

#### ����MTA ####

function mta_start ()
{
	ip_mta=$1
	number_j=$2
	current_time=$3

	if [ $# -eq 3 ];then
		for i in {1..2}
		do
			expect expect/start_mta.exp $ip_mta $number_j $path_mta_work > $TMP_path/start_mta_${current_time}_${path_server}_${number_j}_$i.log 2>&1
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


#### Ӳ����MTA ####

function mta_restart ()
{
	ip_mta=$1
	number_j=$2
	current_time=$3

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

#### ��鱾��MTA�汾·�� ####

function main_mta ()
{
option_mta=$1
zip_mta=$2
echo -e "��Y��y��������:"
echo -e ">>\c"
read choice_Y

#server_number=`cat $TMP_path/choice_server1.csv | wc -l`
awk -F',' '!a[$1]++' $TMP_path/choice_MTA_server1.csv >$TMP_path/choice_MTA_server2.csv
server_number=`cat $TMP_path/choice_MTA_server2.csv | wc -l`
current_time=`date +%H%M%S`

if [ ${choice_Y} == "y" -o ${choice_Y} == "Y" ];then

		echo -e "\n��鿴��־�ļ�=== $TMP_path/${option_mta}_mta_${current_time}_[BJBGP20_GS01].log ===[ ]�ڱ�ʾ��Ӧ���������\n"

			for i in `seq 1 $server_number`
			do
##############################################
#### �ڲ�forѭ�� #### ����ִ�� #### ������ͬʱ�����
#
			temp_fifo_file=$$.info	##�Ե�ǰ���̺ţ�Ϊ��ʱ�ܵ�ȡ��
			mkfifo $temp_fifo_file	##������ʱ�ܵ�
			exec 9<>$temp_fifo_file	##������ʶΪ9�����ԶԹܵ����ж�д
			rm $temp_fifo_file		##��չܵ�����
			temp_thread=12			##����������
			for ((ii=0;ii<$temp_thread;ii++))	##Ϊ���̴�����Ӧ��ռλ
			do
				echo				##ÿ��echo���һ���س���Ϊÿ�����̴���һ��ռλ
			done >&9				##��ռλ��Ϣд���ʶΪ9�Ĺܵ�
#
##############################################

				SERVER=`sed -n "$i"p $TMP_path/choice_MTA_server2.csv`
				path_server=`echo $SERVER |awk -F: '{print $1}'`
				sec_IP=`echo $SERVER |awk -F: '{print $2}'`
				ALL_server=`echo $SERVER |awk -F: '{print $3}'`
				Array_server=`echo $ALL_server |awk -F "-|," '{for(i=1;i<=NF;i+=2)$i="";print}'`
				printf "%-13sMTA $option_mta �����" "$path_server"

				for j in ${Array_server[@]}
				do
					read -u9	##�ڲ�����ʱ��
					{			##�ڲ�����ʱ��

					ip_mta=${sec_IP}.`echo $ALL_server |awk -F, -v j="$j" '{for(k=1;k<=NF;k++) if ($k~/'$j'/) print $'k'}' |awk -F- '{print $1}'`


						case $option_mta in
						stop)
							mta_stop $ip_mta $j $current_time
							;;
						replace)
							mta_replace $ip_mta $j $current_time $zip_mta
							;;
						start)
							mta_start $ip_mta $j $current_time
							;;
						restart)
							mta_restart $ip_mta $j $current_time
							;;
						*)
							;;
						esac

						ret=$?

						if [ $ret -eq 0 ];then
							echo -e "\033[40;32m$j \033[0m\c"	##�ϴ��ɹ�������ɫ
						else
							echo -e "\033[40;31m$j \033[0m\c"	##�ϴ�ʧ�ܷ��غ�ɫ
						fi
				echo >&9
				}&
				done

				wait	##
				echo	##��β��ӡ����
				exec 9>&-	##

			done


##############################################

else
        echo -e "����������!!!"
        echo
        main_mta
fi
}

#restart_mta restart

option_mta=$1
case $1 in
stop|start|restart)
	main_mta $option_mta
	;;
replace)
	echo -e "���������ϴ���MTA�°汾���������Ʋ��س�������:MTA_20150805_1.zip��"
	echo -e ">>\c"
	read zip_mta
	main_mta $option_mta $zip_mta
	;;
*)
	echo -e "\033[40;31m�ű� main.sh �������󣡣���\033[0m"
	;;
esac
