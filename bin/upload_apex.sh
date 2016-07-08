#!/bin/sh

function file_upload_apex ()
{
	ip_upload=$1
	path_upload=$2
	name_server=$3
	if [ $# -eq 3 ];then
		expect expect/scp_downapex.exp  $ip_upload $path_upload $name_server > $TMP_path/upload_file_${path_server}_${name_server}.log 2>&1
	else
		echo -e "3Parameter Number Error!!!\r"
	fi
}

#### 检查本地版本包路径 ####

function apex_local ()
{
echo -e "请输入要上传的文件:\n"
echo -e ">>\c"

		echo
		echo -e "确认下载选项，如下："
		
		echo -e "提取APEX （ 提示：/home/svrX/ax_update/../hook_log ）"
		echo

			echo -e "请输入要上传的路径，进程根目录请直接回车"
			echo -e ">>\c"
					
				SERVER=`sed -n 1p $TMP_path/choice_server1.csv`
				path_server=`echo $SERVER |awk -F, '{print $1}'`
				name_server=`echo $SERVER |awk -F, '{print $2}'`
				TYPE_moban=`echo $SERVER |awk -F, '{print $3}'`
				sec_IP=`echo $SERVER |awk -F, '{print $5}'`
				Ser1_IP=`echo $SERVER |awk -F, '{print $4}' |awk -F. '{print $4}'`
				template_file=`ls template/ |grep "_${TYPE_moban}_" |grep -E "xml$" |grep -E "^template"`	##匹配模板文件，比如31模板
				path_upload=`cat template/${template_file} |awk '/<'APEX'>/,/<\/'APEX'>/{if(j>1)print x;x=$0;j++}' |awk -F= '/path/{print$2}' |tr -d " "`/../hook_log

#				ip_upload=${sec_IP}.`cat template/${template_file} |awk '/<'gmod'>/,/<\/'gmod'>/{if(j>1)print x;x=$0;j++}' |awk -v TYPE_thread="$TYPE_thread" '/<'$TYPE_thread'>/,/<\/'$TYPE_thread'>/{if(j>1)print x;x=$0;j++}' |awk -F= '/IP/{print$2}' |tr -d " "`
				if [ $path_server == "ALI-HZ-NY-100" ];then
					ip_upload=${sec_IP}.26
					echo -e "ip_upload=$ip_upload"
				elif [ $TYPE_moban == AliYun11 ];then
					let ip_upload_4th=$Ser1_IP+2
					ip_upload=${sec_IP}.${ip_upload_4th}
				else
					ip_upload=${sec_IP}.`cat template/${template_file} |awk '/<'APEX'>/,/<\/'APEX'>/{if(j>1)print x;x=$0;j++}'  |awk -F= '/IP/{print$2}' |tr -d " "`
				fi

				file_upload_apex  $ip_upload $path_upload $path_server $name_server 
				ret=$?

					if [ $ret -eq 0 ];then
						printf "%-20s下载结果： \033[40;32m$num_thread \033[0m\n" $name_server	##上传成功返回绿色
					# else
						printf "%-20s下载结果： \033[40;31m$num_thread \033[0m\n" $name_server	##上传失败返回红色
					fi
					

			echo	##行尾打印服名

}

apex_local
