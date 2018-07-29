;Portland bootloader
;Copyright 2018 Benji Dial
;Under GNU GPL v3.0

  org 0x7c00
  bits 32

start:
  xor ax, ax
  mov ds, ax
  mov si, dap

loop_o:
  mov ah, 0x42
  int 0x13
  mov ebx, 0x7e04

loop_i:
  cmp byte [ebx], 'p'
  jne skip
  cmp byte [ebx+1], 'o'
  jne skip
  cmp byte [ebx+2], 'r'
  jne skip
  cmp byte [ebx+3], 't'
  jne skip

  mov dh, byte [dap_sector]
  mov dword [dap_sector], dword [ebx-4]
  mov dword [buffer], 0x8000
  mov ah, 0x42
  int 0x13

  cmp [0x801f], 'l'
  jne false_alarm
  cmp [0x8020], 'a'
  jne false_alarm
  cmp [0x8021], 'n'
  jne false_alarm
  cmp [0x8022], 'd'
  jne false_alarm

  mov cl, dl
  xor dx, dx
  mov ax, [0x8018]
  dec ax
  div 512
  inc ax
  mov dl, cl
  mov [dap_n_sectors], al
  inc qword [dap_sector]

  mov ah, 0x42
  int 0x13

  xor ax, ax
  mov es, ax
  mov ax, 0x1300
  mov bx, 0x0002
  mov cx, 29
  mov bp, succ_msg
  int 0x10

  jmp 0x8000

false_alarm:
  mov byte [dap_sector], dh
  mov dword [buffer], 0x7e00

skip:
  add ebx, 8
  cmp ebx, 0x8004
  jne loop_i
  inc byte [dap_sector]
  cmp byte [dap_sector], 16
  jne loop_o

  xor ax, ax
  mov es, ax
  mov ax, 0x1300
  mov bx, 0x0004
  mov cx, 34
  mov bp, fail_msg
  int 0x10

  cli
hlt:
  hlt
  jmp hlt

succ_msg:
  db "portland loaded.  Starting..."
     ;123456789|123456789|123456789 = 29

fail_msg:
  db "Could not find portland.  Halting."
     ;123456789|123456789|123456789|1234 = 34

dap:
  dw 0x0010
dap_n_sectors:
  dw 1
buffer:
  dd 0x00007e00
dap_sector:
  dq 1

end:
%if end - start > 504
%error "Bootloader too long to fit."
%endif
  times 510 - ($ - $$) db 0
  dw 0xaa55
