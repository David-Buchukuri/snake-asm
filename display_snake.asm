.include "./setting_defs.asm"

.section .data
    printfNewlineFormat:      .ascii "\n\0"
    printfAsterisk:           .ascii "*\0"
    printfDash:               .ascii "-\0"
    printfFood:               .ascii "$\0"

    cyan:                     .ascii "\033[96m\0"
    yellow:                   .ascii "\033[93m\0"
    red:                      .ascii "\033[91m\0"


# ---- parameters ---- #
# food row
# food col
# snake buffer address
# snake head index

.equ ARG_ROW_FOOD, 20
.equ ARG_COL_FOOD, 16
.equ ARG_SNAKE_BUFF_ADDR, 12
.equ ARG_SNAKE_HEAD_IDX, 8

.equ VAR_ROW_IDX, -4
.equ VAR_COL_IDX, -8

.section .text
.global display_snake
.type display_snake, @function

display_snake:
    pushl %ebp
    movl  %esp, %ebp

    subl $8, %esp
    movl $0, VAR_ROW_IDX(%ebp)
    movl $0, VAR_COL_IDX(%ebp) 

    loop_row:
        movl $0, VAR_COL_IDX(%ebp)
        loop_col:
            pushl VAR_ROW_IDX(%ebp)
            pushl VAR_COL_IDX(%ebp)
            pushl ARG_SNAKE_HEAD_IDX(%ebp)
            pushl ARG_SNAKE_BUFF_ADDR(%ebp)
            call is_snake_on_position
            addl $16, %esp
            
            cmpl $1, %eax
            jne food_check

            pushl $cyan
            call printf
            addl $4, %esp

            pushl $printfAsterisk
            call printf
            addl $4, %esp
            jmp loop_operations_loop_col
            
            food_check:
                movl ARG_ROW_FOOD(%ebp), %eax
                cmpl %eax, VAR_ROW_IDX(%ebp)
                jne print_board_cell

                movl ARG_COL_FOOD(%ebp), %eax
                cmpl %eax, VAR_COL_IDX(%ebp)
                jne print_board_cell

                pushl $yellow
                call printf
                addl $4, %esp

                pushl $printfFood
                call printf
                addl $4, %esp
                jmp loop_operations_loop_col

            print_board_cell:
                pushl $red
                call printf
                addl $4, %esp

                pushl $printfDash
                call printf
                addl $4, %esp

            loop_operations_loop_col:
                addl $1, VAR_COL_IDX(%ebp)
                cmpl $BOARD_W, VAR_COL_IDX(%ebp)
                jl loop_col

        pushl $printfNewlineFormat
        call printf
        addl $4, %esp

        addl $1, VAR_ROW_IDX(%ebp)
        cmpl $BOARD_H, VAR_ROW_IDX(%ebp)
        jl loop_row


    exit_display_snake:
        addl $8, %esp
        movl %ebp, %esp
        popl %ebp
        ret


# ---- parameters ---- #
# row
# col
# snake head index
# snake buffer address

.equ ARG_ROW, 20
.equ ARG_COL, 16
.equ ARG_HEAD_IDX, 12
.equ ARG_SNAKE_ADDR, 8

is_snake_on_position:
    pushl %ebp
    movl  %esp, %ebp

    # !TODO save all registers
    pushl %edi
    pushl %ecx
    pushl %ebx

    movl $0, %edi

    loop_snake_position:
        movl %edi, %eax
        imull $SNAKE_NODE_SIZE, %eax
        movl ARG_SNAKE_ADDR(%ebp), %ecx
        addl %ecx, %eax

        movl SNAKE_NODE_ROW_OFFSET(%eax), %ebx
        movl SNAKE_NODE_COL_OFFSET(%eax), %ecx

        cmpl ARG_ROW(%ebp), %ebx
        jne loop_operations_is_snake_on_position

        cmpl ARG_COL(%ebp), %ecx
        jne loop_operations_is_snake_on_position

        jmp exit_true_is_snake_on_position

        loop_operations_is_snake_on_position:
            addl $1, %edi
            cmpl ARG_HEAD_IDX(%ebp), %edi
            jle loop_snake_position
    
    exit_false_is_snake_on_position:
        movl $0, %eax
        jmp exit_is_snake_on_position

    exit_true_is_snake_on_position:
        movl $1, %eax

    exit_is_snake_on_position:
        popl %ebx
        popl %ecx
        popl %edi
        
        movl %ebp, %esp
        popl %ebp
        ret
