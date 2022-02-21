#!/bin/bash 

function error () {
    ./freshstart.sh -h
    echo "ERROR: $1" 1>&2
    exit
}

POSITIONAL_ARGS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--base)
            BASE_INSTALL=true
            shift 
            ;;
        -B|--bootpartition)
            BOOT_PARTITION="$2"
            shift 2
            ;;
        -d|--dual)
            DUAL_BOOT=true
            shift 
            ;;
        -c|--customs)
            CUSTOMIZATIONS=true
            shift 
            ;;
        -e|--efipartition)
            EFI_PARTITION="$2"
            shift 2
            ;;
        -H|--hostname)
            HOSTNAME="$2"
            shift 2
            ;;
        -p|--password)
            exit
            PASSWORD="$2"
            shift 2
            ;;
        -r|--rootpassword)
            ROOT_PASSWORD="$2"
            shift 2
            ;;
        -R|--rootpartition)
            ROOT_PASSWORD="$2"
            shift 2
            ;;
        -u|--username)
            USERNAME="$2"
            shift 2
            ;;
        -h|--help)
            echo -e "
Script for installing Arch linux with/without customizations.

\t./freshstart.sh [options]

Options:

\t-b, --base\t\t\t\t- (re-)install base Arch linux. If not specified (re-)install only customizations (e.g. cutomizations_install.sh).
\t-B, --bootpartition (dev)\t\t- [MANDATORY] specify boot partition.
\t-d, --dual\t\t\t\t- install linux alongside other OS. If not specified - overwrite the disk.
\t-c, --customs\t\t\t\t- install customizations specified in other script files.
\t-e, --efipartition (efi_partition)\t- [MANDATORY] Required only if -d|--dual is specified. Specify EFI disk partition.
\t-H, --hostname (name)\t\t\t- [MANDATORY] specify hostname for the machine.
\t-p, --password (pass)\t\t\t- [MANDATORY] specify password for the new admin user.
\t-r, --rootpassword (pass)\t\t- specify root password.
\t-R, --rootpartition (dev)\t\t- [MANDATORY] specify root partition (e.g. /dev/sda1).
\t-u, --username (name)\t\t\t- [MANDATORY] specify new admin user.
\t-h, --help\t\t\t\t- display this screen.
"
            exit 0
            ;;
        -*|--*)
            echo "Unknown option $1"
            exit 1
            ;;
        *)
            POSITIONAL_ARGS="$POSITIONAL_ARGS $1" # save positional args
            shift # past argument
            ;;
    esac
done

if [ ! "$BASE_INSTALL" ] && [ ! "$CUSTOMIZATIONS" ];
then
    error "At least one of the options has to be specified: -c or -b"
fi

if [ "$BASE_INSTALL" ]
then
    [ ! "$BOOT_PARTITION" ] && error "Boot partition was not specified"
    [ ! "$EFI_PARTITION" ] && error "EFI partition was not specified"
    [ ! "$ROOT_PARTITION" ] && error "Root partition was not specified"
    [ ! "$USERNAME" ] && error "Username for admin user was not specified"
    [ ! "$HOSTNAME" ] && error "Hostname for the machine was not specified"
    [ ! "$PASSWORD" ] && error "Password for admin user was not specified"

    echo "Installing base arch linux"
    #./base_install.sh $BOOT_PARTITION $EFI_PARTITION $ROOT_PARTITION $USERNAME $HOSTNAME $PASSWORD $ROOT_PASSWORD $DUAL_BOOT
fi
