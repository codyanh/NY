#!/bin/sh

#### �ϴ�΢�˺��� ####

function upload_weiduan ()
{
	path_weiduan=$1
	NFS_IP=$2
	NFS_path=$3
	name_weiduan=$4
	name_server=$5
	path_server=$6

	if [ $# -eq 6 ];then
		expect expect/scp_banben.exp $path_weiduan $NFS_IP $NFS_path $name_weiduan >> $TMP_path/upload_weiduan_${path_server}_${name_server}.log 2>&1
		sleep 1
		if grep -q "upload weiduan OK 100%" $TMP_path/upload_weiduan_${path_server}_${name_server}.log ;then
			return 0
		else
			return 1
		fi
	else
		echo -e "2Parameter Number Error!!!\r"
	fi
}

#### ��ѹ�°汾 ####
function unzip_weiduan ()
{
	path_weiduan=$1
	NFS_IP=$2
	NFS_path=$3
	name_weiduan=$4
	name_server=$5
	path_server=$6

	expect expect/unzip_banben.exp $path_weiduan $NFS_IP $NFS_path $name_weiduan >> $TMP_path/upload_weiduan_${path_server}_${name_server}.log 2>&1
}

#### ��֤�汾 MD5 ���� ####
function check_weiduan ()
{
	NFS_IP=$1
	NFS_path=$2
	name_weiduan=$3
	md5_local_weiduan=$4

	if [ $# -eq 5 ];then	##md5sum�������м��пո����Ի��һ����Σ���$5
		expect expect/check_banben.exp $NFS_IP $NFS_path $name_weiduan >> $TMP_path/upload_weiduan_${path_server}_${name_server}.log 2>&1
	###	md5_remote_weiduan=`sed -n "/md5sum/{n;p}" $TMP_path/upload_weiduan_${path_server}_${name_server}.log |awk '{print $1}'`######ɽ���޸���20150930#########
		md5_remote_weiduan=`sed -n "/md5sum/{n;p}" $TMP_path/upload_weiduan_${path_server}_${name_server}.log |awk '{if($2~/mnt/){print $1}}'`

		sleep 1
		if [ ${md5_local_weiduan} = ${md5_remote_weiduan} ];then
			return 0
		else
			return 1
		fi
	else
		echo -e "4Parameter Number Error!!!\r"
	fi
}

#### ��鱾�ذ汾��·�� ####

function file_weiduan ()
{

echo -e "������Ҫ�ϴ���΢��·��(�ʼ����ַ):\n"
echo -e ">>\c"
# read webpath_weiduan
  read name_weiduan
#/usr/bin/smbclient -c "get weiduan\cacti cacti"  //192.168.10.186/mofei/ -U mofei%MAmachaofan31
#/usr/bin/smbclient -c "get \\192.168.1.247\X-gameClient\΢�����\3.00.413"  //192.168.1.247// -U mofei%MAmachaofan31
sudo umount /mnt/nuoya/weiduan/
sudo mount -t smbfs //192.168.10.186/mofei/ /mnt/nuoya/weiduan/ -o iocharset=utf8,username=mofei,password=MAmachaofan31
pwd
echo "==============="
zip -r $TMP_path$name_weiduan.zip /mnt/nuoya/weiduan/weiduan/CompressedWDF

#name_weiduan=`basename $path_weiduan`
##echo $name_weiduan
##echo -e "ȷ���밴Y or y:"
##read choiceY
##if [ ${choiceY} == "Y" -o ${choiceY} == "y" ];then
##	continue;
##fi

if [ -f $path_weiduan ];then

	md5_local_weiduan=`md5sum $path_weiduan`

#		path_weiduan=
		NFS_IP="192.168.135.21"
		SERVER2="192.168.221.53"

#			upload_weiduan $path_weiduan $NFS_IP $NFS_path $name_weiduan $name_server $path_server
			ret=$?
			if [ $ret -eq 0 ];then
				printf "%-20s: \033[40;32m�°汾�ϴ��ɹ�! \033[0m\n" $name_server	##�°汾�ϴ��ɹ�������ɫ
			else
				printf "%-20s: \033[40;31m�°汾�ϴ�ʧ��! \033[0m\n" $name_server	##�°汾�ϴ�ʧ�ܷ��غ�ɫ
			fi
			if [ $ret -eq 0 ];then
				check_weiduan $NFS_IP $NFS_path $name_weiduan ${md5_local_weiduan}
				ret=$?
				if [ $ret -eq 0 ];then
					printf "%-20s: \033[40;32mMD5 OK!!!!\033[0m\n" $name_server	##�汾MD5���ɹ�������ɫ
				else
					printf "%-20s: \033[40;31mMD5 ERROR!\033[0m\n" $name_server	##�汾MD5���ʧ�ܷ��غ�ɫ
				fi
			fi
			if [ $ret -eq 0 ];then
				unzip_weiduan $path_weiduan $NFS_IP $NFS_path $name_weiduan $name_server $path_server
				printf "%-20s: \033[40;32m��ѹ�ɹ�! \033[0m\n" $name_server    ##��ѹ�ɹ�������ɫ
			fi


else
	echo -e "�汾�ļ�������!!!"
	echo
	file_weiduan
fi
}

file_weiduan
