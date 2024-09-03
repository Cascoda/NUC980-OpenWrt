#!/bin/sh
./scripts/feeds update -a
./scripts/feeds install -a
make clean
make -j12
#More logs to file, for debugging
#make -j12 V=sc -k 2>&1 | tee build_log.txt 
cmatrix -b
