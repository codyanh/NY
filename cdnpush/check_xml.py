#!/usr/bin/python
#-*- coding: utf-8 -*-
#encoding=gbk
from xml.etree import ElementTree as ET
try:
	ET.parse('patch_list.xml_ws')
	print 'patch_list.xml_ws�﷨���ͨ��!!'
except Exception,e:
	print 'patch_list.xml_ws���﷨����!!'

try:
	ET.parse('patch_list.xml_lx')
	print 'patch_list.xml_lx�﷨���ͨ��!!'
except Exception,e:
	print 'patch_list.xml_lx���﷨����!!'
