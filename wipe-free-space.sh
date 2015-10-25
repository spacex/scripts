#!/bin/bash

BLOCK_SIZE=64M
RAND_BLOCK_SIZE=8M
#SIZE is in terms of BLOCK_SIZE, leave blank for fill
SIZE=
RAND_SIZE=

# WARNING:
# 
# Filling up all of the free space on a drive that is in use
# has serious performance and stability problems.

#This assumes that you have dd, mktemp, and tr installed and in PATH

# If not run as root, all free space may not be cleared
if [[ $(whoami) != "root" ]]; then
  echo "This must be run as root."
  exit -1
fi

# Make sure we have only one argument, and the directory exists
if [ $# -ne 1 -a ! -d "$1" ]; then
  if [ $# -ne 1 ]; then
    echo "Only one argument must be passed."
  fi
  echo "Please pass the mount point of the mounted filesystem."
  exit -1
fi

# Base dd invocation
DD="dd conv=notrunc,fdatasync status=progress"

echo "Creating tmp file to expand to fill all free space."
TMPFILE=$(mktemp --tmpdir=$1)

DD_COUNT=""
DD_RAND_COUNT=""
if [[ "${SIZE}" != "" ]]; then
  DD_COUNT="count=${SIZE}"
  DD_RAND_COUNT="count=${RAND_SIZE}"
fi

echo "Pass 1: All zeros"
${DD} if=/dev/zero of=${TMPFILE} bs=${BLOCK_SIZE} ${DD_COUNT}

echo "Pass 2: All ones"
${DD} if=/dev/zero bs=${BLOCK_SIZE} ${DD_COUNT} | tr '\0' '\377' | ${DD} of=${TMPFILE} bs=${BLOCK_SIZE}

echo "Pass 3: Random data"
${DD} if=/dev/urandom bs=${RANDOM_BLOCK_SIZE} of=${TMPFILE} ${DD_RAND_COUNT}

echo "Removing tmp file."
rm -f ${TMPFILE}
