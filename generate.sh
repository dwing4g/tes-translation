#!/bin/bash
for txt_file in $(ls *.txt)
do
	txt_file=${txt_file%.txt}
	echo $txt_file
	iconv -f gbk -t utf-8 ${txt_file}.txt > ${txt_file}.txt_utf8
	sed -i 's/\r$//' ${txt_file}.txt_utf8
	luajit ./tes3enc.lua ${txt_file}.txt_utf8 ${txt_file}.esp
done
