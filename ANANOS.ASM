org 100h


call clear_screen

repeat:
    mov si, wc
    call print_si
    mov si, console
    call input_si
	;call print_si

    mov di, exitcom
    call compare_str_si_di
    test al, al
    jnz exit

    mov si, error0
    call print_si

    jmp repeat


exit:
mov byte[atr], 00000111b; default DOS colors
call clear_screen
mov ah, 4Ch; exit
int 21h


wc db '>>>', 0
error0 db 'Illegal command!', 13, 13, 0
exitcom db 'exit', 0

console: times 100h db 0

atr db 01111011b; white bckg, cyan text
cur_x db 0
cur_y db 0


compare_str_si_di:; AL = 1 if str[si]==str[di] else 0
    push si
    push di
    push dx
    .loop:
        mov dl, [si]
        cmp byte[di], dl
        jne .no
        cmp byte[si], 0
        je .yes
        inc si
        inc di
        jmp .loop
    .yes:
        mov al, 1
        jmp .end
    .no:
        mov al, 0
    .end:
    pop dx
    pop di
    pop si
    ret

clear_screen:
    pushad
    mov ax, 0003; clear screen, text mode 80x25, 16/8 color
    int 10h

    mov cx, 2000; 80*25
    mov al, ' '
    .repeat:
        call print_al
        loop .repeat

	mov dx, 0; dh=0; dl=0
	call set_cur_dh_dl
    popad
    ret

input_si:
    pushad
    .loop:
        mov ah, 8; input 1 char
        int 21h
        call print_al
        cmp al, 13
		je .end
        mov [si], al
        inc si
        jmp .loop
    .end:
	mov byte[si], 0
	popad
    ret

print_dx:
    pushad
    mov ah, 9
    int 21h
    popad
    ret

print_si:
    pushad
    .loop:
        cmp byte[si], 0
        je .end
        mov al, [si]
        call print_al
        inc si
        jmp .loop
    .end:
    popad
    ret

set_cur_dh_dl:
	pushad
	mov bh, 0; video page
	mov ah, 2
	int 10h
	mov [cur_x], dl
	mov [cur_y], dh
	popad
	ret

cur_next_pos:
	pushad
	mov dh, [cur_y]
	mov dl, [cur_x]
	cmp dl, 79
	jnb .next
	inc dl
	call set_cur_dh_dl
	jmp .end
	.next:
		call cur_next_str
	.end:
        popad
	ret

cur_next_str:
    pushad
    mov dl, 0
    mov dh, [cur_y]
    inc dh
    call set_cur_dh_dl
    popad
    ret

print_al:
    pushad
    cmp al, 13
    je .next
    mov ah, 9
    mov bh, 0; video page
    mov bl, [atr]
    mov cx, 1; count
    int 10h
    call cur_next_pos
    jmp .end
    .next:
        call cur_next_str
    .end:
    popad
    ret
