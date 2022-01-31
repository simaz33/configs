#!/bin/bash 

POSITIONAL_ARGS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--base)
            BASE_INSTALL=true
            shift 
            ;;
        -d|--dual)
            DUAL_BOOT=true
            shift 
            ;;
        -D|--disk)
            DEVICE="$2"
            shift 2
            ;;
        -e|--efipartition)
            EFI_PARTITION="$2"
            shift 2
            ;;
        -p|--password)
            PASSWORD=true
            shift
            ;;
        -r|--rootpassword)
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
\t-d, --dual\t\t\t\t- install linux alongside other OS. If not specified - overwrite the disk.
\t-D, --disk (dev)\t\t\t- [MANDATORY] specify disk on which to install Arch linux.
\t-e, --efipartition (efi_partition)\t- [CONDITIONAL] Required only if -d|--dual is specified. Specify EFI disk partition.
\t-p, --password (pass)\t\t\t- [MANDATORY] specify password for the new admin user.
\t-r, --rootpassword (pass)\t\t- specify root password.
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

if [ "$BASE_INSTALL" ]
then
    echo "Installing base arch linux"
fi
