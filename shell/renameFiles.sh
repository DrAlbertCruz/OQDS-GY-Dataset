#!/bin/bash

# This script will iterate over the files in a directory and rename them according to their MD5 checksum. This should
# eliminate duplicate images.
filePath=~/Documents/xfast-dataset/raw/vitus-vinifera/stictocephala-bisonia/;

for filename in ${filePath}*.jpg; do
	md5=`md5sum ${filename} | awk '{ print $1 }'`;
	newFilename=${filePath}${md5}'.jpg';
	cp $filename $newFilename;
	rm -f $filename;
done
