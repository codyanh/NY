#!/bin/sh
if [ $1=="auto" ];then 
	echo
	echo -e "\033[40;32;5m����MTS:\033[0m ��ѡ�� w->b"
	echo -e "\033[40;32;5m����MTA:\033[0m ��ѡ�� w->h"
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
	echo -e "a) ����ά��"
	echo -e "b) �ճ�����"
	echo -e "c) CDN���"
	echo -e "w) ����ά��"
	echo -e "x) �˳�"
	echo -e "*******************"
	echo
	echo -e "��ѡ��ѡ�\c"
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
		echo -e "�������,����������..."
		menu
	fi
}

function list_Server ()
{
	echo
	echo -e "*******************"
	echo -e "a) �������з�(���������)"
	echo -e "b) �������з�(�������)"
	echo -e "f) �·�"
	echo -e "h) ��ѡ��"
	echo -e "k) ���"
	echo -e "r) ����"
	echo -e "*******************"
	echo
	echo -e "��ѡ��ѡ�\c"

	read type_servers

	case $type_servers in
	a|A)
		if [ "$(grep -Ev "^#|^$" etc/gamegroup.csv |awk -F, '{print $2}' |sort -k 1 | uniq -d)" ];then                                                        
			repeated_server=`grep -Ev "^#|^$" etc/gamegroup.csv |awk -F, '{print $2}' |sort -k 1 | uniq -d`
			echo -e "\n\033[40;31m!!!!������ͬ�ķ�������(����): \033[0m \n$repeated_server"
			list_Server
		else
			grep -Ev "^#|^$|KuaFuZhanChang" etc/gamegroup.csv |awk -F, '{print $2" ("$8")"}'
			choice_number=`grep -Ev "^#|^$|KuaFuZhanChang" etc/gamegroup.csv | wc -l`
			rm -rf $TMP_path/choice_server*.csv
			grep -Ev "^#|^$|KuaFuZhanChang" etc/gamegroup.csv > $TMP_path/choice_server.csv
			echo -e "\n��ѡ����$choice_number������ȷ���밴y: \c"
			read choice
			if [ ${choice} == "Y" -o ${choice} == "y" ];then
#				awk -F, '{print $1","$2","$3","192"."168"."$5","$4}' $TMP_path/choice_server.csv > $TMP_path/choice_server1.csv
				awk -F, '{print $1","$2","$3","$5","$4}' $TMP_path/choice_server.csv > $TMP_path/choice_server1.csv
			else
				echo -e "�������,����������..."
				list_Server
			fi
		fi
	;;
	b|B)
		if [ "$(grep -Ev "^#|^$" etc/gamegroup.csv |awk -F, '{print $2}' |sort -k 1 | uniq -d)" ];then                                                        
			repeated_server=`grep -Ev "^#|^$" etc/gamegroup.csv |awk -F, '{print $2}' |sort -k 1 | uniq -d`
			echo -e "\n\033[40;31m!!!!������ͬ�ķ�������(����): \033[0m \n$repeated_server"
			list_Server
		else
			grep -Ev "^#|^$" etc/gamegroup.csv |awk -F, '{print $2" ("$8")"}'
			choice_number=`grep -Ev "^#|^$" etc/gamegroup.csv | wc -l`
			rm -rf $TMP_path/choice_server*.csv
			grep -Ev "^#|^$" etc/gamegroup.csv > $TMP_path/choice_server.csv
			echo -e "\n��ѡ����$choice_number������ȷ���밴y: \c"
			read choice
			if [ ${choice} == "Y" -o ${choice} == "y" ];then
				awk -F, '{print $1","$2","$3","$5","$4}' $TMP_path/choice_server.csv > $TMP_path/choice_server1.csv
			else
				echo -e "�������,����������..."
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
			echo -e "\n\033[40;31m!!!!������ͬ�ķ�������(����): \033[0m \n$repeated_server"
			list_Server
		else
		grep -Ev "^#|^$" etc/gamegroup.csv |awk -F, 'BEGIN {print "\r"} {print $2" ("$8")"}'
		echo -e "\n�����������,�ÿո����:\n"
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
		echo -e "�������,����������..."
		list_Server
	esac
}

