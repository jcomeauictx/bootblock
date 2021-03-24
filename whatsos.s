# stupid "operating system" that does nothing but repeat back what you type.
	.code16
	.org 0
	mov %cs, %ax
	mov %ax, %ds
	mov %ax, %es
	call okay
	hlt
okay:
	mov okstring, %bp
	mov $0x1301, %ax
	mov $4, %cx
	mov $0xc, %bx
	mov $0, %dl
	int $0x10
	ret
okstring:
	.ascii "ok\r\n"
	.org 0x1fe
	.word 0xaa55
