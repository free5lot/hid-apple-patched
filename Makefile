LINUX_HEADER_DIR ?= /usr/src/linux-headers-$(shell uname -r)

obj-$(CONFIG_HID_APPLE)		+= hid-apple.o

all:
	make -C $(LINUX_HEADER_DIR) M=$(CURDIR) modules

clean:
	make -C $(LINUX_HEADER_DIR) M=$(CURDIR) clean

install:
	make -C $(LINUX_HEADER_DIR) M=$(CURDIR) modules_install

# - alternative installs

test-install:
	sudo /bin/sh -c "rmmod -f hid-apple && insmod hid-apple.ko"

test-uninstall:
	-sudo /bin/sh -c "rmmod -f hid-apple && modprobe hid-apple"
