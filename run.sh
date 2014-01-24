#!/bin/bash
#
# Usage (specifying release):
#
#     $ ./run.sh 2
#
# Usage (default release):
#
#     $ ./run.sh
#

RELEASE=2

if [ "$1" != "" ] ; then
  RELEASE=$1
fi

URL=http://download.bio2rdf.org/release/$RELEASE/

DIR=files/$RELEASE

rm -f $DIR/err.log $DIR/out.log

mkdir -p $DIR
cd $DIR

echo "Downloading Index..." >> out.log

wget $URL -O index.html >> out.log 2>> err.log

cat index.html | egrep '<a href="[^"]*">[^<].*/</a>' | sed 's/^.*<a href="[^"]*">\([^<].*\)\/<\/a>.*$/\1/' > dirs.txt
rm index.html

while read D; do
  echo "Accessing $D..." >> out.log
  mkdir -p $D
  cd $D
  wget ${URL}${D}/ -O index.html >> ../out.log 2>> ../err.log
  cat index.html | egrep '<a href="[^"]*">[^<].*(\.nt|\.owl)(\.gz)?</a>' | sed 's/^.*<a href="[^"]*">\([^<].*\)<\/a>.*$/\1/' > files.txt
  rm index.html
  while read F; do
    echo "Downloading $F..." >> ../out.log
    wget ${URL}${D}/${F} >> ../out.log 2>> ../err.log
  done < files.txt
  echo "Uncompressing files..." >> ../out.log
  gunzip *.gz >> ../out.log 2>> ../err.log
  rm files.txt
  cd ..
done < dirs.txt

rm dirs.txt

echo "Finished." >> out.log
