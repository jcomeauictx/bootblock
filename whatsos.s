# stupid "operating system" that does nothing but repeat back what you type.
	.org 0x7c00
	mov %cs, %ax
	mov %ax, %ds
	mov %ax, %es
	call okay
	jmp .
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
	.org 0x7dfe
	.word 0xaa55
