# # use this file to test operatons on snake.
# # - creating buffer to store snake nodes
# # - creating new node and adding it to the specified index
# # - moving snake aka 
# #     - popping last node and moving all others 1 index down
# #     - updating old head's head flag so it becomes regular node


# # ------- before loop starts ------- # #
# # struct node head;
# # head.col = BOARD_W / 2;
# # head.row = BOARD_H / 2;
# # snake[0] = head;

# # ------- move snake function ------- # #
# int moveSnake(){
#     int newRow = snake[snakeHeadIdx].row;
#     int newCol = snake[snakeHeadIdx].col;
# 
#     if     (direction == 'w'){newRow -= 1;}
#     else if(direction == 's'){newRow += 1;}
#     else if(direction == 'a'){newCol -= 1;}
#     else if(direction == 'd'){newCol += 1;}
# 
#     // check if we are out of bounds
#     if(newRow < 0 || newCol < 0 || newRow >= BOARD_H || newCol >= BOARD_W){
#         return 1;
#     }
# 
#     // add new head in the list
#     struct node head;
#     head.row = newRow;
#     head.col = newCol;
#     snake[snakeHeadIdx + 1] = head;
# 
#     // if food was on the current cell
#         // increase snakeHeadIdx value by 1
#         // generate new food position randomly 
#     if(newRow == foodRow && newCol == foodCol){
#         snakeHeadIdx += 1;
#         foodRow = rand() % BOARD_H;
#         foodCol = rand() % BOARD_W;
#     }else{
#         // if food wasn't on the current cell, shift all nodes 1 position behind. do this one by one until we reach head node.
#         for(int i = 1; i <= snakeHeadIdx + 1; i++){
#             snake[i - 1] = snake[i]; 
#         }
#     }
#
#     // check if we crashed into ourselves and return 1 if that's the case
#     for(int i = 0; i < snakeHeadIdx; i++){
#         if(snake[i].row == head.row && snake[i].col == head.col){
#             return 1;
#         }
#     }
#     
#     return 0;
# }

# .section .data
#     snakeHeadIdx: .long 0
#     printfLongFormat:    .ascii "%d \n\0"
#     printfNewlineFormat:    .ascii "\n\0"
# 
#     .equ BOARD_W, 15
#     .equ BOARD_H, 7
#     .equ SNAKE_NODE_SIZE, 8
#     .equ SNAKE_BUFFER_SIZE, BOARD_W * BOARD_H * SNAKE_NODE_SIZE
#     .equ SNAKE_NODE_ROW_OFFSET, 0
#     .equ SNAKE_NODE_COL_OFFSET, 4
# 
# .section .bss
#     .lcomm snake, SNAKE_BUFFER_SIZE
# 
# .section .text
# .global _start
# _start:
#     # add node at index 0
#     movl $0, %edi      # index
#     movl %edi, %eax
#     imull $12, %eax
#     addl $snake, %eax
# 
#     movl $4, SNAKE_NODE_ROW_OFFSET(%eax)  # setting row
#     movl $4, SNAKE_NODE_COL_OFFSET(%eax)  # setting col
# 
# 
#     # # add node at index 1
#     # movl $1, %edi      # index
#     # movl %edi, %eax
#     # imull $12, %eax
#     # addl $snake, %eax
#     # movl $4, SNAKE_NODE_ROW_OFFSET(%eax)  # setting row
#     # movl $5, SNAKE_NODE_COL_OFFSET(%eax)  # setting col
# 
# 
#     # # add node at index 2
#     # movl $2, %edi      # index
#     # movl %edi, %eax
#     # imull $12, %eax
#     # addl $snake, %eax
#     # movl $4, SNAKE_NODE_ROW_OFFSET(%eax)  # setting row
#     # movl $6, SNAKE_NODE_COL_OFFSET(%eax)  # setting col
# 
#     # loop to print snake nodes
#     movl $0, %edi
# 
#     loop:
#         movl %edi, %eax
#         imull $12, %eax
#         addl $snake, %eax
#         pushl SNAKE_NODE_ROW_OFFSET(%eax)
#         pushl $printfLongFormat
#         call printf
#         addl $8, %esp
# 
#         movl %edi, %eax
#         imull $12, %eax
#         addl $snake, %eax
#         pushl SNAKE_NODE_COL_OFFSET(%eax)
#         pushl $printfLongFormat
#         call printf
#         addl $8, %esp
# 
#         pushl $printfNewlineFormat
#         call printf
#         addl $4, %esp
# 
# 
# 
#         addl $1, %edi
# 
#         cmp snakeHeadIdx, %edi 
#         jg exit_program
#     
#         jmp loop
# 
#     exit_program:
#         pushl $0
#         call exit

