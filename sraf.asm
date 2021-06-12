;===============================;
;                               ;
; SRAF - Stupid Read A File     ;
;                               ;
; usage: sraf {path_to_file}    ;
;                               ;
; NASM elf64 - Charles Corbett  ;
;                         2021  ;
;                               ;
;           sraf.asm            ;
;===============================;

%include 'util.asm'

segment .data
  msgUsage      db    'Usage: sraf {path_to_file}', 0h
  errArgCount   db    'Incorrect number of arguments.', 0h
  errArgLen     db    'Given path is too long and would be truncated. Max size: 255 characters.', 0h
  errUndef      db    'An undefined error occured', 0h
  msg           db    'Operation completed successfully.', 0h


segment .bss
;pathInput   resb  255   ; reserve a 255 byte space in memory for the user input
;contents   resb  4096

pathInput   resb  255,
contents    resb  4096,

segment .text
global _start

_start:
  pop rcx             ; on entry contains the # of arguments in the stack
  cmp rcx, 1          ; desired arg count - 1
  jle argumentError   ; go to argument err if too few
  cmp rcx, 3          ; desired arg count + 1
  jge argumentError   ; go to arg err of too many

  pop rdi             ; pull out the exec path from the stack rdi[0]
  pop rdi             ; pull out our argument from the stack rdi[1]

  call validateArgumentLength   ; make sure it won't truncate or overflow

  mov [pathInput], rdi  ; store our filepath in our reserved space
  
  ; open file and get descriptor
  mov rax, 2        ; sys_open
  xor rsi, rsi      ; readonly
  syscall

  cmp rax, 0        ; compare result to 0
  jle .derp         ; if it is lower, like -1, use our temporary error

  mov rdi, rax      ; lets pass our FD in
  mov rax, 0        ; sys_read
  mov rsi, contents ; buffer for the contents
  mov rdx, 4096     ; were fetching 4096 bytes because fuck you
  syscall           ; JUST DO IT

  mov rdi, contents ; move our buffer on to rdi
  call sprintLF     ; print that shit

  call quit ; happy ending

.derp:
  mov rdi, errUndef
  call error