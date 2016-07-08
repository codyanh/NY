#!/bin/sh

#### �ϴ��汾���� ####

function upload_banben ()
{
	path_banben=$1
	NFS_IP=$2
	NFS_path=$3
	name_banben=$4
	name_server=$5
	path_server=$6

	if [ $# -eq 6 ];then
		expect expect/scp_banben.exp $path_banben $NFS_IP $NFS_path $name_banben >> $TMP_path/upload_banben_${path_server}_${name_server}.log 2>&1
		sleep 1
		if grep -q "upload banben OK 100%" $TMP_path/upload_banben_${path_server}_${name_server}.log ;then
			return 0
		else
			return 1
		fi
	else
		echo -e "2Parameter Number Error!!!\r"
	fi
}

#### ɾ���ɰ汾 ####
function del_old_banben ()
{
	path_banben=$1
	NFS_IP=$2
	NFS_path=$3
	name_banben=$4
	name_server=$5
	path_server=$6

	if [ $# -eq 6 ];then
		echo -e "��鿴��־�ļ�:==== $TMP_path/upload_banben_${path_server}_${name_server}.log ===="
		expect expect/del_old_banben.exp $path_banben $NFS_IP $NFS_path $name_banben $command_ls> $TMP_path/upload_banben_${path_server}_${name_server}.log 2>&1
		sleep 1
		if grep -q "No File Exist : total 0" $TMP_path/upload_banben_${path_server}_${name_server}.log ;then
			return 0
		else
			return 1
		fi
	else
		echo -e "3Parameter Number Error!!!\r"
	fi
}

#### ��ѹ�°汾 ####
function unzip_banben ()
{
	path_banben=$1
	NFS_IP=$2
	NFS_path=$3
	name_banben=$4
	name_server=$5
	path_server=$6

	expect expect/unzip_banben.exp $path_banben $NFS_IP $NFS_path $name_banben >> $TMP_path/upload_banben_${path_server}_${name_server}.log 2>&1
}

#### ��֤�汾 MD5 ���� ####
function check_banben ()
{
	NFS_IP=$1
	NFS_path=$2
	name_banben=$3
	md5_local_banben=$4

	if [ $# -eq 5 ];then	##md5sum�������м��пո����Ի��һ����Σ���$5
		expect expect/check_banben.exp $NFS_IP $NFS_path $name_banben >> $TMP_path/upload_banben_${path_server}_${name_server}.log 2>&1
	###	md5_remote_banben=`sed -n "/md5sum/{n;p}" $TMP_path/upload_banben_${path_server}_${name_server}.log |awk '{print $1}'`######ɽ���޸���20150930#########
		md5_remote_banben=`sed -n "/md5sum/{n;p}" $TMP_path/upload_banben_${path_server}_${name_server}.log |awk '{if($2~/mnt/){print $1}}'`

		sleep 1
		if [ ${md5_local_banben} = ${md5_remote_banben} ];then
			return 0
		else
			return 1
		fi
	else
		echo -e "4Parameter Number Error!!!\r"
	fi
}

#### ��鱾�ذ汾��·�� ####

function file_banben ()
{
echo -e "������Ҫ�ϴ��İ汾·��(����·��):\n"
echo -e ">>\c"
read path_banben
name_banben=`basename $path_banben`
##echo $name_banben
##echo -e "ȷ���밴Y or y:"
##read choiceY
##if [ ${choiceY} == "Y" -o ${choiceY} == "y" ];then
##	continue;
##fi

if [ -f $path_banben ];then

	md5_local_banben=`md5sum $path_banben`
	server_number=`cat $TMP_path/choice_server1.csv | wc -l`

##############################################
#### ���forѭ�� #### ����ִ�� #### ͬʱ�����
#
	temp_fifo_file=$$.info  ##�Ե�ǰ���̺ţ�Ϊ��ʱ�ܵ�ȡ��
	mkfifo $temp_fifo_file  ##������ʱ�ܵ�
	exec 9<>$temp_fifo_file ##������ʶΪ9�����ԶԹܵ����ж�д
	rm $temp_fifo_file      ##��չܵ�����
	temp_thread=3           ##����������
	for ((ii=0;ii<$temp_thread;ii++))   ##Ϊ���̴�����Ӧ��ռλ
	do
		echo                ##ÿ��echo���һ���س���Ϊÿ�����̴���һ��ռλ
	done >&9                ##��ռλ��Ϣд���ʶΪ9�Ĺܵ�
#
##############################################

	for i in `seq 1 $server_number`
	do
		read -u9    ##�������ʱ��
		{           ##�������ʱ��

		SERVER=`sed -n "$i"p $TMP_path/choice_server1.csv`
		path_server=`echo $SERVER |awk -F, '{print $1}'`
		name_server=`echo $SERVER |awk -F, '{print $2}'`
		TYPE_moban=`echo $SERVER |awk -F, '{print $3}'`
		sec_IP=`echo $SERVER |awk -F, '{print $5}'`
		NFS_IP=`echo $SERVER |awk -F, '{print $4}'`
		template_file=`ls template/ |grep "_${TYPE_moban}_" |grep -E "xml$" |grep -E "^template"`   ##ƥ��ģ���ļ�������31ģ��
		NFS_path=`cat template/${template_file} |awk '/<'gdir'>/,/<\/'gdir'>/{if(j>1)print x;x=$0;j++}' |awk '/<'verdir'>/,/<\/'verdir'>/{if(jj>1)print x;x=$0;jj++}' |awk -F= '/nfsdir/{print$2}' |tr -d " "`
#		NFS_IP=192.168.${sec_IP}.`cat template/${template_file} |awk '/<'gdir'>/,/<\/'gdir'>/{if(k>1)print x;x=$0;k++}' |awk '/<'verdir'>/,/<\/'verdir'>/{if(kk>1)print x;x=$0;kk++}' |awk -F= '/IP/{print$2}' |tr -d " "`
#		NFS_IP=${sec_IP}.`cat template/${template_file} |awk '/<'gdir'>/,/<\/'gdir'>/{if(k>1)print x;x=$0;k++}' |awk '/<'verdir'>/,/<\/'verdir'>/{if(kk>1)print x;x=$0;kk++}' |awk -F= '/IP/{print$2}' |tr -d " "`

		del_old_banben $path_banben $NFS_IP $NFS_path $name_banben $name_server $path_server
		ret=$?
		if [ $ret -eq 0 ];then
			printf "%-20s: \033[40;32m�ɰ汾ɾ���ɹ�!\033[0m\n" $name_server  ##ɾ���ɰ汾�ɹ�������ɫ
		else
			printf "%-20s: \033[40;31m�ɰ汾ɾ��ʧ��!\033[0m\n" $name_server  ##ɾ���ɰ汾�ɹ����غ�ɫ
		fi
		if [ $ret -eq 0 ];then
			upload_banben $path_banben $NFS_IP $NFS_path $name_banben $name_server $path_server
			ret=$?
			if [ $ret -eq 0 ];then
				printf "%-20s: \033[40;32m�°汾�ϴ��ɹ�! \033[0m\n" $name_server	##�°汾�ϴ��ɹ�������ɫ
			else
				printf "%-20s: \033[40;31m�°汾�ϴ�ʧ��! \033[0m\n" $name_server	##�°汾�ϴ�ʧ�ܷ��غ�ɫ
			fi
			if [ $ret -eq 0 ];then
				check_banben $NFS_IP $NFS_path $name_banben ${md5_local_banben}
				ret=$?
				if [ $ret -eq 0 ];then
					printf "%-20s: \033[40;32mMD5 OK!!!!\033[0m\n" $name_server	##�汾MD5���ɹ�������ɫ
				else
					printf "%-20s: \033[40;31mMD5 ERROR!\033[0m\n" $name_server	##�汾MD5���ʧ�ܷ��غ�ɫ
				fi
			fi
			if [ $ret -eq 0 ];then
				unzip_banben $path_banben $NFS_IP $NFS_path $name_banben $name_server $path_server
				printf "%-20s: \033[40;32m��ѹ�ɹ�! \033[0m\n" $name_server    ##��ѹ�ɹ�������ɫ
			fi
		fi

		echo >&9    ##
		}&  ##

	done

	wait    ##
	echo    ##��β��ӡ����
	exec 9>&-   ##

else
	echo -e "�汾�ļ�������!!!"
	echo
	file_banben
fi
}

file_banben
