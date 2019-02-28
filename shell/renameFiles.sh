#!/bin/bash

# This script will iterate over the files in a directory and rename them according to their MD5 checksum. This should
# eliminate duplicate images.
filePath=~/Documents/xfast-dataset/raw/olea-europea/control/;

for filename in ${filePath}*.jpg; do
	echo ${filename};
	md5=`md5sum ${filename} | awk '{ print $1 }'`;
	newFilename=${filePath}${md5}'.jpg';
	echo "cp $filename $newFilename";
    #for ((i=0; i<=3; i++)); do
    #    ./MyProgram.exe "$filename" "Logs/$(basename "$filename" .txt)_Log$i.txt"
    #done
done
