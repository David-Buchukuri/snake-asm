.section .data
    # case 1 - output - w
    old_direction:      .long 'w'
    new_direction:      .long 'p'

    # # case 2 - output - w
    # old_direction:      .long 'w'
    # new_direction:      .long 'v'

    # # case 3 - output - a
    # old_direction:      .long 'w'
    # new_direction:      .long 'a'

    # # case 4 - output - d
    # old_direction:      .long 'w'
    # new_direction:      .long 'd'

    # # case 4 - output - w
    # old_direction:      .long 'w'
    # new_direction:      .long 'w'

    # # case 5 - output - w
    # old_direction:      .long 'w'
    # new_direction:      .long 's'

    # # case 6 - output - s
    # old_direction:      .long 's'
    # new_direction:      .long 'w'

    # # case 7 - output - a
    # old_direction:      .long 'a'
    # new_direction:      .long 'd'

    # # case 8 - output - d
    # old_direction:      .long 'd'
    # new_direction:      .long 'a'

    printfFormat:       .ascii "%c \n\0"

.section .text
.global _start

_start:
    pushl new_direction
    pushl old_direction
    call is_valid_direction
    addl $4, %esp

    cmpl $0, %eax
    je skip_direction_update

    update_direction:
        movl (%esp), %eax
        movl %eax, old_direction

    skip_direction_update:
        # remove remaining argument
        addl $4, %esp
    
    # print old direction
    pushl old_direction
    pushl $printfFormat
    call printf
    addl $8, %esp

    exit_program:
        pushl $0
        call exit


is_valid_direction:
    pushl %ebp
    movl  %esp, %ebp

    # saving because will need to overwrite value. will restore at the end
    pushl %ebx

    # # if (lastChar == 'w' || lastChar == 'a' || lastChar == 's' || lastChar == 'd')
    # # {
    # #     newDirection = lastChar;
    # # }
    # # // handling that snake cant start moving straight into opposite direction
    # # if(
    # #     (direction == 'w' && newDirection != 's') ||
    # #     (direction == 's' && newDirection != 'w') ||
    # #     (direction == 'a' && newDirection != 'd') ||
    # #     (direction == 'd' && newDirection != 'a') 
    # # ){
    # #     direction = newDirection;
    # # }

    # movl 12(%ebp), %eax  # new direction
    # movl 8(%ebp), %ebx  # old direction

    cmpl $'w', 12(%ebp)
    je check_opposite_directin

    cmpl $'a', 12(%ebp)
    je check_opposite_directin

    cmpl $'s', 12(%ebp)
    je check_opposite_directin

    cmpl $'d', 12(%ebp)
    je check_opposite_directin

    jmp exit_false_is_valid_direction

    check_opposite_directin:
        # check 'w' and 's' combo
        pushl 12(%ebp)
        pushl 8(%ebp)
        pushl $'w'
        pushl $'s'
        call are_chars_equal
        addl $16, %esp

        cmpl $1, %eax
        je exit_false_is_valid_direction

        # check 's' and 'w' combo
        pushl 12(%ebp)
        pushl 8(%ebp)
        pushl $'s'
        pushl $'w'
        call are_chars_equal
        addl $16, %esp

        cmpl $1, %eax
        je exit_false_is_valid_direction

        # check 'a' and 'd' combo
        pushl 12(%ebp)
        pushl 8(%ebp)
        pushl $'a'
        pushl $'d'
        call are_chars_equal
        addl $16, %esp

        cmpl $1, %eax
        je exit_false_is_valid_direction

        # check 'd' and 'a' combo
        pushl 12(%ebp)
        pushl 8(%ebp)
        pushl $'d'
        pushl $'a'
        call are_chars_equal
        addl $16, %esp

        cmpl $1, %eax
        je exit_false_is_valid_direction

    exit_true_is_valid_direction:
        movl $1, %eax
        jmp exit_is_valid_direction
       
    exit_false_is_valid_direction:
        movl $0, %eax
        jmp exit_is_valid_direction
    
    exit_is_valid_direction:
        popl %ebx
        movl %ebp, %esp
        popl %ebp
        ret


are_chars_equal:
    pushl %ebp
    movl  %esp, %ebp

    pushl %ebx
    pushl %ecx
    pushl %edx


    movl 20(%ebp), %eax  # actual new value
    movl 16(%ebp), %ebx  # actual old value
    movl 12(%ebp), %ecx  # expected new value
    movl 8(%ebp),  %edx  # expected old value

    cmpl %eax, %ecx
    jne exit_false_are_chars_equal

    cmpl %ebx, %edx
    jne exit_false_are_chars_equal

    exit_true_are_chars_equal:
        movl $1, %eax
        jmp exit_are_chars_equal


    exit_false_are_chars_equal:
        movl $0, %eax
        jmp exit_are_chars_equal
    
    exit_are_chars_equal:
        popl %edx
        popl %ecx
        popl %ebx

        movl %ebp, %esp
        popl %ebp
        ret


