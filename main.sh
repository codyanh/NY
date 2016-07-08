#!/bin/sh
if [ $1=="auto" ];then 
	echo
	echo -e "\033[40;32;5m重启MTS:\033[0m 请选择 w->b"
	echo -e "\033[40;32;5m重启MTA:\033[0m 请选择 w->h"
fi
#cp /home/nycs_mgmt/AppEnv_14X/etc/gamegroup.csv etc/old_gamegroup.csv -rf
#grep -Ev "^#|^$" /home/nycs_mgmt/AppEnv_14X/etc/gamegroup.csv > etc/gamegroup.csv
export TMP_path=tmp/$(date '+%Y%m%d_%H%M%S')
export path_mta_work=/home/MT_agent
export path_mts_work=/home/MT_server
mkdir $TMP_path

choice_menu=""

function menu ()
{
	echo
	echo -e "*******************"
	echo -e "a) 例行维护"
	echo -e "b) 日常操作"
	echo -e "c) CDN相关"
	echo -e "w) 网管维护"
	echo -e "x) 退出"
	echo -e "*******************"
	echo
	echo -e "请选择选项：\c"
	read choice_menu;

	if [ ${choice_menu} == "a" -o ${choice_menu} == "A" ];then
		list_LiXing
	elif [ ${choice_menu} == "b" -o ${choice_menu} == "B" ];then
		list_RiChang
	elif [ ${choice_menu} == "c" -o ${choice_menu} == "C" ];then
		list_CDN
	elif [ ${choice_menu} == "w" -o ${choice_menu} == "W" ];then
		list_MainTain
	elif [ ${choice_menu} == "x" -o ${choice_menu} == "X" ];then
		exit
	else
		echo -e "输入错误,请重新输入..."
		menu
	fi
}

function list_Server ()
{
	echo
	echo -e "*******************"
	echo -e "a) 现网所有服(不包括跨服)"
	echo -e "b) 现网所有服(包括跨服)"
	echo -e "f) 新服"
	echo -e "h) 手选服"
	echo -e "k) 跨服"
	echo -e "r) 返回"
	echo -e "*******************"
	echo
	echo -e "请选择选项：\c"

	read type_servers

	case $type_servers in
	a|A)
		if [ "$(grep -Ev "^#|^$" etc/gamegroup.csv |awk -F, '{print $2}' |sort -k 1 | uniq -d)" ];then                                                        
			repeated_server=`grep -Ev "^#|^$" etc/gamegroup.csv |awk -F, '{print $2}' |sort -k 1 | uniq -d`
			echo -e "\n\033[40;31m!!!!存在相同的服务器名(如下): \033[0m \n$repeated_server"
			list_Server
		else
			grep -Ev "^#|^$|KuaFuZhanChang" etc/gamegroup.csv |awk -F, '{print $2" ("$8")"}'
			choice_number=`grep -Ev "^#|^$|KuaFuZhanChang" etc/gamegroup.csv | wc -l`
			rm -rf $TMP_path/choice_server*.csv
			grep -Ev "^#|^$|KuaFuZhanChang" etc/gamegroup.csv > $TMP_path/choice_server.csv
			echo -e "\n您选择了$choice_number个服，确认请按y: \c"
			read choice
			if [ ${choice} == "Y" -o ${choice} == "y" ];then
#				awk -F, '{print $1","$2","$3","192"."168"."$5","$4}' $TMP_path/choice_server.csv > $TMP_path/choice_server1.csv
				awk -F, '{print $1","$2","$3","$5","$4}' $TMP_path/choice_server.csv > $TMP_path/choice_server1.csv
			else
				echo -e "输入错误,请重新输入..."
				list_Server
			fi
		fi
	;;
	b|B)
		if [ "$(grep -Ev "^#|^$" etc/gamegroup.csv |awk -F, '{print $2}' |sort -k 1 | uniq -d)" ];then                                                        
			repeated_server=`grep -Ev "^#|^$" etc/gamegroup.csv |awk -F, '{print $2}' |sort -k 1 | uniq -d`
			echo -e "\n\033[40;31m!!!!存在相同的服务器名(如下): \033[0m \n$repeated_server"
			list_Server
		else
			grep -Ev "^#|^$" etc/gamegroup.csv |awk -F, '{print $2" ("$8")"}'
			choice_number=`grep -Ev "^#|^$" etc/gamegroup.csv | wc -l`
			rm -rf $TMP_path/choice_server*.csv
			grep -Ev "^#|^$" etc/gamegroup.csv > $TMP_path/choice_server.csv
			echo -e "\n您选择了$choice_number个服，确认请按y: \c"
			read choice
			if [ ${choice} == "Y" -o ${choice} == "y" ];then
				awk -F, '{print $1","$2","$3","$5","$4}' $TMP_path/choice_server.csv > $TMP_path/choice_server1.csv
			else
				echo -e "输入错误,请重新输入..."
				list_Server
			fi
		fi
	;;
	f|F)
		echo -e "New Fu!!!"
	;;
	h|H)
		if [ "$(grep -Ev "^#|^$" etc/gamegroup.csv |awk -F, '{print $2}' |sort -k 1 | uniq -d)" ];then
			repeated_server=`grep -Ev "^#|^$" etc/gamegroup.csv |awk -F, '{print $2}' |sort -k 1 | uniq -d`
			echo -e "\n\033[40;31m!!!!存在相同的服务器名(如下): \033[0m \n$repeated_server"
			list_Server
		else
		grep -Ev "^#|^$" etc/gamegroup.csv |awk -F, 'BEGIN {print "\r"} {print $2" ("$8")"}'
		echo -e "\n请输入服务器,用空格隔开:\n"
		read choice_server
		echo
		rm -rf $TMP_path/choice_server*.csv

		for server in $choice_server
		do
			#echo $choice_server |awk -F '{for (i=1;i<=NR;i++){grep $i  $i}}'
			server_csv=`cat etc/gamegroup.csv | grep -Ev "^#|^$" | grep -w "${server}"`
			echo $server_csv >> $TMP_path/choice_server.csv
		done

		awk -F, '{print $1","$2","$3","$5","$4}' $TMP_path/choice_server.csv > $TMP_path/choice_server1.csv
		#bash bin/upload_banben.sh
		#list_LiXing
		fi
	;;
	k|K)
		echo "Kua Fu"
	;;
	r|R)
		menu
	;;
	*)
		echo -e "输入错误,请重新输入..."
		list_Server
	esac
}

