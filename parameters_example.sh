#!/bin/bash

set -e

program_name=$0

if [ -z "$1" ]; then
    echo "usage: $program_name [OPTIONS]"
    echo ""
    echo "  -p1=<>,  --par1=<>  free value"
    echo "  -p2=<>,  --par2=<>  free value"
    echo "  -p3,  --par3    bool value"
    exit 0;
fi


while [ $# -gt 0 ]; do
  case "$1" in
    --par1=* | -p1=*)
      par1="${1#*=}"
      ;;
    --par2=* | -p2=*)
      par2="${1#*=}"
      ;;
    --par3 | -p3)
      par3="true"
      ;;
    *)
      printf "***************************\n"
      printf "* Error: Invalid argument.*\n"
      printf "***************************\n"
      exit 1
  esac
  shift
done

echo "par1: $par1"
echo "par2: $par2"
echo "par3: ${par3:-false}"
