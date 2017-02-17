#!/bin/bash

###################################################
# The author of this script is free5lot
# Licence is GPL 2 (or later).
# https://github.com/free5lot/
###################################################

if [ -f /etc/fedora-release ] ; then
	DIST='Fedora'
	LINUX_HEADER_DIR="/lib/modules/$(uname -r)/build"

elif [ -f /etc/debian_version ] ; then
	DIST="Debian"
	LINUX_HEADER_DIR="${LINUX_HEADER_DIR:-/usr/src/linux-headers-$(uname -r)}"

else
	echo "Could not determine Linux distribution!"
	exit 1
fi


# Check if $LINUX_HEADER_DIR exists
if [ ! -d "$LINUX_HEADER_DIR" ]; then
	echo "============================================="
	echo "Error: Linux headers directory was not found."
	echo "Searched for: $LINUX_HEADER_DIR"
	echo ""
	echo "Try to install it to solve this problem,     "
	echo "On Ubuntu:"
	echo "sudo apt-get install linux-headers-`uname -r`"
	echo ""
	echo "On Fedora:"
	echo "dnf install kernel-devel"
	echo "============================================="
	exit 1;
fi


# Make hid-apple.ko module
echo "============================================="
echo "Starting kernel module make"
make -C "$LINUX_HEADER_DIR" M="$(pwd)" modules

# Remove generated files
echo "============================================="
echo "Removing useless generated files"

rm -v -R ".tmp_versions"

rm -v ".hid-apple.ko.cmd"
rm -v ".hid-apple.o.cmd"
rm -v ".hid-apple.mod.o.cmd"

rm -v "hid-apple.mod.c"
rm -v "hid-apple.mod.o"

rm -v "hid-apple.o"

rm -v "Module.symvers"
rm -v "modules.order"

echo "============================================="