function list_MTA_Server ()
{
	echo
	echo -e "*******************"
	echo -e "a) 现网所有服"
	echo -e "h) 手选服"
	echo -e "r) 返回"
	echo -e "*******************"
	echo
	echo -e "请选择选项：\c"

	read type_servers

	case $type_servers in
	a|A)
		if [ "$(grep -Ev "^#|^$" etc/mta.csv |awk -F: '{print $1}' |sort -k 1 | uniq -d)" ];then
			repeated_server=`grep -Ev "^#|^$" etc/mta.csv |awk -F: '{print $1}' |sort -k 1 | uniq -d`
			echo -e "\n\033[40;31m!!!!存在相同的服务器名(如下): \033[0m \n$repeated_server"
			list_MTA_Server
		else
			GameGroup=`grep -Ev "^#|^$" etc/mta.csv |awk -F: '{print $1}'`
#			for GameGroup_i in ${GameGroup};do
#				echo $GameGroup_i
#				grep ${GameGroup_i} etc/gamegroup.csv |awk -v GameGroup_i="$GameGroup_i" 'BEGIN { FS="," ;ORS="," ;print '$GameGroup_i'} {print $1" ("$8")"} END {printf "\b"" ""\n"}' >> $TMP_path/All_MTA_Server.csv
####			grep -Ev "^#|^$" etc/mta.csv |awk -F: '{print $1" ("$8")"}'
			grep -Ev "^#|^$" etc/mta.csv |awk -F: '{print $1}'
#			done
#			cat $TMP_path/All_MTA_Server.csv
			choice_number=`grep -Ev "^#|^$" etc/mta.csv | wc -l`
			rm -rf $TMP_path/choice_MTA_server*.csv
			grep -Ev "^#|^$" etc/mta.csv > $TMP_path/choice_MTA_server1.csv
			echo -e "\n您选择了$choice_number组服务器，确认请按y: \c"
			read choice
			if [ ${choice} == "Y" -o ${choice} == "y" ];then
				continue
#				awk -F, '{print $1","$2","$3","192"."168"."$5","$4}' $TMP_path/choice_MTA_server.csv > $TMP_path/choice_MTA_server1.csv
#				awk -F: '{print $1}' $TMP_path/choice_MTA_server.csv > $TMP_path/choice_MTA_server1.csv
			else
				echo -e "输入错误,请重新输入..."
				list_MTA_Server
			fi
		fi
	;;
	h|H)
		if [ "$(grep -Ev "^#|^$" etc/mta.csv |awk -F: '{print $1}' |sort -k 1 | uniq -d)" ];then
			repeated_server=`grep -Ev "^#|^$" etc/mta.csv |awk -F: '{print $1}' |sort -k 1 | uniq -d`
			echo -e "\n\033[40;31m!!!!存在相同的服务器名(如下): \033[0m \n$repeated_server"
			list_MTA_Server
		else

			grep -Ev "^#|^$" etc/mta.csv |awk -F: 'BEGIN {print "\r"} {print $1}'
			echo -e "\n请输入服务器,用空格隔开:\n"
			read choice_server
			echo
			rm -rf $TMP_path/choice_MTA_server*.csv

			for server in $choice_server
			do
				#echo $choice_server |awk -F '{for (i=1;i<=NR;i++){grep $i  $i}}'
				server_csv=`cat etc/mta.csv | grep -Ev "^#|^$" | grep -w "${server}"`
				echo $server_csv >> $TMP_path/choice_MTA_server1.csv
			done

#			awk -F, '{print $1","$2","$3","192"."168"."$5","$4}' $TMP_path/choice_MTA_server.csv > $TMP_path/choice_MTA_server1.csv
			#bash bin/upload_banben.sh
			#list_LiXing
		fi
	;;
	r|R)
		menu
	;;
	*)
		echo -e "输入错误,请重新输入..."
		list_MTA_Server
	esac
}

