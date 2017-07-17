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
function SetDialogsus()
{
        [ -x "$(which ${DIALOG%% *})" ] || DIALOG=dialog
    DIALOG=$($DIALOG --menu "Which tool for next run?" 20 60 12 2>&1 \
            whiptail        "dialog boxes from shell scripts" >/dev/tty \
            dialog        "dialog boxes from shell with ncurses" \
            gdialog        "dialog boxes from shell with Gtk" \
            kdialog        "dialog boxes from shell with Kde" ) || exit
    clear;echo "Choosed: $DIALOG."

    echo "Choosed: $DIALOG."
}

# unmount_all
# show_error "show_error"
# show_info "show_info"
# show_warning "show_warning"
# show_question "show_question"
# show_success "show_success"
# show_header "show_header"
# show_listitem  "show_listitem"
# show_warning "show_warning"

show_success 'Init 1.'
show_success ${DIALOG}
SetDialogs
show_success 'Done.'
show_success ${DIALOG}
