#!/bin/bash

####################### 脚本中防火墙状态 ################################################

firewall_state()
{
    for Platform in $(cat ../etc/gameserver |grep "^#:config:" |cut -d : -f 3)
    do
        cat ../etc/gameserver | grep -Ev "^#|^$" | awk -F ',' '{print $2}'| sort  |awk  -v Alone=${Platform} 'BEGIN{print "\n"Alone"服:"}$1~Alone{printf "%s",$1}END{print ""}'
    done
}

new_version_Firewall()
{
echo "请选择要执行的操作：1）都可以玩；2）公司内部可以玩；3）都不可以玩；";
read fire_YN;
case ${fire_YN} in
    1)
        Developers=$(echo "-s 0.0.0.0/0")
    ;;
    2)
        Developers=$(echo "-s 58.251.141.28/32")
    ;;
    3)
        Developers=$(echo "-s 127.0.0.1/32")
    ;;
esac
echo "你确定要执行吗？(Y/N?)";               
read YN;
if [ "$YN" == "Y" -o "$YN" == "y" ];then
Temp_file_date=$(date '+%y%m%d%H%M%S')

for fire_GSIP in $(cat ${Per_folder}/number.log |cut -d , -f 3 |sort -u)
do
    {
    echo "######## 开始执行 192.168.${fire_GSIP} 防火墙 ########"
    {
    ssh ${USER_SCRIPT}@192.168.${fire_GSIP} "if [ -f /home/${USER_SCRIPT}/firewall_rules ];then sudo iptables-save >/home/${USER_SCRIPT}/firewall_rules;exit 5;else exit 6;fi"
    The_fireW=$(echo $?)
    if [ "${The_fireW}" -eq 6 ];then
        scp  ../etc/IP ${USER_SCRIPT}@192.168.${fire_GSIP}:/home/${USER_SCRIPT}/firewall_rules
    fi

    if [ $(cat ../etc/NBServer |grep -Ev "^#|^$" | grep "${fire_GSIP},") ];then
        Port_control_LS=$(cat ../modular/Game_server/Port_table_NB|awk 'BEGIN{FS=","}$1=="LS"{print $2}')
        Port_control_BS=$(cat ../modular/Game_server/Port_table_NB|awk 'BEGIN{FS=","}$1=="BS"{print $2}')
        for Distinguish_execution in $(cat ${Per_folder}/number.log | awk -F , -v FG=${fire_GSIP} '$3==FG{print $4}')
        do
            No_number_2=${Distinguish_execution:2}
            ssh ${USER_SCRIPT}@192.168.${fire_GSIP} "sed -i -e '/^:/d' -e '/${Port_control_LS}${No_number_2}/d' -e '/${Port_control_BS}${No_number_2}/d' -e '/^*filter/a\-A INPUT ${Developers} -i bond1 -p tcp -m tcp --dport ${Port_control_LS}${No_number_2} -j ACCEPT' -e '/^*filter/a\-A INPUT ${Developers} -i bond1 -p tcp -m tcp --dport ${Port_control_BS}${No_number_2} -j ACCEPT' /home/${USER_SCRIPT}/firewall_rules;"
        done
    else
        Port_control_LS=$(cat ../modular/Game_server/Port_table_Normal|awk 'BEGIN{FS=","}$1=="LS"{print $2}')
        Port_control_BS=$(cat ../modular/Game_server/Port_table_Normal|awk 'BEGIN{FS=","}$1=="BS"{print $2}')
        for Distinguish_execution in $(cat ${Per_folder}/number.log | awk -F , -v FG=${fire_GSIP} '$3==FG{print $4}')
        do
            No_number_3=${Distinguish_execution:3}
            ssh ${USER_SCRIPT}@192.168.${fire_GSIP} "sed -i -e '/^:/d' -e '/${Port_control_LS}${No_number_3}/d' -e '/${Port_control_BS}${No_number_3}/d' -e '/^*filter/a\-A INPUT ${Developers} -i bond1 -p tcp -m tcp --dport ${Port_control_LS}${No_number_3} -j ACCEPT' -e '/^*filter/a\-A INPUT ${Developers} -i bond1 -p 
tcp -m tcp --dport ${Port_control_BS}${No_number_3} -j ACCEPT' /home/${USER_SCRIPT}/firewall_rules;"
        done
    fi
    ssh ${USER_SCRIPT}@192.168.${fire_GSIP} "sudo iptables-restore < /home/${USER_SCRIPT}/firewall_rules;sudo iptables -vnL"

       } >> ../log/firewall_${Temp_file_date}_${fire_GSIP}.log
       echo "======== 192.168.${fire_GSIP} 执行完毕 可以通过 ../log/firewall_${Temp_file_date}_${fire_GSIP}.log 开了解现网配置 ========"
    }&
done
wait
echo "======== 执行完毕 ========"


else
    echo "未执行"
    sleep 1
fi
}
