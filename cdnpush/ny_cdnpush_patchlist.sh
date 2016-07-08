#!/bin/bash
cd cdnpush

expect ../expect/scp_expect.exp patch_list.xml_ws 192.168.30.21:/home/update/patch_list.xml && \
expect ../expect/scp_expect.exp patch_list.xml_lx 192.168.30.21:/home/lx/update/patch_list.xml && \
expect ../expect/scp_expect.exp patch_list.xml_ws 172.19.0.90:/home/update/patch_list.xml && \
expect ../expect/scp_expect.exp patch_list.xml_lx 172.19.0.90:/home/lx/update/patch_list.xml
#expect ../expect/scp_expect.exp patch_list.xml_ws 192.168.221.53:/home/update/patch_list.xml && \
#expect ../expect/scp_expect.exp patch_list.xml_lx 192.168.221.53:/home/lx/update/patch_list.xml
if [[ $? -eq 0 ]];then
	echo -e "\033[40;32m�ϴ�Դվ���,��������...\033[0m"
else
	echo -e "\033[40;31m�ϴ�Դվʧ��!!!\033[0m"
	exit 1
fi
###################################
#echo -n "�������͵Ľ��: " ;curl `push_shell_ws/cdnpush.sh push_shell_ws/push_url.patchlist`

echo -e "\n�������͵Ľ��: "
RESULT_ws=$(curl -s `push_shell_ws/cdnpush.sh push_shell_ws/push_url.patchlist`)  ##curl -sΪ��Ĭģʽ������ʾ����ͽ�����Ϣ
#echo "RESULT_ws=$RESULT_ws"    ##����ʱ�ű�ʱ��
for i in {1..10}
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

###################################

#### ����Ϊ��Ѵpatch_list���� #####

#### ��Ѵ��ҳ������Ѿ�ͣ�� 2016�� ####

#sleep 2
#LX_username=syyx
#LX_password=Iewa1Aeph6uu7a
#
#RID=$(java -jar push_shell_lx/examples-1.2.jar -POST $LX_username $LX_password "{\"urls\":[\"http://nyupdate04.shangyoo.com/lx/update/patch_list.xml\"],\"callback\":{\"email\":[\"*@*.com\"],\"acptNotice\":false}}" | sed -n "/r_id/s/^.*\"r_id\": \"\([^\"]*\)\".*/\1/p")
#
#echo -e "\n��Ѵ���͵Ľ��: "
#for i in {1..10}
#do
#    RESULT_lx=$(java -jar push_shell_lx/examples-1.2.jar -GET $LX_username $LX_password $RID )
##   echo -e "RESULT_lx=$RESULT_lx"  ##����ʱ�ű�ʱ��
#    if [[ $( echo $RESULT_lx | grep  "SUCCESS") == "" ]]; then
#        echo -e "\033[40;33m �ٵȻ��  $((10*$i))s... \033[0m"
#        sleep 10
#    else
#        echo -e "\033[40;32mRESULT_lx=\033[0m$RESULT_lx"
#        echo -e "\033[40;32m====== ��Ѵ�ϴ��ɹ�!!! ======\033[0m"
#        exit 0
#    fi
#done
