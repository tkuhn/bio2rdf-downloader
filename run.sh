#!/bin/bash

URL=http://download.bio2rdf.org/release/2/

rm -f err.log out.log

mkdir -p files
cd files

echo "Downloading Index..." >> ../out.log

wget $URL -O index.html >> ../out.log 2>> ../err.log

cat index.html | egrep '<a href="[^"]*">[^<].*/</a>' | sed 's/^.*<a href="[^"]*">\([^<].*\)\/<\/a>.*$/\1/' > dirs.txt
rm index.html

while read D; do
  echo "Accessing $D..." >> ../out.log
  mkdir -p $D
  cd $D
  wget ${URL}${D}/ -O index.html >> ../../out.log 2>> ../../err.log
  cat index.html | egrep '<a href="[^"]*">[^<].*(\.nt|\.owl)(\.gz)?</a>' | sed 's/^.*<a href="[^"]*">\([^<].*\)<\/a>.*$/\1/' > files.txt
  rm index.html
  while read F; do
    echo "Downloading $F..." >> ../../out.log
    wget ${URL}${D}/${F} >> ../../out.log 2>> ../../err.log
  done < files.txt
  echo "Uncompressing files..." >> ../out.log
  gunzip *.gz >> ../out.log 2>> ../err.log
  rm files.txt
  cd ..
done < dirs.txt

rm dirs.txt

echo "Finished." >> ../out.log
