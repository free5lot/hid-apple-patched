## A patched hid-apple kernel module
----------
_**The instructions of build, check, install will be posted a bit later.**_

__UPDATE Oct 2015: The patch was modified for kernel 4.2 and support of Macbook Pro 2015. Thanks to @Aetf!__


### About
A patched version of hid-apple allows GNU/Linux user **to swap the FN and left Control keys** on Macbook Pro, external Apple keyboards and probably other Apple devices.

The patch was created by [free5lot](https://github.com/free5lot) under GPL 2 (or later) licence. I hope it'll go to upstream kernel, so more GNU/Linux users could make their keyboards more comfortable for them.

This project was inspired by a [similar patch](https://github.com/JanmanX/HID-Apple) made by [JanmanX (Jan Meznik)](https://github.com/JanmanX). His patch has the same idea but a bit different realization. I'd like to thank him for solving this problem in the first place and making his solution public.


### Problem
This patch was created because Apple keyboards on Macbook Pro and external keyboard models have an awful location of special keys. To make it more habitual and friendly the fn key and left Control key should be swapped.

The swapping of Alt (Option) and Command is already possible without a patch by setting swap_opt_cmd=1 option to hid-apple kernel module in current versions of Linux kernel.
More information is available at [Ubuntu's help website](https://help.ubuntu.com/community/AppleKeyboard#Mapping_keys_.28Insert.2C_Alt.2C_Cmd.2C_etc..29).


### Installation

To build make sure you have the kernel development packages for your
distribution installed.

If your kernel header directory is different from the default one in
the Makefile export the correct one:

```
export KERNEL_HEADER_DIR=/path/to/kernel/header/dir
```

To build:

```
make
```

To install:

```
make install
```

The install will put the module in the 'extra' sub-directory and the
default unpatched module will take priority. To give your newly built
module priority create a file '/etc/depmod.d/hid-apple.conf' and add
the following line:

```
override hid_apple * extra
```

Then run:

```
sudo depmod -a
```

### Topicality
A lot of GNU/Linux users of Macbook Pro and/or external (wireless) keyboards face the problem of uncomfortable placement of keys.
Here are some topics about swap of fn and left control keys, and all of them are checked **unsolved or/and closed**.
- [Ubuntu Forums - swap fn and control key](http://ubuntuforums.org/showthread.php?t=785643)
- [Stack Overflow - Is there any way to swap the fn (function) and control keys in linux on an macbook pro?](https://stackoverflow.com/questions/4767895/is-there-any-way-to-swap-the-fn-function-and-control-keys-in-linux-on-an-macbo)
- [Ubuntu Forums - Swap fn and control keys](http://ubuntuforums.org/showthread.php?t=2176248) 
- [Organic Design - Apple wireless keyboard on Linux](http://www.organicdesign.co.nz/Apple_wireless_keyboard_on_Linux)

So this patch is probably essential and desirable by users.






