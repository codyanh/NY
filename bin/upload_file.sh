#!/bin/sh

#### 上传文件函数 (GS/BCS) ####

function file_upload_GS ()
{
	path_file=$1
	ip_upload=$2
	path_upload=$3
	path_server=$4
	name_server=$5
	num_thread=$6
	number_j=$7

	if [ $number_j == 1 ];then
		expect expect/scp_file.exp $path_file $ip_upload $path_upload $number_j> $TMP_path/upload_file_${path_server}_${name_server}.log 2>&1
	else
		expect expect/scp_file.exp $path_file $ip_upload $path_upload $number_j>> $TMP_path/upload_file_${path_server}_${name_server}.log 2>&1
	fi

	if grep -q "$number_j OK 100%" $TMP_path/upload_file_${path_server}_${name_server}.log ;then
		return 0
	else
		return 1
	fi
}

#### 上传文件函数 (LS/DBS/CCS/DBI/DBM/BLOB/APEX...) ####

function file_upload_LS ()
{
	path_file=$1
	ip_upload=$2
	path_upload=$3
	path_server=$4
	name_server=$5
	TYPE_thread=$6
	if [ $# -eq 6 ];then
#		expect expect/scp_file_LS.exp $path_file $ip_upload $path_upload $TYPE_thread > $TMP_path/upload_file_${path_server}_${name_server}.log 2>&1
		expect expect/scp_file.exp $path_file $ip_upload $path_upload $TYPE_thread > $TMP_path/upload_file_${path_server}_${name_server}.log 2>&1

		if grep -q "$TYPE_thread OK 100%" $TMP_path/upload_file_${path_server}_${name_server}.log ;then
			return 0
		else
			return 1
		fi
	else
		echo -e "6Parameter Number Error!!!\r"
	fi
}

#### 检查本地版本包路径 ####

function file_local ()
{
echo -e "请输入要上传的文件:\n"
echo -e ">>\c"
read path_file
name_file=`basename $path_file`
server_number=`cat $TMP_path/choice_server1.csv | wc -l`

if [ -f $path_file ];then
		echo
		echo -e "选择上传选项，如下："
		echo -e "GS   （ 提示：/home/FS_serverX/GS[1..16]/ ）"
		echo -e "BCS  （ 提示：/home/FS_serverX/BCS[1..16]/ ）"
		echo -e "LS   （ 提示：/home/FS_serverX/LS/ ）"
		echo -e "CCS  （ 提示：/home/FS_serverX/CCS/ ）"
		echo -e "DBS  （ 提示：/home/FS_serverX/DBS/ ）"
		echo -e "DBM  （ 提示：/home/FS_serverX/DBM/ ）"
		echo -e "DBI  （ 提示：/home/FS_serverX/DBI/ ）"
		echo -e "APEX （ 提示：/home/svrX/ax_update/ ）"
		echo -e "NFSDIR（提示：/mnt/serverX/）"
		echo -e "MTA  （提示：/home/MT_agent/）"
		echo
		echo -e ">>\c"
		read TYPE_thread
		
		case $TYPE_thread in

		GS|BCS)
#        	server_number=`cat $TMP_path/choice_server1.csv | wc -l`
			echo -e "请输入要上传的路径，进程根目录请直接回车"
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
##############################################
#### 外层for循环 #### 并行执行 #### 同时多个服
#
#			temp_fifo_file=$$.info	##以当前进程号，为临时管道取名
#			mkfifo $temp_fifo_file	##创建临时管道
#			exec 9<>$temp_fifo_file	##创建标识为9，可以对管道进行读写
#			rm $temp_fifo_file		##清空管道内容
#			temp_thread=6			##并发进程数
#			for ((ii=0;ii<$temp_thread;ii++))	##为进程创建相应的占位
#			do
#				echo				##每个echo输出一个回车，为每个进程创建一个占位
#			done >&9				##将占位信息写入标识为9的管道
#
##############################################
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
#				read -u9	##外层多进程时打开
#				{			##外层多进程时打开
				SERVER=`sed -n "$i"p $TMP_path/choice_server1.csv`
				path_server=`echo $SERVER |awk -F, '{print $1}'`
				name_server=`echo $SERVER |awk -F, '{print $2}'`
				TYPE_moban=`echo $SERVER |awk -F, '{print $3}'`
				sec_IP=`echo $SERVER |awk -F, '{print $5}'`
				Ser1_IP=`echo $SERVER |awk -F, '{print $4}' |awk -F. '{print $4}'`
				template_file=`ls template/ |grep "_${TYPE_moban}_" |grep -E "xml$" |grep -E "^template"`	##匹配模板文件，比如31模板
				thread_number=`cat template/${template_file} |grep -E "<${TYPE_thread}[1-9]*>" |grep -o [0-9]* |uniq |sort -n |tail -n 1`
				printf "%-20s上传结果：" "$name_server"

				for j in `seq 1 $thread_number`
				do
					read -u9	##内层多进程时打开
					{			##内层多进程时打开

#					path_upload=/home/FS_server/${TYPE_thread}${j}/${path_XD}/	##已不用此办法
					path_upload=`cat template/${template_file} |awk '/<'gmod'>/,/<\/'gmod'>/{if(i>1)print x;x=$0;i++}' |awk -v TYPE_thread="$TYPE_thread" -v j="$j" '/<'$TYPE_thread''$j'>/,/<\/'$TYPE_thread''$j'>/{if(i>1)print x;x=$0;i++}' |awk -F= '/path/{print$2}' |tr -d " "`/${path_XD}/
					num_thread=${TYPE_thread}${j}
#					ip_upload=${sec_IP}.`cat template/${template_file} |awk '/<'gmod'>/,/<\/'gmod'>/{if(i>1)print x;x=$0;i++}' |awk -v TYPE_thread="$TYPE_thread" -v j="$j" '/<'$TYPE_thread''$j'>/,/<\/'$TYPE_thread''$j'>/{if(i>1)print x;x=$0;i++}' |awk -F= '/IP/{print$2}' |tr -d " "`

					if [ $TYPE_moban == AliYun11 ];then
						if [ $j -le 5 ];then
							let ip_upload_4th=$Ser1_IP+0
						elif [ $j -le 10 ];then
							let ip_upload_4th=$Ser1_IP+1
						else
							let ip_upload_4th=$Ser1_IP+2
						fi
						ip_upload=${sec_IP}.${ip_upload_4th}
					else
						ip_upload=${sec_IP}.`cat template/${template_file} |awk '/<'gmod'>/,/<\/'gmod'>/{if(i>1)print x;x=$0;i++}' |awk -v TYPE_thread="$TYPE_thread" -v j="$j" '/<'$TYPE_thread''$j'>/,/<\/'$TYPE_thread''$j'>/{if(i>1)print x;x=$0;i++}' |awk -F= '/IP/{print$2}' |tr -d " "`
					fi

					file_upload_GS $path_file $ip_upload $path_upload $path_server $name_server $num_thread $j
					ret=$?

					if [ $ret -eq 0 ];then
						echo -e "\033[40;32m$num_thread \033[0m\c"	##上传成功返回绿色
					else
						echo -e "\033[40;31m$num_thread \033[0m\c"	##上传失败返回红色
					fi
				echo >&9
				}&

				done

				wait	##
				echo	##行尾打印服名
				exec 9>&-	##

#			}&
			done
#			wait
#			exec 9>&- 
		;;
		LS|DBS|DBI|DBM|BLOB|APEX)
