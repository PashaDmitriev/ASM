CR equ 0dh
                  
ROW_COUNT equ 5
COLUMN_COUNT equ 6
          
.model tiny

print_str macro out_str
    mov ah, 9
    mov dx, offset out_str
    int 21h
endm

read_str macro in_str
    mov ah, 0ah
    mov dx, offset in_str
    int 21h
endm

.code
.org 0x100

start proc
    
    xor si, si
    mov cx, ROW_COUNT
_scan_raws_loop:    
    push cx
    
    print_str input_row_msg
    read_str _mxln_row
    mov word ptr [g_str_offs], 0
    
    mov cx, COLUMN_COUNT
_fill_row_loop:    
    call scan_int       ;vod matr
    mov row_arr[si], ax
    add si, 2
    loop _fill_row_loop
    
    print_str new_line_msg
    
    pop cx
    loop _scan_raws_loop
    
;;;;;;;;;;;;;;;; sum_row ;;;;;;;;;;;;;;;;;;;;;;
    
    xor si, si
    mov cx, ROW_COUNT
_column_sum_loop:
    push cx
    
    xor di, di
    mov cx, COLUMN_COUNT   
_row_loop:    
    mov ax, row_arr[si]
    add sum_row[di], ax             ;str s sum olumn
	
	jc _sum_overflow
	
    add di, 2
    add si, 2
    loop _row_loop
    
    pop cx
    loop _column_sum_loop
    
;;;; find columns with smallest numbers
    
    xor bx, bx
    xor ax, ax
    xor si, si
    mov ax, sum_row[si]
    
    mov cx, COLUMN_COUNT
_find_lowest_column:
    cmp sum_row[si], ax
    jae _label
    mov ax, sum_row[si]
    mov bx, si
_label:
    add si, 2   
    loop _find_lowest_column
              
    mov bx, ax  
    
    xor dx, dx
    xor si, si
    mov cx, COLUMN_COUNT
_finale_loop:
    cmp bx, sum_row[si]
    jne _label2
    mov dx, si
    shr dx, 1
    inc dx
    add dx, '0'
    mov ah, 02h
    int 21h
    print_str new_line_msg
_label2:
    add si, 2
    loop _finale_loop
    
    jmp _end_of_prog
    
_sum_overflow:
    print_str msg_sum_overflow

_end_of_prog:        
    xor ax, ax
    mov ah, 4Ch
    int 21h
start endp



is_digit proc
    push bp
    mov bp, sp
    push bx
    
    mov ax, 0
    mov bl, byte ptr [bp + 4]
    cmp bl, '0'
    jb _end
    cmp bl, '9'
    ja _end
    mov ax, 1
    
_end:
    pop bx    
    pop bp
    ret
is_digit endp
  
; PROC :: scan_int :: PROC     
; scans integer from g_row_str
; @params: string
; @ret_val: ax
; @side_effects: changes the value of ax, and g_row_str

scan_int proc
    push bp
    mov bp, sp 
    push bx
    push dx
    push si
    
    xor ax, ax
          
_skip_space_loop:
    mov si, [g_str_offs]
    mov al, byte ptr row_str[si]
    
    cmp byte ptr row_str[si], CR 
    je _pre_scan_int_loop
    cmp byte ptr row_str[si], ' '
    jne _pre_scan_int_loop
    
    inc word ptr [g_str_offs]                                   
    jmp _skip_space_loop

_pre_scan_int_loop:          
    xor bx, bx
    
_scan_int_loop:
    mov si, [g_str_offs]    
    cmp byte ptr row_str[si], CR
    je _end_scan_int
    push word ptr row_str[si]
    call is_digit
    cmp ax, 1
    pop ax
    jne _end_scan_int
    
    mov ax, 10
    mul bx
    jc _cant_handle_big_numbers
    
    mov dx, word ptr row_str[si]
    xor dh, dh
    sub dx, '0'
    
    add ax, dx
    jc _cant_handle_big_numbers
    mov bx, ax

    inc word ptr [g_str_offs]
    jmp _scan_int_loop
    
_cant_handle_big_numbers:
    print_str new_line_msg
    print_str msg_cant_handle_big_numbers
    xor ax, ax
    mov ah, 4Ch
    int 21h
             
_end_scan_int:
    mov ax, bx 
    
    pop si
    pop dx
    pop bx          
    pop bp
    ret    
scan_int endp

row_arr dw 0, 0, 0, 0, 0, 0
        dw 0, 0, 0, 0, 0, 0
        dw 0, 0, 0, 0, 0, 0
        dw 0, 0, 0, 0, 0, 0
        dw 0, 0, 0, 0, 0, 0

sum_row dw 0, 0, 0, 0, 0, 0

stack_top dw 0
stack dw 0, 0, 0, 0, 0, 0

g_str_offs dw 0

_mxln_row db 201   
row_str_len db 0
row_str db 200 dup(0)

input_row_msg db "input row: ", '$'
msg_input db "input number: ", 0ah, 0dh, '$'
msg_cant_handle_big_numbers db "can't handle big numbers", 0ah, 0dh, '$'
new_line_msg db 0ah, 0dh, '$'
msg_sum_overflow db "sum overflow", 0ah, 0dh, '$'
    
end start