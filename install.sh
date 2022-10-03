#!/bin/bash

###################################################
# The author of this script is free5lot
# Licence is GPL 2 (or later).
# https://github.com/free5lot/
###################################################

# Constants
MODULE_FILENAME="hid-apple.ko"
MODULE_LSMOD_NAME="hid_apple"
MODPROBE_CONFIG_PATH="/etc/modprobe.d/hid_apple.conf"
MODULE_OPTIONS_PATH="/sys/module/hid_apple/parameters"
PLACE_FOR_MODULE="/lib/modules/$(uname -r)/kernel/drivers/hid"

# Let's pre-set these few:
SWAP_FN_F13_INSERT=0
SWAP_FN_LEFTCTRL=0
EJECTCD_AS_DELETE=0
LOCK_AS_DELETE=0

# Pre-checks -------------------------------------------
# Check if place for module exists in system
if [ ! -d "$PLACE_FOR_MODULE" ]; then
	echo "=================================================="
	echo "Error: System directory for modules was not found."
	echo "Directory tested: $PLACE_FOR_MODULE"
	echo ""
	echo "Maybe you're using unsuitable GNU/Linux distro?"
	echo "=================================================="
	exit;
fi

# Check if module is used at all
SEARCH_MODULE_RESULT=`lsmod | grep "$MODULE_LSMOD_NAME" | wc -l`
if [ $SEARCH_MODULE_RESULT -lt "1" ]; then
	echo "============================================="
	echo "Warning: The Apple hid module is not currently"
	echo "being used."
	echo "Module name: $MODULE_LSMOD_NAME"
	echo ""
	echo "Maybe you don't need this patched module"
	echo "============================================="
	#exit; # warning only
fi

# Check if MODULE_FILENAME exists
if [ ! -f "$MODULE_FILENAME" ]; then
	echo "============================================="
	echo "Error: Compiled patched module was not found."
	echo "Kernel module filename: MODULE_FILENAME"
	echo ""
	echo "Try to build it with this command:"
	echo "./build"
	echo "============================================="
	exit;
fi

# Main part --------------------------------------------

echo "============================================="

echo "Only one of fn/f13 lctrl/fn swaps are allowed. Choose one: "
read -e -p "1. Do you want to set F13 to Fn and Fn to Insert (function) keys (1); swap Left Control (ctrl) and Fn (function) keys (2); or neither? [1/2/n]: " -i "n" response
    case $response in
        [1]* ) SWAP_FN_F13_INSERT=1; echo "Yes, swap fn/f13";;
        [2]* ) SWAP_FN_LEFTCTRL=1; echo "Yes, swap lctrl/fn";;
        * )    SWAP_FN_F13_INSERT=0; SWAP_FN_LEFTCTRL=0; echo "Neither (default)";
    esac
echo ""

echo "NOTE: If you don't have Eject key, select No (default)"
read -e -p "3. Do you want to use Eject-CD key as Delete? [y/N]: " -i "N" yn
    case $yn in
        [Yy]* ) EJECTCD_AS_DELETE=1; echo "Yes, use it";;
        [Nn]* ) EJECTCD_AS_DELETE=0; echo "No, don't";;
        * )   EJECTCD_AS_DELETE=0; echo "No (default)";;
    esac
echo ""

echo "NOTE: If you don't have Lock key, select No (default)"
read -e -p "3. Do you want to use Lock key as Delete? [y/N]: " -i "N" yn
    case $yn in
        [Yy]* ) LOCK_AS_DELETE=1; echo "Yes, use it";;
        [Nn]* ) LOCK_AS_DELETE=0; echo "No, don't";;
        * )   LOCK_AS_DELETE=0; echo "No (default)";;
    esac

echo ""
echo "============================================="
echo "Test run before installation in the system"
echo ""
echo "If you faced any problems and the keyboard doesn't work"
echo "simply reboot the computer and all the changes will be reverted"
echo ""

# save old options
SAVED_OPTIONS=""
if [ -f "$MODULE_OPTIONS_PATH/fnmode" ]; then
	prev_fnmode=`cat "$MODULE_OPTIONS_PATH/fnmode"`
	SAVED_OPTIONS="$SAVED_OPTIONS fnmode=\"$prev_fnmode\""
fi
if [ -f "$MODULE_OPTIONS_PATH/iso_layout" ]; then
	prev_iso_layout=`cat "$MODULE_OPTIONS_PATH/iso_layout"`
	SAVED_OPTIONS="$SAVED_OPTIONS iso_layout=\"$prev_iso_layout\""
