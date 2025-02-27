.section .data
    .equ STDIN, 0
    .equ TMP_CHAR_OFFSET, -1
    .equ LAST_CHAR_OFFSET, -2

.section .text
.globl last_char_from_stdin
.type last_char_from_stdin, @function

last_char_from_stdin:
    pushl %ebp
    movl  %esp, %ebp

    subl $2, %esp  
    movb $0, TMP_CHAR_OFFSET(%ebp)
    movb $0, LAST_CHAR_OFFSET(%ebp)

    loop:
        pushl $1
        # Get address of tmpChar
        leal TMP_CHAR_OFFSET(%ebp), %eax  
        pushl %eax
        pushl $STDIN
        call read
        addl $12, %esp

        cmpl $0, %eax 
        je exit

        movb TMP_CHAR_OFFSET(%ebp), %al
        movb %al, LAST_CHAR_OFFSET(%ebp)
        jmp loop
    
    exit:
        movb LAST_CHAR_OFFSET(%ebp), %al
        movl %ebp, %esp
        popl %ebp
        ret

