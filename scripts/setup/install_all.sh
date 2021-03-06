#!/usr/bin/env bash

OPT_DIR_PARAM=$1

# get setup directory path
SETUP_DIR=$(dirname "${BASH_SOURCE[0]}")
SETUP_DIR=$(readlink -f "${SETUP_DIR}")

# find the environment variables
. "${SETUP_DIR}/env.sh" "${OPT_DIR_PARAM}"

##################################################################





echo "-----------------------------------------------"
echo "-- using HOLBA_OPT_DIR=${HOLBA_OPT_DIR}"
echo "-----------------------------------------------"


# install the base (poly, hol4 and basic setup)
echo
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo

"${SETUP_DIR}/install_base.sh"

echo
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo


# install Z3
echo "-----------------------------------------------"
echo "--------------- installing Z3 -----------------"
echo "-----------------------------------------------"
"${SETUP_DIR}/install_z3.sh"
echo


# install gcc_arm8
echo "-----------------------------------------------"
echo "------------ installing gcc_arm8 --------------"
echo "-----------------------------------------------"
"${SETUP_DIR}/install_gcc_arm8.sh"
echo


