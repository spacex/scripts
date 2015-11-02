#!/bin/bash

#Usage:
# build-all.sh <list of src rpms>
# build-all.sh <file containing list of rpms>

OUTPUT_DIR=${OUTPUT_DIR:-$(pwd)/output/}

function build_src_rpm() {
  rpm -ivh "$1"
  pushd $(pwd)
  cd /usr/src/redhat/SPECS
  rpmbuild -bp --target=noarch *.spec
  OUTPUT=${OUTPUT_DIR}/$(basename $1)
  mkdir ${OUTPUT}
  mv ../BUILD ${OUTPUT}/
  mv ../SOURCES ${OUTPUT}/
  mv *.spec ${OUTPUT}/
  mkdir ../BUILD
  mkdir ../SOURCES
  popd
}

if [ ! -d ${OUTPUT_DIR} ]; then
  mkdir ${OUTPUT_DIR}
fi

if [ $# -gt 1 ]; then
  for f in $@; do
	echo $f
    build_src_rpm $f &> ${OUTPUT_DIR}/$(basename $f).log
  done
elif [ $# == 1 ]; then
  if [[ "${1%%\.rpm}" != "$1" ]]; then
	echo $1
    build_src_rpm $1 &> ${OUTPUT_DIR}/$(basename $1).log
  else
    for f in `cat $1`; do
      echo $f
      build_src_rpm $f &> ${OUTPUT_DIR}/$(basename $f).log
    done
  fi
else
  echo "Provide files to process."
fi
