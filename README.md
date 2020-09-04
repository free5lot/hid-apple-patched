## A patched hid-apple kernel module
----------
__UPDATE Jun 2020: New feature added (`swap_fn_f13_insert`) to move fn key to F13 and make fn Insert. Thanks to @smaslennikov!__

__UPDATE May 2020: Part of the patch (`swap_fn_leftctrl`) was submitted and probably accepted to the upstream kernel. Thanks to the maintainer Jiri Kosina.__

__UPDATE Mar 2020: Now it works with Apple Magic Keyboard 2 in both USB and Bluetooth modes. Thanks to @almson!__

__UPDATE Dec 2019: If one has issues building for Fedora, please take a look at [this information](https://github.com/free5lot/hid-apple-patched/issues/55)__

__UPDATE Apr 2017: Works on Arch too, for useful information on this [proceed here](https://github.com/free5lot/hid-apple-patched/issues/31)__

__UPDATE May 2016: DKMS support added (tested on Ubuntu 16.04). Thanks to @almson!__

__UPDATE Dec 2015: An option to use the right Alt key as right ctrl was added. Thanks to @sami-mw!__

__UPDATE Oct 2015: The patch was modified for kernel 4.2 and support of Macbook Pro 2015. Thanks to @Aetf!__


### About

A patched version of hid-apple allows GNU/Linux user **to swap the FN and left Control keys and some other mapping tweaks** on Macbook Pro, external Apple keyboards and probably other Apple devices.

The patch was created by [free5lot](https://github.com/free5lot) under GPL 2 (or later) licence. I hope it'll go to upstream kernel, so more GNU/Linux users could make their keyboards more comfortable for them.

This project was inspired by a [similar patch](https://github.com/JanmanX/HID-Apple) made by [JanmanX (Jan Meznik)](https://github.com/JanmanX). His patch has the same idea but a bit different realization. I'd like to thank him for solving this problem in the first place and making his solution public.


### Problem

This patch was created because Apple keyboards on Macbook Pro and external keyboard models have an awful location of special keys. To make it more habitual and friendly the fn key and left Control key should be swapped.

The swapping of Alt (Option) and Command is already possible without a patch by setting swap_opt_cmd=1 option to hid-apple kernel module in current versions of Linux kernel.
More information is available at [Ubuntu's help website](https://help.ubuntu.com/community/AppleKeyboard#Mapping_keys_.28Insert.2C_Alt.2C_Cmd.2C_etc..29).


### Installation via [DKMS](https://en.wikipedia.org/wiki/Dynamic_Kernel_Module_Support) (recommended)

You may need to install git and dkms first, e.g. on Ubuntu: `sudo apt install git dkms`

Clone this repo and go into the source code directory:
```bash
git clone https://github.com/free5lot/hid-apple-patched
cd hid-apple-patched.git
```
Install module:
```bash
sudo dkms add .
sudo dkms build hid-apple/1.0
sudo dkms install hid-apple/1.0
```
Then, create file `/etc/modprobe.d/hid_apple.conf`. The following configuration emulates a standard PC layout:
```
options hid_apple fnmode=2
options hid_apple swap_fn_leftctrl=1
options hid_apple swap_opt_cmd=1
options hid_apple rightalt_as_rightctrl=1
options hid_apple ejectcd_as_delete=1
```
Finally, apply the new config file:
```bash
sudo update-initramfs -u
```
To (re-)load the module for immediate use, run
```bash
sudo modprobe -r hid_apple; sudo modprobe hid_apple
```
in one go (since the first command will disable your Apple keyboard). Alternatively, run `sudo reboot`, and the new module should be loaded on reboot.

The advantage of DKMS is that the module is automatically re-built after every kernel upgrade and installation. This method has been tested at least on Ubuntu 14.04 and 16.04.

### Note about installation on Mint and some others distros
DKMS config of this repo has option `DEST_MODULE_LOCATION` set to `/extra`. That's the place compiled patched module will be placed.
Distributions like Ubuntu, Fedora, Suse and some others ignore this parameter and use the proper distribution-specific directory instead. There will be no issues with these distributions.
Other distributions like Mint can use `DEST_MODULE_LOCATION` and may require an extra configuration file to be created by the user to force the use of patched version of `hid-apple` from `/extra` instead of original one.
In this case a new file `/etc/depmod.d/hid-apple.conf` should be created which tells depmod to prefer the module in `/extra` (see `man 5 depmod.d`):
```
override hid-apple * extra
```
The configuration file needs to be there before the module is installed using DKMS. 
See additional information about it from @bambinodino (who pointed this out) in the issue #67.

### Installation on Arch Linux

An AUR package [hid-apple-patched-git-dkms](https://aur.archlinux.org/packages/hid-apple-patched-git-dkms/) is available to automate the above installation steps.

See the [ArchWiki](https://wiki.archlinux.org/index.php/Apple_Keyboard#Use_a_patch_to_hid-apple) for install and configuration instructions specific to Arch Linux.

### Configuration

Permanent configuration is done in file `/etc/modprobe.d/hid_apple.conf`. The format is one option-value pair per line, like `swap_fn_leftctrl=1`. After writing to the file, do `sudo update-initramfs -u` and reboot.
Temporary configuration (applies immediately but is lost after rebooting) is possible by writing to virtual files in `/sys/module/hid_apple/parameters/`, like `echo 1 | sudo tee /sys/module/hid_apple/parameters/swap_fn_leftctrl`.

These options are from the original mainstream `hid-apple` module:
- `fnmode` - Mode of top-row keys
  - `0` = disabled
  - `1` = normally media keys, switchable to function keys by holding Fn key (Default)
  - `2` = normally function keys, switchable to media keys by holding Fn key
- `swap_opt_cmd` - Swap the Option (\"Alt\") and Command (\"Flag\") keys
  - `0` = as silkscreened, Mac layout (Default)
  - `1` = swapped, PC layout
- `iso_layout` - Enable/Disable hardcoded ISO-layout of the keyboard. Possibly relevant for international keyboard layouts
  - `0` = disabled, 
  - `1` = enabled (Default)

And these options were added in the patched version:
- `swap_fn_leftctrl` - Swap the Fn and left Control keys
  - `0` = as silkscreened, Mac layout (Default)
  - `1` = swapped, PC layout
- `rightalt_as_rightctrl` - Use the right Alt key as a right Ctrl key
  - `0` = as silkscreened, Mac layout (Default)
  - `1` = swapped, PC layout
- `ejectcd_as_delete` - Use Eject-CD key as Delete key, if available
  - `0` = disabled (Default)
  - `1` = enabled
- `swap_fn_f13_insert` - Swap the Fn and f13 keys, making Fn Insert and f13 Fn. For people who need Insert
  - `0` = disabled (Default), 
  - `1` = enabled

Note: `swap_fn_f13_insert` will be ignored if `swap_fn_leftctrl` is activated.

### Warning regarding Secure Boot (on non-Apple computers)

Some distributions, including Ubuntu 16.04, require that all modules are signed if Secure Boot is enabled. This breaks all third-party modules. There are various work-arounds, the easiest of which is to disable secure boot. This is currently not an issue on Apple computers, because Apple firmware does not support Secure Boot. See [issue #23](https://github.com/free5lot/hid-apple-patched/issues/23).


### Alternative, script-based installation

Build and install via scripts provided:
```bash
./build.sh

./install.sh
```
The script will create `/etc/modprobe.d/hid_apple.conf` for you, after asking a few questions.

This process needs to be repeated after installing a new kernel, after having booted into the new kernel.


### Alternative, makefile-based installation

0. To build make sure you have the kernel development packages for your
distribution installed. For example in Ubuntu these packages are called `linux-headers-*`, where "*" indicates the version and variant of the kernel.

1. The default kernel header directory in the Makefile is:
`/usr/src/linux-headers-$(shell uname -r)`, it automatically detects and uses the version of running kernel. 
It works in Ubuntu and a lot of other GNU/Linux distributions, just skip this step if you use them.
But if in your distribution the kernel header directory is different from the default one in
the Makefile export the correct one:
```bash
export LINUX_HEADER_DIR=/path/to/kernel/header/dir
```
2. To build:
```bash
make
```
3. To install:
```bash
make install
```
4. The install will put the module in the 'extra' sub-directory and the
default unpatched module will take priority. To give your newly built
module priority create a file '/etc/depmod.d/hid-apple.conf' and add
the following line:
```
override hid_apple * extra
```
Then run:
```bash
sudo depmod -a
```
5. And update of initramfs maybe required:
```bash
sudo update-initramfs -u
```


### Limitations

Macbook keyboards have no issues nor limitations regarding this patched module. But some External Keyboards (like Magic Keyboard A1255, A1644 and etc.) have a limitation (probably physical) related to the registration of keys from 5-T-G-B column with Fn+Command and Fn+Control being pressed simultaniously. More information can be found in [issue #6](https://github.com/free5lot/hid-apple-patched/issues/6). There is a walkaround - to release the Fn key first in these combinations and it should work fine.


### Topicality

A lot of GNU/Linux users of Macbook Pro and/or external (wireless) keyboards face the problem of uncomfortable placement of keys.
Here are some topics about swap of fn and left control keys, and all of them are checked **unsolved or/and closed**.
- [Ubuntu Forums - swap fn and control key](http://ubuntuforums.org/showthread.php?t=785643)
- [Stack Overflow - Is there any way to swap the fn (function) and control keys in linux on an macbook pro?](https://stackoverflow.com/questions/4767895/is-there-any-way-to-swap-the-fn-function-and-control-keys-in-linux-on-an-macbo)
- [Ubuntu Forums - Swap fn and control keys](http://ubuntuforums.org/showthread.php?t=2176248) 
- [Organic Design - Apple wireless keyboard on Linux](http://www.organicdesign.co.nz/Apple_wireless_keyboard_on_Linux)

So this patch is probably essential and desirable by users.


### Links and mentions
- [**ArchWiki** (documentation wiki of **Arch Linux**) - Apple Keyboard - Swap the Fn key and Left Ctrl key](https://wiki.archlinux.org/index.php/Apple_Keyboard#Use_a_patch_to_hid-apple) (added by @Aetf)).
- [Official documentation of **openSUSE** - Installation on a Mac](https://en.opensuse.org/SDB:Installation_on_a_Mac#Other_things) (added by Cornertwist)
- [Official documentation of **Ubuntu** - AppleKeyboard - Mapping keys](https://help.ubuntu.com/community/AppleKeyboard#Mapping_keys_.28Insert.2C_Alt.2C_Cmd.2C_etc..29) (added by @Aetf).

