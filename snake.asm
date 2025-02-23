.section .data
    tempChar:        .byte 0
    printfFormat:    .ascii "%c \n\0"
    ICANON:         .long 2
    ECHO:           .long 8
    TCSANOW:        .long 0

    .equ VMIN,  6
    .equ VTIME, 5

.section .bss
    # Allocate space for termios structs (60 bytes)
    .lcomm old_tio, 60
    .lcomm new_tio, 60

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

    # # # Offset of c_iflag: 0
    # # # Offset of c_oflag: 4
    # # # Offset of c_cflag: 8
    # # # Offset of c_lflag: 12
    # # # Offset of c_cc: 17
    # # # Size of cc flags array: 32
    # # # Size of struct termios: 60
    # # # ICANON: 0x2
    # # # ECHO: 0x8
    # # # TCSANOW: 0x0
    # # # VMIN: 6
    # # # VTIME: 5

    # # # translate this c code
    # # # ---------------------------------------------
    # # # // Turn off canonical mode and echo
    # # # new_tio.c_lflag &= (~ICANON & ~ECHO);
    # # #
    # # # // Set non-blocking read
    # # # new_tio.c_cc[VMIN] = 0;  // Return even if no bytes are available
    # # # new_tio.c_cc[VTIME] = 0; // No timeout
    # # #
    # # # // Apply new settings
    # # # tcsetattr(STDIN_FILENO, TCSANOW, &new_tio);
    # ---------------------------------------------

    # # Modify new_tio.c_lflag &= (~ICANON & ~ECHO)
    # movl $new_tio, %eax
    # movl $0xFFFFFFF5, 12(%eax)
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

    # read char and print every 2 seconds
    # # # char tempChar = 0;
    # # # int bytes = read(STDIN_FILENO, &tempChar, 1);
    movl $0, %edi

    loop:
        # sleep
        pushl $1000000
        call usleep
        addl $4, %esp

        # read input
        pushl $1
        pushl $tempChar
        pushl $0
        call read
        addl $12, %esp

        # print input
        pushl tempChar
        pushl $printfFormat
        call printf
        addl $8, %esp

        addl $1, %edi

        cmpl $15, %edi
        je restore_terminal

        jmp loop
    
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
