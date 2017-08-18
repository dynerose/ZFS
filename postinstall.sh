#!/bin/bash
# postinstall.sh
# see postinstall.sh -h for info/help

# TOTO: --zfs zfs on root
# TODO: --bootstrap option(s) to install minimal bootable environment as alternative to --cp or --install opts
# TODO: --uefi untested/unfinished
# TODO: --swap to support creation of a swap volume on pool
# TODO: seperate core vs optional sets (rpool/home vs rpool/srv)
# TODO: --LUKS encrypt zfs
# TODO: --mdm raid boot

#----- Import Functions -----#

dir="$(dirname "$0")"

. $dir/functions/check
. $dir/functions/utilities
. $dir/doc/changes.list
. $dir/doc/changescreated.list

# Prompt Colors
BGREEN='\033[1;32m'
GREEN='\033[0;32m'
BRED='\033[1;31m'
RED='\033[0;31m'
BBLUE='\033[1;34m'
BLUE='\033[0;34m'
NORMAL='\033[00m'
PURPLE='\033[1;35m'
LBLUE='\033[1;36m'
YELLOW='\033[1;33m'
PS1="${BLUE}(${NORMAL}\w${BLUE}) ${NORMAL}\u${BLUE}@\h${RED}\$ ${NORMAL}"

DIALOG=dialog
PRINTF=`whereis "printf" | tr -s ' ' '\n' | grep "bin/""printf""$" | head -n 1`

# Constants
readonly VERSION="0.1 Alpha"
export readonly TRUE=0
export readonly FALSE=1
export readonly REQ_PKGS="cryptsetyp debootstrap gdisk zfs zfs-initramfs mdadm"

# Base set of packages to install after deboostrap
# Very annoying - can't use { } as in linux-{image,headers}-generic - expansion of variable fails in apt-get in Setup.sh,
# around line 1203 in this script.  So have to use individual packages names, linux-header-generic linux-image-generic and so on
# whois needed for mkpasswd
export BASE_PACKAGES="openssh-server openssl mc rsync parted linux-headers-generic linux-image-generic debian-keyring"
export readonly ZFSPOOL="rpool"
export readonly ZFSMNTPOINT="/mnt"
export readonly ZFS_CRYPT="rpool_crypt"
# end / Constants

# Initialize / Variable
export UEFI=$FALSE
export MDM=$FALSE
VERBOSE=0

ZFSMINDISK=1
ZFSTYPE="none"
ZFSDISKCOUNT=0
ZFSDISKLIST[0]=""


######################################################################################################
# Using LUKS for encryption (y/n) ? Please use a nice long complicated passphrase ...
# If enabled, will encrypt partition_swap (md raid) and partition_data (zfs)
# If PASSPHRASE is blank, will prompt for a passphrase
export LUKS=$TRUE
export PASSPHRASE="passphrase"
# Use detached headers ?  If y then save LUKS headers in /root/headers
# NOTE: not working yet - have to figure out /etc/crypttab and /etc/initramfs-tools/conf.d/cryptroot
export DETACHEDHEADERS=""
 
# Randomize or zero out the disks for LUKS ?  (y/n)
# Randomizing makes for much better encryption
# Zeroing is good for prepping to create an OVA file, makes for better compression
# NOTE: Can only choose one, not both !
RANDOMIZE=$FALSE
ZERO=$FALSE
######################################################################################################

# System name (also used for mdadm raid set names and filesystem LABELs)
# Note: Only first 10 chars of name will be used for LABELs and the pool name
SYSNAME=zfs"
UBUNTU_VERSION=17.04
UBUNTU_RELEASE=17.04 # lsb_release -r
CODENAME=zesty # lsb_release -c

# trusty Ubuntu 14.04.5 LTS (Trusty Tahr)
# vivid  Ubuntu 15.04 (Vivid Vervet)
# xenial Ubuntu 16.04.3 LTS (Xenial Xerus)
# zesty  Ubuntu 17.04 (Zesty Zapus)
# IS_X64 uname -i x86_64


# Userid, full name and password to create in new system. If UPASSWORD is blank, will prompt for password
export USERNAME="username"
export UCOMMENT='Main User'
export PASSWORD=""

######################################################################################################
# Force the swap partition size for each disk in MB if you don't want it calculated
# If you want Resume to work, total swap must be > total ram
# For 2 disks, will use raid-1 striped, so total = size_swap * num_disks
# For 3+ disks, will use raid-10, so total = size_swap * num_disks / 2
# Set to 0 to disable (SIZE_SWAP = swap partitions, SIZE_ZVOL = zfs zvol in ${POOLNAME})
SIZE_SWAP=100
# Use a zfs volume for swap ?  Set the total size of that volume here.
# NOTE: Cannot be used for Resume
SIZE_ZVOL=100
 
# Use zswap compressed page cache in front of swap ? https://wiki.archlinux.org/index.php/Zswap
USE_ZSWAP="\"zswap.enabled=1 zswap.compressor=lz4 zswap.max_pool_percent=25\""
# USE_ZSWAP=
######################################################################################################
######################################################################################################
# Partition numbers and sizes of each partition in MB
PARTITION_EFI=1
PARTITION_GRUB=2
PARTITION_BOOT=3
PARTITION_SWAP=4
PARTITION_DATA=5
PARTITION_RSVD=9

SIZE_EFI=256
SIZE_GRUB=5
SIZE_BOOT=500
######################################################################################################
################## End of user settable variables ##################

# end / Variable

#----- Fancy Messages -----#
show_error(){
# echo -e 
    $PRINTF "$BRED  ** error ---> $@ $NORMAL\n"
}
show_info(){
    $PRINTF "$BGREEN ** info ---> $@ $NORMAL\n"

}
show_warning(){
    $PRINTF "$YELLOW ** warning ---> $BGREEN $@ $YELLOW.. $NORMAL\n"
}
show_question(){
    $PRINTF "$BBLUE ** question ---> $@ $NORMAL\n"
}
show_success(){
    $PRINTF "$PURPLE ** succes ---> $@ $NORMAL\n"
}
show_header(){
    $PRINTF "$LBLUE $@ $NORMAL\n"
}
show_listitem(){
    $PRINTF "\033[0;37m$@ $NORMAL\n"
}

# show_warning "show_warning"
# SetDialogs
# check_dependencies
# show_changes
show_warning "\nUnmounting All attached to %s & %s..." "$ZFSMNTPOINT" "$UBIQUITYMNTPOINT"
