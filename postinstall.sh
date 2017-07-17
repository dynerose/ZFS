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


# Constants
readonly VERSION="0.1 Alpha"
readonly TRUE=0
readonly FALSE=1

readonly REQ_PKGS="debootstrap gdisk zfs zfs-initramfs"
readonly ZFSPOOL="rpool"
readonly ZFSMNTPOINT="/mnt"
readonly ZFS_CRYPT="rpool_crypt"
# end / Constants

# Initialize / Variable

# end / Variable
