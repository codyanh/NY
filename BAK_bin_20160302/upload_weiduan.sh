#!/bin/sh

#### 上传微端函数 ####

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

#### 解压新版本 ####
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

#### 验证版本 MD5 函数 ####
function check_weiduan ()
{
	NFS_IP=$1
	NFS_path=$2
	name_weiduan=$3
	md5_local_weiduan=$4

	if [ $# -eq 5 ];then	##md5sum命令结果中间有空格，所以会多一个入参，即$5
		expect expect/check_banben.exp $NFS_IP $NFS_path $name_weiduan >> $TMP_path/upload_weiduan_${path_server}_${name_server}.log 2>&1
	###	md5_remote_weiduan=`sed -n "/md5sum/{n;p}" $TMP_path/upload_weiduan_${path_server}_${name_server}.log |awk '{print $1}'`######山竹修改于20150930#########
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

#### 检查本地版本包路径 ####

function file_weiduan ()
{

echo -e "请输入要上传的微端路径(邮件里地址):\n"
echo -e ">>\c"
# read webpath_weiduan
  read name_weiduan
#/usr/bin/smbclient -c "get weiduan\cacti cacti"  //192.168.10.186/mofei/ -U mofei%MAmachaofan31
#/usr/bin/smbclient -c "get \\192.168.1.247\X-gameClient\微端相关\3.00.413"  //192.168.1.247// -U mofei%MAmachaofan31
sudo umount /mnt/nuoya/weiduan/
sudo mount -t smbfs //192.168.10.186/mofei/ /mnt/nuoya/weiduan/ -o iocharset=utf8,username=mofei,password=MAmachaofan31
pwd
echo "==============="
zip -r $TMP_path$name_weiduan.zip /mnt/nuoya/weiduan/weiduan/CompressedWDF

#name_weiduan=`basename $path_weiduan`
##echo $name_weiduan
##echo -e "确认请按Y or y:"
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
				printf "%-20s: \033[40;32m新版本上传成功! \033[0m\n" $name_server	##新版本上传成功返回绿色
			else
				printf "%-20s: \033[40;31m新版本上传失败! \033[0m\n" $name_server	##新版本上传失败返回红色
			fi
			if [ $ret -eq 0 ];then
				check_weiduan $NFS_IP $NFS_path $name_weiduan ${md5_local_weiduan}
				ret=$?
				if [ $ret -eq 0 ];then
					printf "%-20s: \033[40;32mMD5 OK!!!!\033[0m\n" $name_server	##版本MD5检查成功返回绿色
				else
					printf "%-20s: \033[40;31mMD5 ERROR!\033[0m\n" $name_server	##版本MD5检查失败返回红色
				fi
			fi
			if [ $ret -eq 0 ];then
				unzip_weiduan $path_weiduan $NFS_IP $NFS_path $name_weiduan $name_server $path_server
				printf "%-20s: \033[40;32m解压成功! \033[0m\n" $name_server    ##解压成功返回绿色
			fi


else
	echo -e "版本文件不存在!!!"
	echo
	file_weiduan
fi
}

file_weiduan
