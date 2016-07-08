#!/bin/bash

#### ���۱�¥�����ļ����� ####

function check_log_alarm ()
{
	alarm_IP=$1
	alarm_path=$2
	name_server=$3
	path_server=$4
	number_arg=$#

	if [ $number_arg -eq 4 ];then
        expect expect/check_jbl.exp $alarm_IP $alarm_path $name_server $path_server> $TMP_path/check_jbl_${path_server}_${name_server}.log 2>&1
        sleep 1
		if grep -q "This server No such file" $TMP_path/check_jbl_${path_server}_${name_server}.log ;then
            return 0
		else
			return 1
        fi
    else
        echo -e "$number_arg Parameter Number Error!!!\r"
    fi
}

#### ���۱�¥�����ļ�(alarm1.log) ####

function check_alarm ()
{

echo -e "���������밴y��"                                                                                                                                    
read choiceY
if [ ${choiceY} == "Y" -o ${choiceY} == "y" ];then

    server_number=`cat $TMP_path/choice_server1.csv | wc -l`

##############################################
#### ���forѭ�� #### ����ִ�� #### ͬʱ�����
#
    temp_fifo_file=$$.info  ##�Ե�ǰ���̺ţ�Ϊ��ʱ�ܵ�ȡ��
    mkfifo $temp_fifo_file  ##������ʱ�ܵ�
    exec 9<>$temp_fifo_file ##������ʶΪ9�����ԶԹܵ����ж�д
    rm $temp_fifo_file      ##��չܵ�����
    temp_thread=3           ##����������
    for ((ii=0;ii<$temp_thread;ii++))   ##Ϊ���̴�����Ӧ��ռλ
    do
        echo                ##ÿ��echo���һ���س���Ϊÿ�����̴���һ��ռλ
    done >&9                ##��ռλ��Ϣд���ʶΪ9�Ĺܵ�
#
##############################################

    for i in `seq 1 $server_number`
    do
        read -u9    ##�������ʱ��
        {           ##�������ʱ��

        SERVER=`sed -n "$i"p $TMP_path/choice_server1.csv`
        path_server=`echo $SERVER |awk -F, '{print $1}'`
        name_server=`echo $SERVER |awk -F, '{print $2}'`
        TYPE_moban=`echo $SERVER |awk -F, '{print $3}'`
        sec_IP=`echo $SERVER |awk -F, '{print $5}'`
        template_file=`ls template/ |grep "_${TYPE_moban}_" |grep -E "xml$" |grep -E "^template"`   ##ƥ��ģ���ļ�������31ģ��
        alarm_path=`cat template/${template_file} |awk '/<'gmod'>/,/<\/'gmod'>/{if(j>1)print x;x=$0;j++}' |awk '/<'CCS'>/,/<\/'CCS'>/{if(jj>1)print x;x=$0;jj++}' |awk -F= '/alarm_1/{print$2}' |tr -d " "`
        alarm_IP=192.168.${sec_IP}.`cat template/${template_file} |awk '/<'gmod'>/,/<\/'gmod'>/{if(k>1)print x;x=$0;k++}' |awk '/<'CCS'>/,/<\/'CCS'>/{if(kk>1)print x;x=$0;kk++}' |awk -F= '/IP/{print$2}' |tr -d " "`

        check_log_alarm $alarm_IP $alarm_path $name_server $path_server
        ret=$?
		if [ $ret -eq 0 ];then
			printf "%-20s\033[40;32m OK\033[0m\n" $name_server  ##�ϴ��ɹ�������ɫ
		else
			printf "%-20s\033[40;31m ERROR \033[0m\n" $name_server  ##�ϴ��ɹ�������ɫ
		fi

		echo >&9	##
		}&	##	
	done

		wait    ##
		echo    ##��β��ӡ����
		exec 9>&-   ##

else
	exit 0
fi

}

check_alarm
