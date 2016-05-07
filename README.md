# image-freebsd-c2

## Booting the freebsd kernel on the ODroid-C2

The standard u-boot as supplied on the linux-images and with build instructions here:

http://odroid.com/dokuwiki/doku.php?id=en:c2_building_u-boot

just works out of the box. Interrupt the standard boot process by hitting "Enter" twice and enter:

###For booting with TFTP

```
setenv serverip A.B.C.D (The address of your (FreeBSD) TFTP server)
setenv ipaddr D.E.F.G (The address of your C2)
setenv bootcmd "tftp 0x20000000 kernel; go 0x20001000"

saveenv
```
and on the next reboot (just enter "reset") it will boot with TFTP.

Just place the "kernel" file in your TFTP-server directory.

###For booting from SD
```
setenv bootcmd "fatload mmc 0:2 0x20000000 kernel; go 0x20001000"
```
