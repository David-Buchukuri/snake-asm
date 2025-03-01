# # int is_valid_direction(currentDirection, newDirection){
# #     if (newDirection != 'w' || newDirection != 'a' || newDirection != 's' || newDirection != 'd')
# #     {
# #         return false;
# #     }
# #     // handling that snake cant start moving straight into opposite direction
# #     if(
# #         (currentDirection == 'w' && newDirection == 's') ||
# #         (currentDirection == 's' && newDirection == 'w') ||
# #         (currentDirection == 'a' && newDirection == 'd') ||
# #         (currentDirection == 'd' && newDirection == 'a') 
# #     ){
# #         return 0;
# #     }
# #     return 1;
# # }

.section .text
.global is_valid_direction
.type is_valid_direction, @function

is_valid_direction:
    pushl %ebp
    movl  %esp, %ebp

    # saving because will need to overwrite value. will restore at the end
    pushl %ebx

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


