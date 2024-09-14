#!/usr/bin/env bash


# Script for creating a bootable drive for windows
#
# TODO:
# 1) Display numbered list of /dev/<disks>
# 2) Let user select device to use
# 3) Get MOUNT_POINT dynamically
# 4) Eject disk image artefact after completion


usage() {
    echo "Usage: $0 <disk_name> <iso_path>"
    echo "Example: $0 disk4 ~/Downloads/Win11_23H2_English_x64v2.iso"
    exit 1
}

if [ "$#" -ne 2 ]; then
    usage
fi

DEV="$1"
ISO_PATH="$2"

echo "Erasing $DEV and creating a new exFAT partition named 'WIN11'..."
diskutil eraseDisk exFAT "WIN11" GPT "/dev/$DEV"
if [ $? -ne 0 ]; then
    echo "Error: Failed to erase disk $DEV."
    exit 1
fi

echo "Creating sources directory on /Volumes/WIN11..."
mkdir -p /Volumes/WIN11/sources
if [ $? -ne 0 ]; then
    echo "Error: Failed to create sources directory."
    exit 1
fi

echo "Mounting ISO at $ISO_PATH..."
hdiutil mount "$ISO_PATH"
if [ $? -ne 0 ]; then
    echo "Error: Failed to mount ISO."
    exit 1
fi

MOUNT_POINT="CCCOMA_X64FRE_EN-US_DV9"
if [ -z "$MOUNT_POINT" ]; then
    echo "Error: Failed to find the mount point for the ISO."
    exit 1
fi

echo "Mount point found: /Volumes/$MOUNT_POINT"

rsync -vha --progress "/Volumes/$MOUNT_POINT/" /Volumes/WIN11
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy files."
    exit 1
fi

echo "Unmounting the ISO..."
hdiutil unmount "/Volumes/$MOUNT_POINT"
if [ $? -ne 0 ]; then
    echo "Error: Failed to unmount ISO."
    exit 1
fi

# echo "Ejecting virtual disk...."
# diskutil eject -- needs a virtual disk name --
# if [ $? -ne 0 ]; then
#     echo "Error: Failed to unmount ISO."
#     exit 1
# fi

echo "Successfully created bootable drive!"
