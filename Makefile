##LINUX_HEADER_DIR ?=/usr/src/linux-headers-$(uname -r)
LINUX_HEADER_DIR=/usr/src/linux-headers-`uname -r`


obj-$(CONFIG_HID_APPLE)		+= hid-apple.o

all:
	make -C $(LINUX_HEADER_DIR) M=$(CURDIR) modules

clean:
	make -C $(LINUX_HEADER_DIR) M=$(CURDIR) clean

install:
	make -C $(LINUX_HEADER_DIR) M=$(CURDIR) modules_install