#### 检查项相关 ####

function list_CheckItem ()
{
	echo
	echo -e "*******************"
	echo -e "a) 检查全服防火墙"
	echo -e "b) 检查聚宝楼报警文件(alarm)"
	echo -e "w) 其他"
	echo -e "r) 返回"
	echo -e "*******************"
	echo
	echo -e "请选择选项：\c"
	read choice_menu;

	if [ ${choice_menu} == "a" -o ${choice_menu} == "A" ];then
		echo "ing...."
		list_CheckItem
	elif [ ${choice_menu} == "b" -o ${choice_menu} == "B" ];then
		list_Server
		bash bin/check_jbl.sh
		list_CheckItem
	elif [ ${choice_menu} == "w" -o ${choice_menu} == "W" ];then
		echo "ing..."
		list_CheckItem
	elif [ ${choice_menu} == "r" -o ${choice_menu} == "R" ];then
		list_RiChang
	else
		echo -e "输入错误,请重新输入..."
		list_CheckItem
	fi
}

#### 例行维护相关 ####                                                                                                                                   

function list_LiXing ()
{
	echo
	echo -e "*******************"
	echo -e "a) 上传版本"
	echo -e "b) 开关防火墙"
	echo -e "c) 上传微端资源"
	echo -e "r) 返回"
	echo -e "*******************"
	echo
	echo -e "请选择选项：\c"

	read type_lixing

#### 上传版本 ####

    if [ ${type_lixing} == "a" -o ${type_lixing} == "A" ];then
		list_Server
		bash bin/upload_banben.sh
		menu

#### 开关防火墙 ####

	elif [ ${type_lixing} == "b" -o ${type_lixing} == "B" ];then
		echo "Nothing!!!!"
		list_LiXing

	elif [ ${type_lixing} == "c" -o ${type_lixing} == "C" ];then
		echo "========================================"
		bash bin/upload_weiduan.sh

	elif [ ${type_lixing} == "r" -o ${type_lixing} == "R" ];then
		menu

	else
		echo -e "输入错误,请重新输入..."
		list_LiXing
	fi
}

#### 日常操作相关 ####

