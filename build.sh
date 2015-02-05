#!/bin/bash

LINUX_HEADER_DIR="/usr/src/linux-headers-$(uname -r)"

if [ ! -d "$LINUX_HEADER_DIR" ]; then
	echo "============================================="
	echo "Error: Linux headers directory was not found."
	echo "Searched for: $LINUX_HEADER_DIR"
	echo ""
	echo "Try to install it to solve this problem, e.g:"
	echo "sudo apt-get install linux-headers-`uname -r`"
	echo "============================================="
	exit;
fi

echo "============================================="
echo "Starting kernel module make"
# Make hid-apple.ko module
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
