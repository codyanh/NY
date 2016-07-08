#!/bin/bash

echo
echo "##################################################################################################"
echo '#请将所有的patch.sy , patch.exe , depatch.sy , depatch.exe , patch.sy.md5.txt , depatch.sy.md5.txt'
echo '#放到 cdnpush/patchfile/ 目录下面去, 否则要出错哦~'
make_patchlist_cmd=`echo 'cd cdnpush/ ; ./make_patchlist.sh'`
echo '#首先,将执行生成新的patch_list.xml 命令: make_patchlist_cmd'
echo '#生成的patch_list.xml : cdnpush/patch_list.xml_ws(patch_list.xml_lx)'
echo "##################################################################################################"
echo "确定放好了?继续?[ yes 或者任意键中断操作 ]"
echo -e ">>\c "

read choice_Y
if [ ${choice_Y} == "yes" -o ${choice_Y} == "YES" ];then
	expect expect/scp_expect.exp 172.19.0.90:/home/update/patch_list.xml cdnpush/patch_list.xml_ws && \
	expect expect/scp_expect.exp 172.19.0.90:/home/lx/update/patch_list.xml cdnpush/patch_list.xml_lx
	if [[ $? -eq 0 ]];then
		echo -e "\033[40;32m下载patch_list.xml到本地成功\033[0m"
	else
		echo -e "\033[40;31m下载patch_list.xml到本地失败\033[0m"
		exit 1
	fi

	echo -e "\033[40;33m开始生成patch_list.xml...\033[0m"
	sed -i "/<\/patch>/d" cdnpush/patch_list.xml_ws
	sed -i "/<\/root>/d" cdnpush/patch_list.xml_ws
	sed -i "/<\/patch>/d" cdnpush/patch_list.xml_lx
	sed -i "/<\/root>/d" cdnpush/patch_list.xml_lx

	patch_line=`sed -n "/<file filename=\"patch/p" cdnpush/patchfile/*.txt`
	depatch_line=`sed -n "/<file filename=\"depatch/p" cdnpush/patchfile/*.txt`

	tac cdnpush/patch_list.xml_ws | sed "0,/<file filename=\"patch/{//s@.*@$patch_line\n&@}" | tac > cdnpush/patch_list.xml_ws.tmp
	rm cdnpush/patch_list.xml_ws -rf
	tac cdnpush/patch_list.xml_ws.tmp | sed "0,/<file filename=\"depatch/{//s@.*@$depatch_line\n&@}"| tac > cdnpush/patch_list.xml_ws
	rm cdnpush/patch_list.xml_ws.tmp -rf

	tac cdnpush/patch_list.xml_lx | sed "0,/<file filename=\"patch/{//s@.*@$patch_line\n&@}"| tac > cdnpush/patch_list.xml_lx.tmp
	rm cdnpush/patch_list.xml_lx -rf
	tac cdnpush/patch_list.xml_lx.tmp | sed "0,/<file filename=\"depatch/{//s@.*@$depatch_line\n&@}"| tac > cdnpush/patch_list.xml_lx
	rm cdnpush/patch_list.xml_lx.tmp -rf

	echo "</patch>" >> cdnpush/patch_list.xml_ws
	echo "</root>" >> cdnpush/patch_list.xml_ws
	echo "</patch>" >> cdnpush/patch_list.xml_lx
	echo "</root>" >> cdnpush/patch_list.xml_lx

	echo -e "\033[40;32mpatch_list.xml生成完成\033[0m，请查看patch_list.xml是否正确patch_list.xml_ws(lx)"

else
	echo -e "\033[40;31m输入错误...\033[0m"
	exit 1
fi

#### 以下为上传补丁包操作 ####

upload_patchfile_cmd=`echo 'cd cdnpush/ ; ./upload_patchfile.py'`
echo
echo -e "然后,将执行上传补丁包 命令: ${upload_patchfile_cmd}"
echo -e '生成完了,继续上传补丁包?[ yes 或者任意键中断操作 ]'

read choice_Y
if [ ${choice_Y} == "yes" -o ${choice_Y} == "YES" ];then
	cd cdnpush/ ; ./upload_patchfile.py

	echo "##################################################################################################"
	echo '#是否完全分发完,请打开 网宿后台-->内容管理-->大文件系统-->任务查询 进行查看'
	echo '#                      蓝汛的打开fds4.exe 工具查看是否已经 可服务 状态'
	echo "##################################################################################################"

else
	echo -e "\033[40;31m输入错误...\033[0m"
	exit 1
fi