function list_MTA_Server ()
{
	echo
	echo -e "*******************"
	echo -e "a) �������з�"
	echo -e "h) ��ѡ��"
	echo -e "r) ����"
	echo -e "*******************"
	echo
	echo -e "��ѡ��ѡ�\c"

	read type_servers

	case $type_servers in
	a|A)
		if [ "$(grep -Ev "^#|^$" etc/mta.csv |awk -F: '{print $1}' |sort -k 1 | uniq -d)" ];then
			repeated_server=`grep -Ev "^#|^$" etc/mta.csv |awk -F: '{print $1}' |sort -k 1 | uniq -d`
			echo -e "\n\033[40;31m!!!!������ͬ�ķ�������(����): \033[0m \n$repeated_server"
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
			echo -e "\n��ѡ����$choice_number���������ȷ���밴y: \c"
			read choice
			if [ ${choice} == "Y" -o ${choice} == "y" ];then
				continue
#				awk -F, '{print $1","$2","$3","192"."168"."$5","$4}' $TMP_path/choice_MTA_server.csv > $TMP_path/choice_MTA_server1.csv
#				awk -F: '{print $1}' $TMP_path/choice_MTA_server.csv > $TMP_path/choice_MTA_server1.csv
			else
				echo -e "�������,����������..."
				list_MTA_Server
			fi
		fi
	;;
	h|H)
		if [ "$(grep -Ev "^#|^$" etc/mta.csv |awk -F: '{print $1}' |sort -k 1 | uniq -d)" ];then
			repeated_server=`grep -Ev "^#|^$" etc/mta.csv |awk -F: '{print $1}' |sort -k 1 | uniq -d`
			echo -e "\n\033[40;31m!!!!������ͬ�ķ�������(����): \033[0m \n$repeated_server"
			list_MTA_Server
		else

			grep -Ev "^#|^$" etc/mta.csv |awk -F: 'BEGIN {print "\r"} {print $1}'
			echo -e "\n�����������,�ÿո����:\n"
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
		echo -e "�������,����������..."
		list_MTA_Server
	esac
}

#### �������� ####

function list_CheckItem ()
{
	echo
	echo -e "*******************"
	echo -e "a) ���ȫ������ǽ"
	echo -e "b) ���۱�¥�����ļ�(alarm)"
	echo -e "w) ����"
	echo -e "r) ����"
	echo -e "*******************"
	echo
	echo -e "��ѡ��ѡ�\c"
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
		echo -e "�������,����������..."
		list_CheckItem
	fi
}

#### ����ά����� ####                                                                                                                                   

function list_LiXing ()
{
	echo
	echo -e "*******************"
	echo -e "a) �ϴ��汾"
	echo -e "b) ���ط���ǽ"
	echo -e "c) �ϴ�΢����Դ"
	echo -e "r) ����"
	echo -e "*******************"
	echo
	echo -e "��ѡ��ѡ�\c"

	read type_lixing

#### �ϴ��汾 ####

    if [ ${type_lixing} == "a" -o ${type_lixing} == "A" ];then
		list_Server
		bash bin/upload_banben.sh
		menu

#### ���ط���ǽ ####

	elif [ ${type_lixing} == "b" -o ${type_lixing} == "B" ];then
		echo "Nothing!!!!"
		list_LiXing

	elif [ ${type_lixing} == "c" -o ${type_lixing} == "C" ];then
		echo "========================================"
		bash bin/upload_weiduan.sh

	elif [ ${type_lixing} == "r" -o ${type_lixing} == "R" ];then
		menu

	else
		echo -e "�������,����������..."
		list_LiXing
	fi
}

#### �ճ�������� ####

function list_RiChang ()
{
	echo
	echo
	echo -e "*******************"
	echo -e "a) �ϴ��ļ�"
	echo -e "b) ִ�ж�̬����"
	echo -e "c) �����ļ�"
	echo -e "d) ����SSHָ��"
	echo -e "e) APEX����"
	echo -e "f) �����"
	echo -e "g) ��������"
	echo -e "h) ��ȡapex��־"
	echo -e "r) ����"
	echo -e "*******************"
	echo
	echo -e "��ѡ��ѡ�\c"

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
		echo -e "�������,����������..."
		list_RiChang
	fi
}

#### CDN��� ####

function list_CDN ()
{
	echo
	echo -e "*******************"
	echo -e "a) ��һ��:���ز��޸�patch_list.xml,���ϴ��������ļ�"
	echo -e "b) �ڶ���:����patch_list.xml"
	echo -e "c) ������:���ز��޸�server_list.xml,������"
	echo -e "q) ����"
	echo -e "*******************"
	echo
	echo -e "��ѡ��ѡ�\c"

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
		echo -e "�������,����������..."
		list_CDN
	fi
}


#### ������� ####

function list_MainTain ()
{
	echo
	echo -e "*******************"
	echo -e "a) �ϴ�MTS�汾"
	echo -e "b) ����MTS"
	echo -e "c) �ϴ�MTA�汾"
	echo -e "d) �ر�MTA(����ִ��)"
	echo -e "e) ����MTA�汾"
	echo -e "g) ����MTA"
	echo -e "h) Ӳ����MTA"
	echo -e "r) ����"
	echo -e "*******************"
	echo
	echo -e "��ѡ��ѡ�\c"

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
		echo -e "�������,����������..."
		list_MainTain
	fi
	
}

menu
