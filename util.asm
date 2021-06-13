;===============================;
;                               ;
; SRAF - Stupid Read A File     ;
;                               ;
; NASM elf64 - Charles Corbett  ;
;                         2021  ;
;                               ;
;           util.asm            ;
;===============================;

;-------------------------------------
; int slen(String message)
; String length calculation
; RDI RSI RDX RCX
slen:
  push rbx      ; push the address at rbx on to the stack to preserve it
  mov rbx, rdi  ; move a copy of our argument rdi on to rbx as well
                ; both point to the same segment in memory

.nextchar:
  cmp byte [rdi], 0     ; compare the byte pointed to by
                        ; rdi here against 0 (EOS)
  jz  .finished          ; jump to finished if rbx is an EOS terminator
  inc rdi               ; increment since we found content at byte [rbx]
  jmp .nextchar          ; jump to nextchar label to loop

.finished:
  sub rdi, rbx      ; subtract the two memory addresses resulting in
                    ; difference in bytes (width) (rdi is incremented)
  cmp rdi, 0
  jz error
  pop rbx           ; move rbx's old value back on to the stack to restore state
  ret               ; return to the port of call



;-------------------------------------
; void sprint(String message)
; string printing
sprint:
  push rdx      ; store rdx on the stack to preserve
  push rsi      ; store rsi on the stack to preserve
  push rax      ; store rax on the stack to preserve
  push rdi      ; store rdi on the stack to preserve
  call slen     ; call slen with rdi argument still

  mov rdx, rdi  ; move the return value (len of rdi on the stack)
  pop rdi       ; pop the actual message back off the stack

  mov rsi, rdi  ; move the message on to the SYS_WRITE buffer
  mov rdi, 1    ; SYS_WRITE STDOUT
  mov rax, 1    ; SYS_WRITE
  syscall       ; JUST DO IT

  pop rax       ; return previous states
  pop rsi
  pop rdx
  ret

sprintLF:
  call sprint

  push rdi        ; push the current input value on the stack
  mov rdi, 0Ah    ; move a 0Ah into rdi - a linefeed character
  push rdi        ; push the linefeed on the sack so we can get its address
  mov rdi, rsp    ; move the address of the stack pointer to the linefeed to rdi
  call sprint     ; print the linefeed address
  pop rdi         ; remove the linefeed from the stack
  pop rdi         ; restore the original pre-function state
  ret

newline:          ; the same as sprintLF but only the newline
  push rdi
  mov rdi, 0Ah
  push rdi
  mov rdi, rsp
  call sprint
  pop rdi
  pop rdi
  ret

;-------------------------------------
; void validateArgumentLength(String message)
; Makes sure our input string isn't longer than 255 bytes to avoid truncation
validateArgumentLength:
  push rdx        ; store to preserve
  push rdi        ; store to preserve
  call slen       ; get length of rdi

  mov rdx, rdi    ; save length to rdx
  pop rdi         ; restore original rdi

  cmp rdx, 255    ; compare given length to 255
  jge .tooLong    ; if larger, error

  pop rdx         ; restore state before returning
  ret

.tooLong:
  mov rdi, errArgLen  ; grab our error message
  call error          ; die

;-------------------------------------
; void argumentError()
; Displays usage and quits with return code 1
argumentError:
  mov rdi, errArgCount
  call sprintLF
  call usage

;-------------------------------------
; void usage()
; Displays usage and quits with return code 1
usage:
  mov rdi, msgUsage
  call error


;-------------------------------------
; void quit()
; Exit program and restore resources
quit:
  xor rdi, rdi    ; xero rdi for 0 exit code via xors
  mov rax, 60     ; I hate that sys_exit is 60
  syscall
  ret

;-------------------------------------
; void error(String message)
; prints an error and quits
error:
  call sprintLF   ; print what is on rdi
  mov rdi, 1      ; set return code to 1
  mov rax, 60     ; sys_exit
  syscall
  ret

;-------------------------------------
; int Open(String filepath)
; accepts: filename/path on rdi
; returns: file descriptor on rax
open:
  push rsi        ; preserve rsi since we are going to use it

  mov rax, 2      ; sys_open on rax
  xor rsi, rsi    ; clear rsi for readonly flag
  syscall

  pop rsi
  ret

;-------------------------------------
; void readAndPrint(int fd)
; accepts: file descriptor on rdi
; reads a buffered chunk from the given fd, prints
; then loops until EOF
readAndPrint:
  push rbx            ; preserve rbx
  mov rbx, bufflen    ; move our buffer length on to rbx

.bufferedFileRead:
  mov rax, 0          ; sys_read
  mov rsi, readBuf    ; assign our 2kb byte buffer
  mov rdx, bufflen    ; size of our buffer (how much to read)
  syscall

  test rax, rax       ; check for error (-1) or EOF (0)
  jz .done            ; if EOF we're done
  jle .errored        ; if < 0 we're errored

.print_result:
  push rdi            ; preserve rdi
  mov rdi, readBuf    ; move our buffer address into rdi
  call sprint         ; print the content at teh address
  pop rdi             ; restore rdi


.seek_offset:
  mov rax, 8          ; sys_lseek
  mov rsi, bufflen    ; our buffer length to move by
  mov rdx, rbx        ; offset is our cumulative buffer size over loops
  syscall

  add rbx, [bufflen]  ; grow the offset by the buffer size

  jmp .bufferedFileRead ; loop

.errored:
  mov rdi, errRead
  call error

.done:
  pop rbx
  call newline
  call newline
  mov rdi, msg
  call sprintLF
  ret