#!/bin/bash

echo
echo "##################################################################################################"
echo '#�뽫���е�patch.sy , patch.exe , depatch.sy , depatch.exe , patch.sy.md5.txt , depatch.sy.md5.txt'
echo '#�ŵ� cdnpush/patchfile/ Ŀ¼����ȥ, ����Ҫ����Ŷ~'
make_patchlist_cmd=`echo 'cd cdnpush/ ; ./make_patchlist.sh'`
echo '#����,��ִ�������µ�patch_list.xml ����: make_patchlist_cmd'
echo '#���ɵ�patch_list.xml : cdnpush/patch_list.xml_ws(patch_list.xml_lx)'
echo "##################################################################################################"
echo "ȷ���ź���?����?[ yes ����������жϲ��� ]"
echo -e ">>\c "

read choice_Y
if [ ${choice_Y} == "yes" -o ${choice_Y} == "YES" ];then
	expect expect/scp_expect.exp 172.19.0.90:/home/update/patch_list.xml cdnpush/patch_list.xml_ws && \
	expect expect/scp_expect.exp 172.19.0.90:/home/lx/update/patch_list.xml cdnpush/patch_list.xml_lx
	if [[ $? -eq 0 ]];then
		echo -e "\033[40;32m����patch_list.xml�����سɹ�\033[0m"
	else
		echo -e "\033[40;31m����patch_list.xml������ʧ��\033[0m"
		exit 1
	fi

	echo -e "\033[40;33m��ʼ����patch_list.xml...\033[0m"
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

	echo -e "\033[40;32mpatch_list.xml�������\033[0m����鿴patch_list.xml�Ƿ���ȷpatch_list.xml_ws(lx)"

else
	echo -e "\033[40;31m�������...\033[0m"
	exit 1
fi

#### ����Ϊ�ϴ����������� ####

upload_patchfile_cmd=`echo 'cd cdnpush/ ; ./upload_patchfile.py'`
echo
echo -e "Ȼ��,��ִ���ϴ������� ����: ${upload_patchfile_cmd}"
echo -e '��������,�����ϴ�������?[ yes ����������жϲ��� ]'

read choice_Y
if [ ${choice_Y} == "yes" -o ${choice_Y} == "YES" ];then
	cd cdnpush/ ; ./upload_patchfile.py

	echo "##################################################################################################"
	echo '#�Ƿ���ȫ�ַ���,��� ���޺�̨-->���ݹ���-->���ļ�ϵͳ-->�����ѯ ���в鿴'
	echo '#                      ��Ѵ�Ĵ�fds4.exe ���߲鿴�Ƿ��Ѿ� �ɷ��� ״̬'
	echo "##################################################################################################"

else
	echo -e "\033[40;31m�������...\033[0m"
	exit 1
fi
