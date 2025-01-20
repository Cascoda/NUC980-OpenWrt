#!/bin/sh


./scripts/feeds update -a
./scripts/feeds install -a
rm -rf build_dir/target-mips_24kc_musl/libknx-iot-mqtt-2-way-1.0/
make

