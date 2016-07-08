#!/bin/bash
serverlistfile=$1

cd cdnpush/

#### 以下为网宿server_list推送 #####
echo
echo "##################################################################################################"
echo "#需要从现网下载一份新的server_list.xml下来吗？"
download_serverlist_cmd=`echo 'wget -N -P ./ http://172.19.0.90/update/server_list.xml'`
echo -e "#将执行下载server_list 命令: ${download_serverlist_cmd}"
echo "#下载完了请瞅这 : more ./server_list.xml"
echo "##################################################################################################"
echo -e "需要吗？[ 输入yes继续，或 q 键跳过此操作]"
echo -e ">>\c "

read choice_Y
if [ ${choice_Y} == "Q" -o ${choice_Y} == "q" ];then
	:
elif [ ${choice_Y} == "yes" -o ${choice_Y} == "YES" ];then
	rm server_list.xml -rf
	wget -N -P ./ http://172.19.0.90/update/server_list.xml
    if [[ $? -eq 0 ]];then
        echo -e "\033[40;32m从源站下载server_list.xml完毕!!\033[0m"
	fi
else
    echo -e "\033[40;31m输入错误...请重新输入...\033[0m"
    exit 1
fi

echo
echo "##################################################################################################"
echo "#请确保server_list.xml内容正确 : ./server_list.xml"
push_serverlist_cmd=`echo './ny_cdnpush_serverlist.sh server_list.xml'`
echo -e "#将执行推送server_list 命令: ${push_serverlist_cmd}"
echo '#你也可以手动执行或者定时操作: \"./ny_cdnpush_serverlist.sh <serverlist文件>\"'
echo "##################################################################################################"
echo "检查完了?继续?[ yes 或者任意键中断操作 ]"
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
		echo -e "\033[40;32m上传源站完毕,正在推送...\033[0m"
	else
		echo -e "\033[40;31m上传源站失败!!!\033[0m"
		exit 1
	fi
#else
#	echo -e "输入错误..."
#fi

	echo -e "继续推送，请输入yes："
	read choice_YYY
	if [ ${choice_YYY} == "yes" -o ${choice_YYY} == "YES" ];then
		echo -e "\n网宿推送的结果: "
		RESULT_ws=$(curl -s `push_shell_ws/cdnpush.sh push_shell_ws/push_url`)	##curl -s为静默模式，不显示错误和进度信息
		#echo "RESULT_ws=$RESULT_ws"	##调试时脚本时打开
		for i in {1..15}
		do
			if [[ $( echo $RESULT_ws | grep  "success append purge tasks") == "" ]]; then
        		echo -e "\033[40;33m 再等会儿  $((10*$i))s... \033[0m"
        		sleep 10
    		else
				echo -e "\033[40;32mRESULT_ws=\033[0m$RESULT_ws"
				echo -e "\033[40;32m====== 网宿上传成功!!! ======\033[0m"
				break
			fi
		done

#### 以下为蓝汛server_list推送 #####

#### 蓝汛的页面加速已停用 2016 ####

#		sleep 2
#		LX_username=syyx
#		LX_password=Iewa1Aeph6uu7a
#
#		RID=$(java -jar push_shell_lx/examples-1.2.jar -POST $LX_username $LX_password "{\"urls\":[\"http://nyupdate04.shangyoo.com/lx/update/server_list.xml\",\"http://nyupdate04.shangyoo.com/lx/update2/server_list.xml\"],\"callback\":{\"email\":[\"*@*.com\"],\"acptNotice\":false}}" | sed -n "/r_id/s/^.*\"r_id\": \"\([^\"]*\)\".*/\1/p")
#
#		echo -e "\n蓝汛推送的结果: "
#		for i in {1..15}
#		do
#			RESULT_lx=$(java -jar push_shell_lx/examples-1.2.jar -GET $LX_username $LX_password $RID )
#		#	echo -e "RESULT_lx=$RESULT_lx"	##调试时脚本时打开
#			if [[ $( echo $RESULT_lx | grep  "SUCCESS") == "" ]]; then
#				echo -e "\033[40;33m 再等会儿  $((10*$i))s... \033[0m"
#				sleep 10
#			else
#				echo -e "\033[40;32mRESULT_lx=\033[0m$RESULT_lx"
#				echo -e "\033[40;32m====== 蓝汛上传成功!!! ======\033[0m"
#				exit 0
#			fi
#		done
	else
		echo -e "输入错误..."
	fi

else
	exit 0
fi