fi
if [ -f "$MODULE_OPTIONS_PATH/swap_opt_cmd" ]; then
	prev_swap_opt_cmd=`cat "$MODULE_OPTIONS_PATH/swap_opt_cmd"`
	SAVED_OPTIONS="$SAVED_OPTIONS swap_opt_cmd=\"$prev_swap_opt_cmd\""
fi

sudo rmmod "$MODULE_LSMOD_NAME"
sudo insmod "./$MODULE_FILENAME" $SAVED_OPTIONS swap_fn_leftctrl="$SWAP_FN_LEFTCTRL" ejectcd_as_delete="$EJECTCD_AS_DELETE" lock_as_delete="$LOCK_AS_DELETE" swap_fn_f13_insert="$SWAP_FN_F13_INSERT"

echo "The patched module was loaded."
echo "Please test the keyboard (mainly the modified keys)."
read -e -p "Does the keyboard work as expected? [Y/n]: " -i "Y" yn
    case $yn in
        [Nn]* )
        echo "No, keyboard works incorrectly.";
        echo "=> The installation was canceled by user.";
        echo "=> If you have any keyboard problems simply reboot the computer.";
        exit;;
    esac

# Install hid-apple.ko module
echo "============================================="
echo "Module installation ..."
echo "1. Making a backup of original module as $MODULE_FILENAME.prev"
if [ -f "$PLACE_FOR_MODULE/$MODULE_FILENAME.prev" ]; then
	echo "Skipped: a backup file already exists."
else
	sudo cp -v "$PLACE_FOR_MODULE/$MODULE_FILENAME" "$PLACE_FOR_MODULE/$MODULE_FILENAME.prev"
fi


echo "2. Replacing the old module $MODULE_FILENAME"
sudo cp -v "$MODULE_FILENAME" "$PLACE_FOR_MODULE/$MODULE_FILENAME"

echo "3. Updating initramfs"
sudo update-initramfs -u

echo "4. Adding options to modprobe.d config"

SEARCH_RESULT_FN=`cat "$MODPROBE_CONFIG_PATH" | grep "swap_fn_f13_insert" | wc -l`
if [ $SEARCH_RESULT_FN -gt "0" ]; then
	echo "Warning: Option 'swap_fn_f13_insert' is already set in $MODPROBE_CONFIG_PATH"
	echo "You should change this option manually in this file"
else
	echo "" | sudo tee -a "$MODPROBE_CONFIG_PATH"
	echo "options hid_apple swap_fn_f13_insert=$SWAP_FN_F13_INSERT" | sudo tee -a "$MODPROBE_CONFIG_PATH"
fi

SEARCH_RESULT_SWAP=`cat "$MODPROBE_CONFIG_PATH" | grep "swap_fn_leftctrl" | wc -l`
if [ $SEARCH_RESULT_SWAP -gt "0" ]; then
	echo "Warning: Option 'swap_fn_leftctrl' is already set in $MODPROBE_CONFIG_PATH"
	echo "You should change this option manually in this file"
else
	echo "" | sudo tee -a "$MODPROBE_CONFIG_PATH"
	echo "options hid_apple swap_fn_leftctrl=$SWAP_FN_LEFTCTRL" | sudo tee -a "$MODPROBE_CONFIG_PATH"
fi

SEARCH_RESULT_EJECTCD=`cat "$MODPROBE_CONFIG_PATH" | grep "ejectcd_as_delete" | wc -l`
if [ $SEARCH_RESULT_EJECTCD -gt "0" ]; then
	echo "Warning: Option 'ejectcd_as_delete' is already set in $MODPROBE_CONFIG_PATH"
	echo "You should change this option manually in this file"
else
	echo "" | sudo tee -a "$MODPROBE_CONFIG_PATH"
	echo "options hid_apple ejectcd_as_delete=$EJECTCD_AS_DELETE" | sudo tee -a "$MODPROBE_CONFIG_PATH"
fi

SEARCH_RESULT_LOCK=`cat "$MODPROBE_CONFIG_PATH" | grep "lock_as_delete" | wc -l`
if [ $SEARCH_RESULT_LOCK -gt "0" ]; then
	echo "Warning: Option 'lock_as_delete' is already set in $MODPROBE_CONFIG_PATH"
	echo "You should change this option manually in this file"
else
	echo "" | sudo tee -a "$MODPROBE_CONFIG_PATH"
	echo "options hid_apple lock_as_delete=$LOCK_AS_DELETE" | sudo tee -a "$MODPROBE_CONFIG_PATH"
fi


echo "5. All done"
echo ""
echo "To test the updated initramfs you need to reboot"

echo "============================================="
