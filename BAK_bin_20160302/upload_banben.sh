#!/bin/sh

#### 上传版本函数 ####

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

#### 删除旧版本 ####
function del_old_banben ()
{
	path_banben=$1
	NFS_IP=$2
	NFS_path=$3
	name_banben=$4
	name_server=$5
	path_server=$6

	if [ $# -eq 6 ];then
		echo -e "请查看日志文件:==== $TMP_path/upload_banben_${path_server}_${name_server}.log ===="
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

#### 解压新版本 ####
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

#### 验证版本 MD5 函数 ####
function check_banben ()
{
	NFS_IP=$1
	NFS_path=$2
	name_banben=$3
	md5_local_banben=$4

	if [ $# -eq 5 ];then	##md5sum命令结果中间有空格，所以会多一个入参，即$5
		expect expect/check_banben.exp $NFS_IP $NFS_path $name_banben >> $TMP_path/upload_banben_${path_server}_${name_server}.log 2>&1
	###	md5_remote_banben=`sed -n "/md5sum/{n;p}" $TMP_path/upload_banben_${path_server}_${name_server}.log |awk '{print $1}'`######山竹修改于20150930#########
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

#### 检查本地版本包路径 ####

function file_banben ()
{
echo -e "请输入要上传的版本路径(绝对路径):\n"
echo -e ">>\c"
read path_banben
name_banben=`basename $path_banben`
##echo $name_banben
##echo -e "确认请按Y or y:"
##read choiceY
##if [ ${choiceY} == "Y" -o ${choiceY} == "y" ];then
##	continue;
##fi

if [ -f $path_banben ];then

	md5_local_banben=`md5sum $path_banben`
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
		NFS_IP=`echo $SERVER |awk -F, '{print $4}'`
		template_file=`ls template/ |grep "_${TYPE_moban}_" |grep -E "xml$" |grep -E "^template"`   ##匹配模板文件，比如31模板
		NFS_path=`cat template/${template_file} |awk '/<'gdir'>/,/<\/'gdir'>/{if(j>1)print x;x=$0;j++}' |awk '/<'verdir'>/,/<\/'verdir'>/{if(jj>1)print x;x=$0;jj++}' |awk -F= '/nfsdir/{print$2}' |tr -d " "`
#		NFS_IP=192.168.${sec_IP}.`cat template/${template_file} |awk '/<'gdir'>/,/<\/'gdir'>/{if(k>1)print x;x=$0;k++}' |awk '/<'verdir'>/,/<\/'verdir'>/{if(kk>1)print x;x=$0;kk++}' |awk -F= '/IP/{print$2}' |tr -d " "`
#		NFS_IP=${sec_IP}.`cat template/${template_file} |awk '/<'gdir'>/,/<\/'gdir'>/{if(k>1)print x;x=$0;k++}' |awk '/<'verdir'>/,/<\/'verdir'>/{if(kk>1)print x;x=$0;kk++}' |awk -F= '/IP/{print$2}' |tr -d " "`

		del_old_banben $path_banben $NFS_IP $NFS_path $name_banben $name_server $path_server
		ret=$?
		if [ $ret -eq 0 ];then
			printf "%-20s: \033[40;32m旧版本删除成功!\033[0m\n" $name_server  ##删除旧版本成功返回绿色
		else
			printf "%-20s: \033[40;31m旧版本删除失败!\033[0m\n" $name_server  ##删除旧版本成功返回红色
		fi
		if [ $ret -eq 0 ];then
			upload_banben $path_banben $NFS_IP $NFS_path $name_banben $name_server $path_server
			ret=$?
			if [ $ret -eq 0 ];then
				printf "%-20s: \033[40;32m新版本上传成功! \033[0m\n" $name_server	##新版本上传成功返回绿色
			else
				printf "%-20s: \033[40;31m新版本上传失败! \033[0m\n" $name_server	##新版本上传失败返回红色
			fi
			if [ $ret -eq 0 ];then
				check_banben $NFS_IP $NFS_path $name_banben ${md5_local_banben}
				ret=$?
				if [ $ret -eq 0 ];then
					printf "%-20s: \033[40;32mMD5 OK!!!!\033[0m\n" $name_server	##版本MD5检查成功返回绿色
				else
					printf "%-20s: \033[40;31mMD5 ERROR!\033[0m\n" $name_server	##版本MD5检查失败返回红色
				fi
			fi
			if [ $ret -eq 0 ];then
				unzip_banben $path_banben $NFS_IP $NFS_path $name_banben $name_server $path_server
				printf "%-20s: \033[40;32m解压成功! \033[0m\n" $name_server    ##解压成功返回绿色
			fi
		fi

		echo >&9    ##
		}&  ##

	done

	wait    ##
	echo    ##行尾打印服名
	exec 9>&-   ##

else
	echo -e "版本文件不存在!!!"
	echo
	file_banben
fi
}

file_banben
