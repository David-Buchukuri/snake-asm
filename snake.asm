.include "./setting_defs.asm"
.section .data
    tempChar:               .byte 0
    printfCharFormat:       .ascii "%c \n\0"
    printfNewlineFormat:    .ascii "\n\0"
    crashedMessage:         .ascii "\n Crashed! \n\0"
    #clearConsoleMessage:   .ascii "\e[1;1H\e[2J"
    clearConsoleMessage:    .ascii "\x1B[1;1H\x1B[2J\0"

    ICANON:                 .long 2
    ECHO:                   .long 8
    TCSANOW:                .long 0

    direction:              .long 'd'
    snakeLastIndex:         .long 0
    foodRow:                .long 3
    foodCol:                .long 5

    .equ VMIN,  6
    .equ VTIME, 5

.section .bss
    # Allocate space for termios structs (60 bytes)
    .lcomm old_tio, 60
    .lcomm new_tio, 60
    .lcomm snake, SNAKE_BUFFER_SIZE

.section .text
.global _start

_start:
    # Call tcgetattr(STDIN_FILENO, &old_tio)
    pushl $old_tio
    pushl $0      
    call tcgetattr
    addl $8, %esp

    pushl $60
    pushl $old_tio
    pushl $new_tio
    call memcpy
    addl $12, %esp

    # # Modify new_tio.c_lflag &= (~ICANON & ~ECHO)
    movl $0xFFFFFFF5, new_tio + 12

    # # Set non-blocking read (new_tio.c_cc[VMIN] = 0, new_tio.c_cc[VTIME] = 0)
    movl $0, new_tio + 17 + VMIN  # Set VMIN (Offset 17 + index 6)
    movl $0, new_tio + 17 + VTIME # Set VTIME (Offset 17 + index 5)

    # Call tcsetattr(STDIN_FILENO, TCSANOW, &new_tio)
    pushl $new_tio
    pushl TCSANOW
    pushl $0
    call tcsetattr
    addl $12, %esp  

    # add first node of snake at position 0, 0
    movl $snake, %eax
    movl $0, SNAKE_NODE_ROW_OFFSET(%eax)  # setting row
    movl $0, SNAKE_NODE_COL_OFFSET(%eax)  # setting col

    # movl $0, %edi

    loop:
        # sleep
        pushl $300000
        call usleep
        addl $4, %esp

        call last_char_from_stdin

        # print input
        pushl %eax
        pushl $printfCharFormat
        call printf
        addl $4, %esp
        popl %eax

        pushl %eax
        pushl direction
        call is_valid_direction
        addl $4, %esp
    
        cmpl $0, %eax
        je skip_direction_update
    
        update_direction:
            movl (%esp), %eax
            movl %eax, direction
    
        skip_direction_update:
            # remove remaining argument
            addl $4, %esp
        
        pushl $1                  # food col
        pushl $1                  # food row
        pushl direction           # direction
        pushl snakeLastIndex      # last index
        pushl $snake              # snake buffer address
        call move_snake
        addl $20, %esp

        pushl %eax

        # clear console
        pushl $clearConsoleMessage
        call printf
        addl $4, %esp

        # call display snake
        pushl foodRow
        pushl foodCol
        pushl $snake
        pushl snakeLastIndex
        call display_snake
        addl $16, %esp

        # check if we crashed
        popl %eax
        cmpl $0, %eax
        je crashed
        
        # # print current direction
        # pushl direction
        # pushl $printfCharFormat
        # call printf
        # addl $8, %esp

        # addl $1, %edi

        # cmpl $15, %edi
        # je restore_terminal

        pushl $printfNewlineFormat
        call printf
        addl $4, %esp

        jmp loop
    
    crashed:
        pushl $crashedMessage
        call printf
        addl $4, %esp
    
    restore_terminal:
        # tcsetattr(STDIN_FILENO, TCSANOW, &old_tio);
        pushl $old_tio
        pushl TCSANOW
        pushl $0
        call tcsetattr
        addl $12, %esp

    exit_program:
        pushl $0
        call exit
