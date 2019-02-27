[bits 16]
org 0x7C00
start:
	call vesa
	cli
	call read_kernel
	mov ax, 0
	call prepare
	mov sp, 0xfffc
	call LoadDeskTable
	
	mov eax, cr0
	or eax, 1
	mov cr0, eax
	jmp SEG_CODE:goPM
ret

vesa:
	mov ax, 0x4f01
	mov cx, 0x118
	mov di, buffer
	int 0x10
	mov ax, 0x4f02
	mov bx, 0x4118
	int 0x10
	mov eax, dword[buffer+40]
	mov dword[lfb_addr], eax
ret

read_kernel:
	mov ah, 2
	mov al, 10
	mov ch, 0
	mov cl, 2
	mov dh, 0
	mov dl, 0x80
	mov bx, 0X8000
	int 0x13
ret

prepare:
	mov ss, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
ret
	
LoadDeskTable:
	pusha
	lgdt[gdt_desk]
	popa
ret

[bits 32]
goPM:
	mov ax, SEG_DATA
	call prepare

	mov edi, [lfb_addr]
	jmp SEG_CODE:0X8000
	jmp $
ret

[bits 16]

;---------------- GDT TABLE START ------------
gdt_start:
;---------------- base desk ------------------
null_desk: 
	dd 0
	dd 0
code_desk:
	dw 0xffff ;limit
	dw 0x0 ;base addr
	db 0 ;base addr 3byte
	db 10011010b ;base flags
	db 11001111b ;дополнительные флаги сегмента
	db 0 ;base addr 4byte (четвертый)
data_desk:
	dw 0xffff
	dw 0x0
	db 0
	db 10010010b
	db 11001111b
	db 0	
;---------------- desk table -----------------
gdt_end:
gdt_desk:
	dw gdt_end - gdt_start
	dd gdt_start
;---------------- pointer --------------------
SEG_DATA equ data_desk - gdt_start
SEG_CODE equ code_desk - gdt_start
;---------------- GDT TABLE END --------------
buffer dd 0,0,0,0,0,0,0,0,0,0,0,0
lfb_addr dd 0