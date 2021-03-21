#!/bin/bash -e
# Usage: insert_nop_at 0x53 bootblock.dat
offset=$1
outfile=$2
if [ "$offset" -a "$outfile" -a -e "$outfile" ]; then
  echo -n -e '\x90' | dd of=$outfile seek=$((offset)) bs=1 count=1 conv=notrunc
  echo File $2 was patched with a nop at offset $1 >&2
elif [ -z "$outfile" ]; then
  echo Usage: $0 offset filename >&2
  echo Example: $0 0x53 bootblock.dat
  exit 1
else
  echo File $2 not found >&2
  exit 2
fi
