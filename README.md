# bootblock

information and scripts for creating and modifying bootblocks

notes from memory in no particular order:

fetch the bootblock from the disk partition:
`dd if=/dev/sdb1 bs=512 count=1 of=sdb1.boot.dat`

attempt disassembly:
`objdump --disassemble-all --target=binary --architecture=i386 >
sdb1.boot.dat > sdb1.boot.dsm`

you may find that the first "jmp" goes to an address that the disassembly
doesn't show, because objdump's disassembler isn't that smart and it takes
text and other data as instructions; if the jump address falls in the middle
of one of these, you need to insert a "nop" in front of it.

you do this with xxd. first xxd sdb1.boot.dat sdb1.boot.xxd. Then you edit
the hexadecimal and change 00 (or whatever it happens to be) to 93, hexadecimal
for `nop`. now you `xxd -r sdb1.boot.xxd sdb1.nopinserted.boot.dat`. then you
can disassemble it more or less correctly.
