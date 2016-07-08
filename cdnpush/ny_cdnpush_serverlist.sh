#!/bin/bash
serverlistfile=$1

cd cdnpush/

#### ����Ϊ����server_list���� #####
echo
echo "##################################################################################################"
echo "#��Ҫ����������һ���µ�server_list.xml������"
download_serverlist_cmd=`echo 'wget -N -P ./ http://172.19.0.90/update/server_list.xml'`
echo -e "#��ִ������server_list ����: ${download_serverlist_cmd}"
echo "#������������� : more ./server_list.xml"
echo "##################################################################################################"
echo -e "��Ҫ��[ ����yes�������� q �������˲���]"
echo -e ">>\c "

read choice_Y
if [ ${choice_Y} == "Q" -o ${choice_Y} == "q" ];then
	:
elif [ ${choice_Y} == "yes" -o ${choice_Y} == "YES" ];then
	rm server_list.xml -rf
	wget -N -P ./ http://172.19.0.90/update/server_list.xml
    if [[ $? -eq 0 ]];then
        echo -e "\033[40;32m��Դվ����server_list.xml���!!\033[0m"
	fi
else
    echo -e "\033[40;31m�������...����������...\033[0m"
    exit 1
fi

echo
echo "##################################################################################################"
echo "#��ȷ��server_list.xml������ȷ : ./server_list.xml"
push_serverlist_cmd=`echo './ny_cdnpush_serverlist.sh server_list.xml'`
echo -e "#��ִ������server_list ����: ${push_serverlist_cmd}"
echo '#��Ҳ�����ֶ�ִ�л��߶�ʱ����: \"./ny_cdnpush_serverlist.sh <serverlist�ļ�>\"'
echo "##################################################################################################"
echo "�������?����?[ yes ����������жϲ��� ]"
echo -e ">>\c "

read choice_YY
if [ ${choice_YY} == "yes" -o ${choice_YY} == "YES" ];then
	expect ../expect/scp_expect.exp $serverlistfile 192.168.30.21:/home/update/server_list.xml && \
	expect ../expect/scp_expect.exp $serverlistfile 192.168.30.21:/home/update2/server_list.xml && \
	expect ../expect/scp_expect.exp $serverlistfile 192.168.30.21:/home/lx/update/server_list.xml && \
	expect ../expect/scp_expect.exp $serverlistfile 192.168.30.21:/home/lx/update2/server_list.xml && \
	expect ../expect/scp_expect.exp $serverlistfile 172.19.0.90:/home/update/server_list.xml && \
	expect ../expect/scp_expect.exp $serverlistfile 172.19.0.90:/home/update2/server_list.xml && \
	expect ../expect/scp_expect.exp $serverlistfile 172.19.0.90:/home/lx/update/server_list.xml && \
	expect ../expect/scp_expect.exp $serverlistfile 172.19.0.90:/home/lx/update2/server_list.xml
#	expect ../expect/scp_expect.exp $serverlistfile 192.168.221.53:/home/update/server_list.xml && \
#	expect ../expect/scp_expect.exp $serverlistfile 192.168.221.53:/home/update2/server_list.xml && \
#	expect ../expect/scp_expect.exp $serverlistfile 192.168.221.53:/home/lx/update/server_list.xml && \
#	expect ../expect/scp_expect.exp $serverlistfile 192.168.221.53:/home/lx/update2/server_list.xml
	if [[ $? -eq 0 ]];then
		echo -e "\033[40;32m�ϴ�Դվ���,��������...\033[0m"
	else
		echo -e "\033[40;31m�ϴ�Դվʧ��!!!\033[0m"
		exit 1
	fi
#else
#	echo -e "�������..."
#fi

	echo -e "�������ͣ�������yes��"
	read choice_YYY
	if [ ${choice_YYY} == "yes" -o ${choice_YYY} == "YES" ];then
		echo -e "\n�������͵Ľ��: "
		RESULT_ws=$(curl -s `push_shell_ws/cdnpush.sh push_shell_ws/push_url`)	##curl -sΪ��Ĭģʽ������ʾ����ͽ�����Ϣ
		#echo "RESULT_ws=$RESULT_ws"	##����ʱ�ű�ʱ��
		for i in {1..15}
		do
			if [[ $( echo $RESULT_ws | grep  "success append purge tasks") == "" ]]; then
        		echo -e "\033[40;33m �ٵȻ��  $((10*$i))s... \033[0m"
        		sleep 10
    		else
				echo -e "\033[40;32mRESULT_ws=\033[0m$RESULT_ws"
				echo -e "\033[40;32m====== �����ϴ��ɹ�!!! ======\033[0m"
				break
			fi
		done

#### ����Ϊ��Ѵserver_list���� #####

#### ��Ѵ��ҳ�������ͣ�� 2016 ####

#		sleep 2
#		LX_username=syyx
#		LX_password=Iewa1Aeph6uu7a
#
#		RID=$(java -jar push_shell_lx/examples-1.2.jar -POST $LX_username $LX_password "{\"urls\":[\"http://nyupdate04.shangyoo.com/lx/update/server_list.xml\",\"http://nyupdate04.shangyoo.com/lx/update2/server_list.xml\"],\"callback\":{\"email\":[\"*@*.com\"],\"acptNotice\":false}}" | sed -n "/r_id/s/^.*\"r_id\": \"\([^\"]*\)\".*/\1/p")
#
#		echo -e "\n��Ѵ���͵Ľ��: "
#		for i in {1..15}
#		do
#			RESULT_lx=$(java -jar push_shell_lx/examples-1.2.jar -GET $LX_username $LX_password $RID )
#		#	echo -e "RESULT_lx=$RESULT_lx"	##����ʱ�ű�ʱ��
#			if [[ $( echo $RESULT_lx | grep  "SUCCESS") == "" ]]; then
#				echo -e "\033[40;33m �ٵȻ��  $((10*$i))s... \033[0m"
#				sleep 10
#			else
#				echo -e "\033[40;32mRESULT_lx=\033[0m$RESULT_lx"
#				echo -e "\033[40;32m====== ��Ѵ�ϴ��ɹ�!!! ======\033[0m"
#				exit 0
#			fi
#		done
	else
		echo -e "�������..."
	fi

else
	exit 0
fi