.include "./setting_defs.asm"
.section .data
    printfLongFormat:    .ascii "%d \n\0"
    printfNewlineFormat:    .ascii "\n\0"
.section .bss
    .lcomm snake, SNAKE_BUFFER_SIZE

.section .text
.globl _start
_start:
    # add node at index 0
    movl $0, %edi      # index
    movl %edi, %eax
    imull $12, %eax
    addl $snake, %eax

    movl $1, SNAKE_NODE_ROW_OFFSET(%eax)  # setting row
    movl $14, SNAKE_NODE_COL_OFFSET(%eax)  # setting col

    pushl $1
    pushl $1
    pushl $'w'
    pushl $0
    pushl $snake
    call move_snake
    addl $20, %esp

    # print result from move snake
    pushl %eax
    pushl $printfLongFormat
    call printf
    addl $8, %esp

    exit_program:
        pushl $0
        call exit


# -- arguments --
# snake buffer address
# last index
# direction
# board_h
# board_w
# address of food position row
# address of food position col

# return
# 0 if success
# 1 if crashed

.equ ARG_SNAKE_BUFFER, 8
.equ ARG_SNAKE_LAST_IDX, 12
.equ ARG_DIRECTION, 16
.equ ARG_FOOD_ROW_ADDRESS, 20
.equ ARG_FOOD_COL_ADDRESS, 24

.equ VAR_NEW_ROW, -4
.equ VAR_NEW_COL, -8

move_snake:
    pushl %ebp
    movl  %esp, %ebp

    # !! TODO !!
    # save all registers I'm using and then pop at the end

    # --------
    # int newRow = snake[snakeHeadIdx].row;
    # int newCol = snake[snakeHeadIdx].col;
    # --------

    # allocate space for VAR_NEW_ROW and VAR_NEW_COL 
    subl $8, %esp

    # address of the head node
    movl ARG_SNAKE_LAST_IDX(%ebp), %eax
    imull $12, %eax
    movl ARG_SNAKE_BUFFER(%ebp), %ebx
    addl %ebx, %eax

    # assign VAR_NEW_ROW and VAR_NEW_COL head node's row and col
    movl SNAKE_NODE_ROW_OFFSET(%eax), %ebx
    movl %ebx, VAR_NEW_ROW(%ebp)
    movl SNAKE_NODE_COL_OFFSET(%eax), %ebx
    movl %ebx, VAR_NEW_COL(%ebp)

    # --------
    # if     (direction == 'w'){newRow -= 1;}
    # else if(direction == 's'){newRow += 1;}
    # else if(direction == 'a'){newCol -= 1;}
    # else if(direction == 'd'){newCol += 1;}
    # --------

    cmpl $'s', ARG_DIRECTION(%ebp)
    je increment_row

    cmpl $'w', ARG_DIRECTION(%ebp)
    je decrement_row

    cmpl $'d', ARG_DIRECTION(%ebp)
    je increment_col

    cmpl $'a', ARG_DIRECTION(%ebp)
    je decrement_col
    

    increment_row:
        addl $1, VAR_NEW_ROW(%ebp)
        jmp out_of_bounds_check

    decrement_row:
        subl $1, VAR_NEW_ROW(%ebp)
        jmp out_of_bounds_check

    increment_col:
        addl $1, VAR_NEW_COL(%ebp)
        jmp out_of_bounds_check

    decrement_col:
        subl $1, VAR_NEW_COL(%ebp)
        jmp out_of_bounds_check

    # --------
    # if(newRow < 0 || newCol < 0 || newRow >= BOARD_H || newCol >= BOARD_W){
    #     return 1;
    # }
    # --------
    out_of_bounds_check:
    cmpl $0, VAR_NEW_ROW(%ebp)
    jl exit_false

    cmpl $0, VAR_NEW_COL(%ebp)
    jl exit_false

    cmpl $BOARD_H, VAR_NEW_ROW(%ebp)
    jge exit_false

    cmpl $BOARD_W, VAR_NEW_COL(%ebp)
    jge exit_false

    exit_true:
        # ---------- print new row and col
        pushl VAR_NEW_ROW(%ebp)
        pushl $printfLongFormat
        call printf
        addl $8, %esp

        pushl VAR_NEW_COL(%ebp)
        pushl $printfLongFormat
        call printf
        addl $8, %esp
        # ----------  
        movl $1, %eax
        jmp exit_move_snake
    
    exit_false:
        # ---------- print new row and col
        pushl VAR_NEW_ROW(%ebp)
        pushl $printfLongFormat
        call printf
        addl $8, %esp

        pushl VAR_NEW_COL(%ebp)
        pushl $printfLongFormat
        call printf
        addl $8, %esp
        # ----------  
        movl $0, %eax
        jmp exit_move_snake

    exit_move_snake:
        movl %ebp, %esp
        popl %ebp
        ret



