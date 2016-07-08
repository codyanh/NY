#!/usr/bin/python
#-*- coding: utf-8 -*-
#encoding=gbk
from xml.etree import ElementTree as ET
try:
	ET.parse('patch_list.xml_ws')
	print 'patch_list.xml_ws语法检查通过!!'
except Exception,e:
	print 'patch_list.xml_ws有语法错误!!'

try:
	ET.parse('patch_list.xml_lx')
	print 'patch_list.xml_lx语法检查通过!!'
except Exception,e:
	print 'patch_list.xml_lx有语法错误!!'