#        	server_number=`cat $TMP_path/choice_server1.csv | wc -l`
			echo -e "请输入要上传的路径，进程根目录请直接回车"
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
##############################################
#### 外层for循环 #### 并行执行 #### 同时多个服
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
			echo -e "正在上传中....."
			for i in `seq 1 $server_number`
			do
				read -u9	##外层多进程时打开
				{			##外层多进程时打开

				SERVER=`sed -n "$i"p $TMP_path/choice_server1.csv`
				path_server=`echo $SERVER |awk -F, '{print $1}'`
				name_server=`echo $SERVER |awk -F, '{print $2}'`
				TYPE_moban=`echo $SERVER |awk -F, '{print $3}'`
				sec_IP=`echo $SERVER |awk -F, '{print $5}'`
				Ser1_IP=`echo $SERVER |awk -F, '{print $4}' |awk -F. '{print $4}'`
				template_file=`ls template/ |grep "_${TYPE_moban}_" |grep -E "xml$" |grep -E "^template"`	##匹配模板文件，比如31模板
				path_upload=`cat template/${template_file} |awk '/<'gmod'>/,/<\/'gmod'>/{if(j>1)print x;x=$0;j++}' |awk -v TYPE_thread="$TYPE_thread" '/<'$TYPE_thread'>/,/<\/'$TYPE_thread'>/{if(j>1)print x;x=$0;j++}' |awk -F= '/path/{print$2}' |tr -d " "`/${path_XD}/
				num_thread=${TYPE_thread}
#				ip_upload=${sec_IP}.`cat template/${template_file} |awk '/<'gmod'>/,/<\/'gmod'>/{if(j>1)print x;x=$0;j++}' |awk -v TYPE_thread="$TYPE_thread" '/<'$TYPE_thread'>/,/<\/'$TYPE_thread'>/{if(j>1)print x;x=$0;j++}' |awk -F= '/IP/{print$2}' |tr -d " "`
				if [ $path_server == "ALI-HZ-NY-100" ];then
					ip_upload=${sec_IP}.26
					echo -e "ip_upload=$ip_upload"
				elif [ $TYPE_moban == AliYun11 ];then
					let ip_upload_4th=$Ser1_IP+2
					ip_upload=${sec_IP}.${ip_upload_4th}
				else
					ip_upload=${sec_IP}.`cat template/${template_file} |awk '/<'gmod'>/,/<\/'gmod'>/{if(j>1)print x;x=$0;j++}' |awk -v TYPE_thread="$TYPE_thread" '/<'$TYPE_thread'>/,/<\/'$TYPE_thread'>/{if(j>1)print x;x=$0;j++}' |awk -F= '/IP/{print$2}' |tr -d " "`
				fi
				file_upload_LS $path_file $ip_upload $path_upload $path_server $name_server $TYPE_thread
				ret=$?

					if [ $ret -eq 0 ];then
						printf "%-20s上传结果： \033[40;32m$num_thread \033[0m\n" $name_server	##上传成功返回绿色
					else
						printf "%-20s上传结果： \033[40;31m$num_thread \033[0m\n" $name_server	##上传失败返回红色
					fi
					
				echo >&9	##
				}&	##

			done

			wait	##
			echo	##行尾打印服名
			exec 9>&-	##

		;;
		CCS)
