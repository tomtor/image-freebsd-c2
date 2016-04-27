#!/bin/sh

# Construct the Linux binary header
# See https://www.kernel.org/doc/Documentation/arm64/booting.txt

# code: (b 0x40 which branches to the code after the 64 bit header)
printf "\020\000\000\024\000\000\000\000"

# Not clear what purpose this serves, should test 0x0000000000000000
# text offset: 0x0000000001080000 (Used by ODROID Linux kernel)
printf "\000\000\010\001\000\000\000\000"

# image size: 0x0000000001000000 (fix at 16 Mbyte)
printf "\000\000\000\001\000\000\000\000"

# flags
printf "\000\000\000\000\000\000\000\000"

# res2,3,4
printf "\000\000\000\000\000\000\000\000"
printf "\000\000\000\000\000\000\000\000"
printf "\000\000\000\000\000\000\000\000"

# magic
printf "ARM\144"

# res5
printf "\000\000\000\000"

cat "$1"
