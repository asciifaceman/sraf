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
  errUnread     db    'An error occured while opening the file, does it exist?', 0h
  errRead       db    'An error occured while reading the file.', 0h
  msg           db    'Operation completed successfully.', 0h
  loopmsg       db    'looping...', 0h
  bufflen       dw    2048  ; size of our buffer to be used for read

segment .bss
pathInput   resb  255,
;contents    resb  4096,
readBuf     resb  2048    ; reserve 2kb byte buffer for read

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
  
  call open         ; open filename on rdi and get fd back in rax
  test rax, rax     ; test result of open and die if its dead
  jle .derp         ; derp out if -1 (failed open)

  mov rdi, rax        ; pass our fd in
  call readAndPrint
  call quit ; happy ending

.derp:
  mov rdi, errUnread
  call error