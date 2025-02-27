.section .data
    lastReadChar:    .byte 0 
    tempChar:        .byte 0 

    .equ STDIN, 0

.section .text
.globl last_char_from_stdin
.type last_char_from_stdin, @function

last_char_from_stdin:
    pushl %ebp
    movl  %esp, %ebp
    movb $0, tempChar
    movb $0, lastReadChar

    loop:
        pushl $1
        pushl $tempChar
        pushl $STDIN
        call read
        addl $12, %esp

        cmpl $0, %eax 
        je exit

        movb tempChar, %al
        movb %al, lastReadChar
        jmp loop
    
    exit:
        movb lastReadChar, %al
        movl %ebp, %esp
        popl %ebp
        ret