#        	server_number=`cat $TMP_path/choice_server1.csv | wc -l`
			echo -e "请输入要上传的路径，进程根目录请直接回车"
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
##############################################
#### 外层for循环 #### 并行执行 #### 同时多个服
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
			echo -e "正在上传中....."
			for i in `seq 1 $server_number`
			do
				read -u9	##外层多进程时打开
				{			##外层多进程时打开

				SERVER=`sed -n "$i"p $TMP_path/choice_server1.csv`
				path_server=`echo $SERVER |awk -F, '{print $1}'`
				name_server=`echo $SERVER |awk -F, '{print $2}'`
				TYPE_moban=`echo $SERVER |awk -F, '{print $3}'`
				sec_IP=`echo $SERVER |awk -F, '{print $5}'`
				Ser1_IP=`echo $SERVER |awk -F, '{print $4}' |awk -F. '{print $4}'`
				template_file=`ls template/ |grep "_${TYPE_moban}_" |grep -E "xml$" |grep -E "^template"`	##匹配模板文件，比如31模板
				path_upload=`cat template/${template_file} |awk '/<'gmod'>/,/<\/'gmod'>/{if(j>1)print x;x=$0;j++}' |awk -v TYPE_thread="$TYPE_thread" '/<'$TYPE_thread'>/,/<\/'$TYPE_thread'>/{if(j>1)print x;x=$0;j++}' |awk -F= '/path/{print$2}' |tr -d " "`/${path_XD}/
				num_thread=${TYPE_thread}
#				ip_upload=${sec_IP}.`cat template/${template_file} |awk '/<'gmod'>/,/<\/'gmod'>/{if(j>1)print x;x=$0;j++}' |awk -v TYPE_thread="$TYPE_thread" '/<'$TYPE_thread'>/,/<\/'$TYPE_thread'>/{if(j>1)print x;x=$0;j++}' |awk -F= '/IP/{print$2}' |tr -d " "`

				if [ $TYPE_moban == AliYun11 ];then
					let ip_upload_4th=$Ser1_IP+1
					ip_upload=${sec_IP}.${ip_upload_4th}
				else
					ip_upload=${sec_IP}.`cat template/${template_file} |awk '/<'gmod'>/,/<\/'gmod'>/{if(j>1)print x;x=$0;j++}' |awk -v TYPE_thread="$TYPE_thread" '/<'$TYPE_thread'>/,/<\/'$TYPE_thread'>/{if(j>1)print x;x=$0;j++}' |awk -F= '/IP/{print$2}' |tr -d " "`
				fi
				file_upload_LS $path_file $ip_upload $path_upload $path_server $name_server $TYPE_thread
				ret=$?

					if [ $ret -eq 0 ];then
						printf "%-20s上传结果： \033[40;32m$num_thread \033[0m\n" $name_server	##上传成功返回绿色
					else
						printf "%-20s上传结果： \033[40;31m$num_thread \033[0m\n" $name_server	##上传失败返回红色
					fi
					
				echo >&9	##
				}&	##

			done

			wait	##
			echo	##行尾打印服名
			exec 9>&-	##

		;;
		dbs)
			echo "DBS"
		;;
		dbm)
			echo "DBM"
		;;
		dbi)
			echo "DBI"
		;;
		apex)
			echo "APEX"
		;;
		nfsdir)
			echo "NFS"
		;;
		nfsdir)
			echo "MTA"
		;;
		esac

else
        echo -e "版本文件不存在!!!"
        echo
        file_local
fi
}

file_local
