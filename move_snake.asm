# -- arguments -- #
# snake buffer address
# last index
# direction
# address of food position row
# address of food position col

# return #
# 0 if success
# 1 if crashed

.include "./setting_defs.asm"

.section .data
    .equ ARG_SNAKE_BUFFER, 8
    .equ ARG_SNAKE_LAST_IDX_ADDR, 12
    .equ ARG_DIRECTION, 16
    .equ ARG_FOOD_ROW_ADDRESS, 20
    .equ ARG_FOOD_COL_ADDRESS, 24

    .equ VAR_NEW_ROW, -4
    .equ VAR_NEW_COL, -8

.section .text
.global move_snake
.type move_snake, @function

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
    movl ARG_SNAKE_LAST_IDX_ADDR(%ebp), %eax
    movl (%eax), %eax
    imull $SNAKE_NODE_SIZE, %eax
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

    # --------
    # // add new head in the list
    # struct node head;
    # head.row = newRow;
    # head.col = newCol;
    # snake[snakeHeadIdx + 1] = head;
    # --------

    # add node at index snakeHeadIdx + 1
    movl ARG_SNAKE_LAST_IDX_ADDR(%ebp), %edi
    movl (%edi), %edi
    addl $1, %edi
    movl %edi, %eax
    imull $SNAKE_NODE_SIZE, %eax
    addl ARG_SNAKE_BUFFER(%ebp), %eax

    movl VAR_NEW_ROW(%ebp), %ebx
    movl %ebx, SNAKE_NODE_ROW_OFFSET(%eax)  # setting row
    movl VAR_NEW_COL(%ebp), %ebx
    movl %ebx, SNAKE_NODE_COL_OFFSET(%eax)  # setting col

    
    # ------------------------
    # // if food was on the current cell
    #     // increase snakeHeadIdx value by 1
    #     // generate new food position randomly 
    # if(newRow == foodRow && newCol == foodCol){
    #     snakeHeadIdx += 1;
    #     foodRow = rand() % BOARD_H;
    #     foodCol = rand() % BOARD_W;
    # }else{
    #     // if food wasn't on the current cell, shift all nodes 1 position behind. do this one by one until we reach head node.
    #     for(int i = 1; i <= snakeHeadIdx + 1; i++){
    #         snake[i - 1] = snake[i]; 
    #     }
    # }
    # ------------------------

    # TODO implement if branch
    food_check:
        movl ARG_FOOD_ROW_ADDRESS(%ebp), %eax
        movl (%eax), %eax
        cmpl %eax, VAR_NEW_ROW(%ebp)
        jne shift_all_nodes_behind

        movl ARG_FOOD_COL_ADDRESS(%ebp), %eax
        movl (%eax), %eax
        cmpl %eax, VAR_NEW_COL(%ebp)
        jne shift_all_nodes_behind

        # increment snake head index via address
        movl ARG_SNAKE_LAST_IDX_ADDR(%ebp), %eax
        addl $1, (%eax)

        pushl ARG_FOOD_ROW_ADDRESS(%ebp)
        pushl ARG_FOOD_COL_ADDRESS(%ebp)
        call update_food_positions
        addl $8, %esp

        jmp check_crashed_into_itself


    shift_all_nodes_behind:
        movl $1, %edi
        movl ARG_SNAKE_LAST_IDX_ADDR(%ebp), %ebx
        movl (%ebx), %ebx
        addl $1, %ebx

        move_snake_loop:
            movl %edi, %eax
            imull $SNAKE_NODE_SIZE, %eax
            addl ARG_SNAKE_BUFFER(%ebp), %eax
            
            movl SNAKE_NODE_ROW_OFFSET(%eax), %ecx 
            movl SNAKE_NODE_COL_OFFSET(%eax), %edx

            subl $SNAKE_NODE_SIZE, %eax
            movl %ecx, SNAKE_NODE_ROW_OFFSET(%eax) 
            movl %edx, SNAKE_NODE_COL_OFFSET(%eax)

            cmpl %edi, %ebx
            jl check_crashed_into_itself

            addl $1, %edi
            jmp move_snake_loop
    

    check_crashed_into_itself:
    # TODO Implement this



    exit_true:
        movl $1, %eax
        jmp exit_move_snake
    
    exit_false:
        movl $0, %eax
        jmp exit_move_snake

    exit_move_snake:
        movl %ebp, %esp
        popl %ebp
        ret



.equ ARG_FOOD_ADDR_1, 8
.equ ARG_FOOD_ADDR_2, 12

update_food_positions:
    pushl %ebp
    movl  %esp, %ebp


    call rand
                          # Dividend in already in eax from rand
    movl $0, %edx         # Clear edx (will hold high bits of dividend)
    movl $BOARD_W, %ebx   # Put divisor in ebx
    divl %ebx

    movl ARG_FOOD_ADDR_1(%ebp), %eax
    movl %edx, (%eax)


    call rand
                          
    movl $0, %edx
    movl $BOARD_H, %ebx   
    divl %ebx

    movl ARG_FOOD_ADDR_2(%ebp), %eax
    movl %edx, (%eax)

    update_food_positions_exit:
        movl %ebp, %esp
        popl %ebp
        ret
