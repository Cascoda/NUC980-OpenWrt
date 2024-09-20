#!/bin/sh


die() { echo "Error: " "$*" 1>&2 ; exit 1; }

echo '=== Welcome to the Cascoda Border Router release script! ==='
echo ''


cat feeds.conf.default | grep src-link | while read line
do
	echo $line
	echo 'Is this repository up to date & on the latest master/main branch?'
	read -p 'y/n: ' -r REPLY < /dev/tty
	echo $REPLY
	[ "$REPLY" = "y" ] || die "Repository not up to date"
done

echo 'Is /home/alexandru/knx-iot-code-gen up to date & on the latest master/main branch?'
read -p 'y/n: ' -r REPLY < /dev/tty
echo $REPLY
[ "$REPLY" = "y" ] || die "Repository not up to date"

echo '=== All repositories are up to date! Validating version number... ==='
echo ''

rg CONFIG_VERSION_PRODUCT .config
echo 'Are you building the right product?'
read -p 'y/n: ' -r REPLY < /dev/tty
[ "$REPLY" = "y" ] || die "Product not updated!"

rg CONFIG_VERSION_NUMBER .config
echo 'Has the configuration version number been updated?'
read -p 'y/n: ' -r REPLY < /dev/tty
[ "$REPLY" = "y" ] || die "Version not updated!"


echo '=== All Checks Complete! Starting build! ==='
cd ../knx-iot-mqtt-proxy
bash generate.sh ../knx-iot-code-gen
cd ../openwrt

./scripts/feeds update -a
./scripts/feeds install -a
make clean
make -j12

IMAGE_PATH=bin/targets/ath79/generic/*upgrade.bin

cp $IMAGE_PATH ~/mnt/internal/software/Cascoda/hub-images/

