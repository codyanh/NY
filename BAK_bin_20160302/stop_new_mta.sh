#!/bin/bash

#### �ر�MTA���̣���ɾ���ɵ�MTA�汾 expect���� ####

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

#### �ر�MTA���� ####

function stop_mta ()
{
echo -e "��Y��y�����������ر�MTA���̣�\n"
echo -e ">>\c"
read choice_Y

#server_number=`cat $TMP_path/choice_server1.csv | wc -l`
awk -F',' '!a[$1]++' $TMP_path/choice_MTA_server1.csv >$TMP_path/choice_MTA_server2.csv
server_number=`cat $TMP_path/choice_MTA_server2.csv | wc -l`
current_time=`date +%H%M%S`
path_mta_work=/home/MT_agent

if [ ${choice_Y} == "y" -o ${choice_Y} == "Y" ];then

			echo -e "\n��鿴��־�ļ�=== $TMP_path/stop_mta_${current_time}_[BJBGP20_GS01].log ===[ ]�ڱ�ʾ��Ӧ���������\n"

			for i in `seq 1 $server_number`
			do
##############################################
#### �ڲ�forѭ�� #### ����ִ�� #### ������ͬʱ�����
#
			temp_fifo_file=$$.info	##�Ե�ǰ���̺ţ�Ϊ��ʱ�ܵ�ȡ��
			mkfifo $temp_fifo_file	##������ʱ�ܵ�
			exec 9<>$temp_fifo_file	##������ʶΪ9�����ԶԹܵ����ж�д
			rm $temp_fifo_file		##��չܵ�����
			temp_thread=6			##����������
			for ((ii=0;ii<$temp_thread;ii++))	##Ϊ���̴�����Ӧ��ռλ
			do
				echo				##ÿ��echo���һ���س���Ϊÿ�����̴���һ��ռλ
			done >&9				##��ռλ��Ϣд���ʶΪ9�Ĺܵ�
#
##############################################

				SERVER=`sed -n "$i"p $TMP_path/choice_MTA_server2.csv`
				path_server=`echo $SERVER |awk -F, '{print $1}'`
				sec_IP=`echo $SERVER |awk -F: '{print $2}'`
				ALL_server=`echo $SERVER |awk -F: '{print $3}'`
				Array_server=`echo $ALL_server |awk -F "-|," '{for(i=1;i<=NF;i+=2)$i="";print}'`

				name_server=`echo $SERVER |awk -F, '{print $2}'`
				TYPE_moban=`echo $SERVER |awk -F, '{print $3}'`
				template_file=`ls template/ |grep "_${TYPE_moban}_" |grep -E "xml$" |grep -E "^template"`   ##ƥ��ģ���ļ�������31ģ��
				NFS_path=`cat template/${template_file} |awk '/<'gdir'>/,/<\/'gdir'>/{if(j>1)print x;x=$0;j++}' |awk '/<'verdir'>/,/<\/'verdir'>/{if(jj>1)print x;x=$0;jj++}' |awk -F= '/nfsdir/{print$2}' |tr -d " "`
				NFS_IP=192.168.${sec_IP}.`cat template/${template_file} |awk '/<'gdir'>/,/<\/'gdir'>/{if(k>1)print x;x=$0;k++}' |awk '/<'verdir'>/,/<\/'verdir'>/{if(kk>1)print x;x=$0;kk++}' |awk -F= '/IP/{print$2}' |tr -d " "`
				all_server=`cat template/${template_file} |awk '/<'PHY_SERVER'>/,/<\/'PHY_SERVER'>/{if(i>1)print x;x=$0;i++}' |awk -F= '/ALL_server/{print$2}'|tr -d "\r"`
				Array_server=${all_server}

#				echo -e "\n��鿴��־�ļ�=== $TMP_path/stop_mta_${current_time}_[BJBGP20_GS01].log ===[ ]�ڱ�ʾ��Ӧ���������\n"

				printf "%-27sMTA�رս����" "$name_server""($path_server)"

				for j in ${Array_server[@]}
				do
					read -u9	##�ڲ�����ʱ��
					{			##�ڲ�����ʱ��

#					echo "j=$j"
					path_upload=`cat template/${template_file} |awk '/<'gserver'>/,/<\/'gserver'>/{if(i>1)print x;x=$0;i++}' |awk '/<'MTA'>/,/<\/'MTA'>/{if(ii>1)print x;x=$0;ii++}' |awk -F= '/path/{print$2}' |tr -d " "`
					ip_mta=192.168.${sec_IP}.`cat template/${template_file} |awk '/<'gserver'>/,/<\/'gserver'>/{if(i>1)print x;x=$0;i++}' |awk -v j="$j" '/<'$j'>/,/<\/'$j'>/{if(jj>1)print x;x=$0;jj++}' |awk -F= '/IP/{print$2}' |tr -d " "`

#					echo -e "path_upload=$path_upload"
#					echo -e "ip_mta=$ip_mta"
#						num_thread=${TYPE_thread}${j}
						mta_stop $ip_mta $j $current_time

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
        stop_mta
fi
}

stop_mta
