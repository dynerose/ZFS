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
export readonly ZFSPOOL="rpool"
export readonly ZFSMNTPOINT="/mnt"
export readonly ZFS_CRYPT="rpool_crypt"
# end / Constants

# Initialize / Variable
export VAR_UEFI=$FALSE
export VAR_LUKS=$FALSE
export VAR_MDM=$FALSE
VAR_VERBOSE=0

export VAR_USERNAME=username
export VAR_PASSWORD=password

VAR_ZFSMINDISK=1
VAR_ZFSTYPE="none"
VAR_ZFSDISKCOUNT=0
VAR_ZFSDISKLIST[0]=""

VAR_UBUNTU_VERSION=17.04
VAR_UBUNTU_RELEASE=17.04 # lsb_release -r
VAR_CODENAME=zesty # lsb_release -c

# trusty Ubuntu 14.04.5 LTS (Trusty Tahr)
# vivid  Ubuntu 15.04 (Vivid Vervet)
# xenial Ubuntu 16.04.3 LTS (Xenial Xerus)
# zesty  Ubuntu 17.04 (Zesty Zapus)
# IS_X64 uname -i x86_64

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
show_changes