#!/bin/sh
./scripts/feeds update -a
./scripts/feeds install -a
make clean
make
cmatrix -b
