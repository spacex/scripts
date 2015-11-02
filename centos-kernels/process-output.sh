#!/bin/bash

#Usage:
# process-output.sh <list of output directories>
# process-output.sh <file containing list of rpms>

KDIR_DIR=${KDIR_DIR:-$(pwd)/kdir}
OUTPUT_DIR=${OUTPUT_DIR:-$(pwd)/output}

function process_output() {
  f=$(basename $1)
  kver=${f%%.src.rpm}
  kdir=${kver##kernel-}
  echo $kver
  pushd $(pwd) &> /dev/null
  cd ${OUTPUT_DIR}
  mv $f $kver
  mv $f.log $kver.log
  tar -cjf $kver.tar.bz2 $kver
  cp -r $kver/BUILD/kernel-*/linux-* ${KDIR_DIR}/$kdir
  cd ${KDIR_DIR}
  tar -cjf $kdir.tar.bz2 $kdir
  popd &> /dev/null
}

if [ ! -d ${OUTPUT_DIR} ]; then
  echo "No output to process."
fi

if [ ! -d ${KDIR_DIR} ]; then
  mkdir ${KDIR_DIR}
fi

if [ $# -gt 1 ]; then
  for f in $@; do
	echo $f
    process_output $f
  done
elif [ $# == 1 ]; then
  if [[ "${1%%\.rpm}" != "$1" ]]; then
    if [ -d "$1" ]; then
      echo $1
      process_output $1
    fi
  else
    for f in `cat $1`; do
	  echo $f
      process_output $f
    done
  fi
else
  echo "Provide files to process."
fi