function list_RiChang ()
{
	echo
	echo
	echo -e "*******************"
	echo -e "a) 上传文件"
	echo -e "b) 执行动态更新"
	echo -e "c) 下载文件"
	echo -e "d) 运行SSH指令"
	echo -e "e) APEX更新"
	echo -e "f) 检查项"
	echo -e "g) 在线人数"
	echo -e "h) 提取apex日志"
	echo -e "r) 返回"
	echo -e "*******************"
	echo
	echo -e "请选择选项：\c"

	read choice_server
	if [ ${choice_server} == "a" -o ${choice_server} == "A" ];then
#		echo "Nothing!!!"
		list_Server
		bash bin/upload_file.sh
		list_RiChang

	elif [ ${choice_server} == "b" -o ${choice_server} == "B" ];then
		echo "Nothing!!!"

	elif [ ${choice_server} == "c" -o ${choice_server} == "C" ];then
		echo "Nothing!!!"
#		bash bin/download_file.sh
		list_RiChang
	elif [ ${choice_server} == "d" -o ${choice_server} == "D" ];then
		echo "Nothing!!!"
	elif [ ${choice_server} == "e" -o ${choice_server} == "E" ];then
		echo "Nothing!!!"
	elif [ ${choice_server} == "f" -o ${choice_server} == "F" ];then
		list_CheckItem
		list_RiChang
	elif [ ${choice_server} == "g" -o ${choice_server} == "G" ];then
		list_Server
		bash bin/query_online.sh
		list_RiChang
	elif [ ${choice_server} == "h" -o ${choice_server} == "H" ];then
		list_Server
		bash bin/upload_apex.sh
		list_RiChang
	elif [ ${choice_server} == "r" -o ${choice_server} == "R" ];then
		menu
	else
		echo -e "输入错误,请重新输入..."
		list_RiChang
	fi
}

#### CDN相关 ####

function list_CDN ()
{
	echo
	echo -e "*******************"
	echo -e "a) 第一步:下载并修改patch_list.xml,并上传补丁包文件"
	echo -e "b) 第二步:推送patch_list.xml"
	echo -e "c) 第三步:下载并修改server_list.xml,并推送"
	echo -e "q) 返回"
	echo -e "*******************"
	echo
	echo -e "请选择选项：\c"

	read choice_server
	if [ ${choice_server} == "a" -o ${choice_server} == "A" ];then
		bash cdnpush/make_patchlist.sh
		list_CDN
	elif [ ${choice_server} == "b" -o ${choice_server} == "B" ];then
		bash cdnpush/ny_cdnpush_patchlist.sh
		list_CDN
	elif [ ${choice_server} == "c" -o ${choice_server} == "C" ];then
		bash cdnpush/ny_cdnpush_serverlist.sh server_list.xml
		list_CDN
	elif [ ${choice_server} == "q" -o ${choice_server} == "Q" ];then
		menu
	else
		echo -e "输入错误,请重新输入..."
		list_CDN
	fi
}


#### 网管相关 ####

function list_MainTain ()
{
	echo
	echo -e "*******************"
	echo -e "a) 上传MTS版本"
	echo -e "b) 重启MTS"
	echo -e "c) 上传MTA版本"
	echo -e "d) 关闭MTA(不用执行)"
	echo -e "e) 更换MTA版本"
	echo -e "g) 启动MTA"
	echo -e "h) 硬重启MTA"
	echo -e "r) 返回"
	echo -e "*******************"
	echo
	echo -e "请选择选项：\c"

	read choice_server
	if [ ${choice_server} == "a" -o ${choice_server} == "A" ];then
		echo "Nothing!!!"
	elif [ ${choice_server} == "b" -o ${choice_server} == "B" ];then
		echo "===================="
		bash bin/restart_mts.sh
		list_MainTain
	elif [ ${choice_server} == "c" -o ${choice_server} == "C" ];then
#		list_Server
		list_MTA_Server
		bash bin/upload_mta.sh
		list_MainTain
	elif [ ${choice_server} == "d" -o ${choice_server} == "D" ];then
#		list_Server
		list_MTA_Server
		bash bin/restart_new_mta.sh stop
		list_MainTain
	elif [ ${choice_server} == "e" -o ${choice_server} == "E" ];then
#		list_Server
#		bash bin/update_mta.sh
		list_MTA_Server
		bash bin/restart_new_mta.sh replace
		list_MainTain
	elif [ ${choice_server} == "g" -o ${choice_server} == "G" ];then
#		list_Server
#		bash bin/start_mta.sh
		list_MTA_Server
		bash bin/restart_new_mta.sh start
		list_MainTain
	elif [ ${choice_server} == "h" -o ${choice_server} == "H" ];then
		list_MTA_Server
		bash bin/restart_new_mta.sh restart
		list_MainTain
	elif [ ${choice_server} == "r" -o ${choice_server} == "R" ];then
		menu
	else
		echo -e "输入错误,请重新输入..."
		list_MainTain
	fi
	
}

menu
