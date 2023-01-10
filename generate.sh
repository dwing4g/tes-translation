#!/bin/bash
for txt_file in $(ls *.txt)
do
	txt_file=${txt_file%.txt}
	echo $txt_file
	sed -i 's/\r$//' ${txt_file}.txt
	luajit ./tes3enc.lua ${txt_file}.txt ${txt_file}_gbk.esp
	luajit ./tes3dec.lua ${txt_file}_gbk.esp gbk > ${txt_file}.txt_gbk
	iconv -f gbk -t utf-8 ${txt_file}.txt_gbk > ${txt_file}.txt_utf8
	luajit ./tes3enc.lua ${txt_file}.txt_utf8 ${txt_file}_utf8.esp
done
