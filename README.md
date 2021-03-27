# bootblock

information and scripts for creating and modifying bootblocks

notes from memory in no particular order:

fetch the bootblock from the disk partition:
`dd if=/dev/sdb1 bs=512 count=1 of=sdb1.boot.dat`

attempt disassembly:
`objdump --disassemble-all --target=binary --architecture=i386 
--disassembler-options=addr16,data16 sdb1.boot.dat > sdb1.boot.dsm`

you may find that the first "jmp" goes to an address that the disassembly
doesn't show, because objdump's disassembler isn't that smart and it takes
text and other data as instructions; if the jump address falls in the middle
of one of these, you need to insert one or more `nop`s in front of it.

you can do this with xxd. first xxd sdb1.boot.dat sdb1.boot.xxd. Then edit
the hexadecimal and change 00 (or whatever it happens to be) to 90, hexadecimal
for `nop`. now you `xxd -r sdb1.boot.xxd sdb1.nopinserted.boot.dat`. then it
will disassemble more or less correctly.

it can be done even more easily with `dd`. see the `insert_nop_at.sh` script
in this code repository, and the Makefile for usage.

with the Bochs emulator you can step through the code and see what it's doing.
first make a floppy image using `bximage`, or `dd`, as shown in the Makefile.
on startup, you will be presented with a prompt similar to that of the `gdb`
debugger, and some of the commands work more or less the same. for example,
you can `break *0x7c00` to set a breakpoint at where the bootloader will be
located, and it will work in most cases; but I have read of strange BIOSes which
set the `cs` (code segment) register to 07c0 and jump into the boodcode at
offset 0!

tried to set up dual boot Linux on Vista using instructions at
<https://wiki.archlinux.org/index.php/Dual_boot_with_Windows>, but so far no
luck. I tried to give bcdedit the correct device, too, but it wouldn't accept
it.
