#!/bin/bash

#### �ϴ�MTA�汾���� ####

function mta_upload ()
{
	path_file=$1
	NFS_IP=$2
	NFS_path=$3
	path_server=$4
	name_server=$5
#	number_j=$6

#	echo -e "path_file=$path_file"
#	echo -e "NFS_IP=$NFS_IP"
#	echo -e "NFS_path=$NFS_path"
#	echo -e "path_server=$path_server"
#	echo -e "name_server=$name_server"

#	if [ $number_j == 1 ];then
#		expect expect/scp_file.exp $path_file $ip_upload $path_upload $number_j> $TMP_path/upload_file_${path_server}_${name_server}.log 2>&1
#	else
#		expect expect/scp_file.exp $path_file $ip_upload $path_upload $number_j>> $TMP_path/upload_file_${path_server}_${name_server}.log 2>&1
#	fi

	expect expect/scp_file.exp $path_file $NFS_IP $NFS_path $number_j> $TMP_path/upload_mta_${path_server}_${name_server}.log 2>&1

#	if grep -q "$number_j OK 100%" $TMP_path/upload_mta_${path_server}_${name_server}.log ;then
		return 0
#	else
#		return 1
#	fi
}

#### ����MTA�汾����ÿ̨�������mta����Ŀ¼�� ####

function mta_copy ()
{
	path_mta_work=$1
	ip_mta=$2
	NFS_path=$3
	name_file=$4
	path_server=$5
	number_j=$6

#	echo -e "path_mta_work=$path_mta_work"
#	echo -e "ip_mta=$ip_mta"
#	echo -e "NFS_path=$NFS_path"
#	echo -e "path_file=$path_file"
#	echo -e "path_server=$path_server"
#	echo -e "number_j=$number_j"

	expect expect/copy_mta.exp $path_mta_work $ip_mta $NFS_path $name_file $number_j> $TMP_path/copy_mta_${path_server}_${number_j}.log 2>&1
	if grep -q "$number_j OK 0nonothing" $TMP_path/copy_mta_${path_server}_${number_j}.log ;then
		return 0
	else
		return 1
	fi

}

#### ��鱾��MTA�汾·�� ####

function file_mta ()
{
echo -e "������Ҫ�ϴ��ı���MTA�汾·����\n"
echo -e ">>\c"
read path_file
name_file=`basename $path_file`
server_number=`cat $TMP_path/choice_server1.csv | wc -l`

if [ -f $path_file ];then
		
			echo -e "������Ҫ�ϴ���·��������/mnt/serverX/�£���ֱ�ӻس�"
			echo -e ">>\c"

			read path_enter
			case $path_enter in
			'^M')
				path_XD=/
			;;
			*)
				path_XD=$path_enter
			;;
			esac

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

				SERVER=`sed -n "$i"p $TMP_path/choice_server1.csv`
				path_server=`echo $SERVER |awk -F, '{print $1}'`
				name_server=`echo $SERVER |awk -F, '{print $2}'`
				TYPE_moban=`echo $SERVER |awk -F, '{print $3}'`
				sec_IP=`echo $SERVER |awk -F, '{print $5}'`
				template_file=`ls template/ |grep "_${TYPE_moban}_" |grep -E "xml$" |grep -E "^template"`   ##ƥ��ģ���ļ�������31ģ��
				NFS_path=`cat template/${template_file} |awk '/<'gdir'>/,/<\/'gdir'>/{if(j>1)print x;x=$0;j++}' |awk '/<'verdir'>/,/<\/'verdir'>/{if(jj>1)print x;x=$0;jj++}' |awk -F= '/nfsdir/{print$2}' |tr -d " "`
				NFS_IP=192.168.${sec_IP}.`cat template/${template_file} |awk '/<'gdir'>/,/<\/'gdir'>/{if(k>1)print x;x=$0;k++}' |awk '/<'verdir'>/,/<\/'verdir'>/{if(kk>1)print x;x=$0;kk++}' |awk -F= '/IP/{print$2}' |tr -d " "`
				all_server=`cat template/${template_file} |awk '/<'PHY_SERVER'>/,/<\/'PHY_SERVER'>/{if(i>1)print x;x=$0;i++}' |awk -F= '/ALL_server/{print$2}'|tr -d "\r"`
				Array_server=${all_server}

				printf "%-20s�ϴ������" "$name_server"
				mta_upload $path_file $NFS_IP $NFS_path $path_server $name_server

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
						mta_copy $path_mta_work $ip_mta $NFS_path $name_file $path_server $j

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
        echo -e "�汾�ļ�������!!!"
        echo
        upload_mta
fi
}

file_mta
