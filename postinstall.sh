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

. $dir/functions/utilities

# Prompt Colors
BGREEN='\[\033[1;32m\]'
GREEN='\[\033[0;32m\]'
BRED='\[\033[1;31m\]'
RED='\[\033[0;31m\]'
BBLUE='\[\033[1;34m\]'
BLUE='\[\033[0;34m\]'
NORMAL='\[\033[00m\]'
PS1="${BLUE}(${NORMAL}\w${BLUE}) ${NORMAL}\u${BLUE}@\h${RED}\$ ${NORMAL}"

# Constants
readonly VERSION="0.1 Alpha"
readonly TRUE=0
readonly FALSE=1
readonly REQ_PKGS="debootstrap gdisk zfs zfs-initramfs"
export readonly ZFSPOOL="rpool"
export readonly ZFSMNTPOINT="/mnt"
export readonly ZFS_CRYPT="rpool_crypt"
# end / Constants

# Initialize / Variable
VAR_UEFI=$FALSE
VAR_LUKS=$FALSE
VAR_MDM=$FALSE
VAR_VERBOSE=0

VAR_USERNAME=username
VAR_PASSWORD=password

VAR_MINDISK=2


# end / Variable

#----- Fancy Messages -----#
show_error(){
echo -e "\033[1;31m$@\033[m" 1>&2
033[1;31m
}
show_info(){
echo -e "\033[1;32m$@\033[0m"
}
show_warning(){
echo -e "\033[1;33m$@\033[0m"
}
show_question(){
echo -e "\033[1;34m$@\033[0m"
}
show_success(){
echo -e "\033[1;35m$@\033[0m"
}
show_header(){
echo -e "\033[1;36m$@\033[0m"
}
show_listitem(){
echo -e "\033[0;37m$@\033[0m"
}

unmount_all
