#include <stdio.h>
#include <termios.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>

#define BOARD_W 40
#define BOARD_H 15

struct node {
    int row;
    int col;
};

char getLastCharFromStdIn()
{
    char lastReadChar = 0;
    char tempChar = 0;

    int bytes = read(STDIN_FILENO, &tempChar, 1);
    while (bytes > 0)
    {
        lastReadChar = tempChar;
        bytes = read(STDIN_FILENO, &tempChar, 1);
    }

    return lastReadChar;
}

char direction = 'w';
int foodRow = BOARD_W / 4;
int foodCol = BOARD_H / 4;
struct node snake[(BOARD_W * BOARD_H) + 1] = {};
int snakeHeadIdx = 0;

int moveSnake(){
    int newRow = snake[snakeHeadIdx].row;
    int newCol = snake[snakeHeadIdx].col;

    if     (direction == 'w'){newRow -= 1;}
    else if(direction == 's'){newRow += 1;}
    else if(direction == 'a'){newCol -= 1;}
    else if(direction == 'd'){newCol += 1;}

    // check if we are out of bounds
    if(newRow < 0 || newCol < 0 || newRow >= BOARD_H || newCol >= BOARD_W){
        return 1;
    }

    // add new head in the list
    struct node head;
    head.row = newRow;
    head.col = newCol;
    snake[snakeHeadIdx + 1] = head;

    // if food was on the current cell
        // increase snakeHeadIdx value by 1
        // generate new food position randomly 
    if(newRow == foodRow && newCol == foodCol){
        snakeHeadIdx += 1;
        foodRow = rand() % BOARD_H;
        foodCol = rand() % BOARD_W;
    }else{
        // if food wasn't on the current cell, shift all nodes 1 position behind. do this one by one until we reach head node.
        for(int i = 1; i <= snakeHeadIdx + 1; i++){
            snake[i - 1] = snake[i]; 
        }
    }
   
    // check if we crashed into ourselves and return 1 if that's the case
    for(int i = 0; i < snakeHeadIdx; i++){
        if(snake[i].row == head.row && snake[i].col == head.col){
            return 1;
        }
    }
    
    return 0;
}

int isSnakeOnPosition(int row, int col){
    for(int i = 0; i <= snakeHeadIdx; i++){
        if(snake[i].row == row && snake[i].col == col){
            return 1;
        }
    }

    return 0;
}

int isValidDirection(char currentDirection, char newDirection){
    if (newDirection != 'w' && newDirection != 'a' && newDirection != 's' && newDirection != 'd')
    {
        return 0;
    }
    // handling that snake cant start moving straight into opposite direction
    if(
        (currentDirection == 'w' && newDirection == 's') ||
        (currentDirection == 's' && newDirection == 'w') ||
        (currentDirection == 'a' && newDirection == 'd') ||
        (currentDirection == 'd' && newDirection == 'a') 
    ){
        return 0;
    }
    return 1;
}

void displaySnake(){
    // CYAN      = '\033[96m'
    // YELLOW    = '\033[93m'
    // RED       = '\033[91m'

    for(int row = 0; row < BOARD_H; row++){
        for(int col = 0; col < BOARD_W; col++){
            if(isSnakeOnPosition(row, col)){
                printf("\033[96m");
                printf("*");
            }
            else if(foodRow == row && foodCol == col){
                printf("\033[91m");
                printf("$");
            }
            else{
                printf("\033[93m");
                printf("-");
            }
        }
        printf("\n");
    }
}

int main()
{
    struct termios old_tio, new_tio;

    // Get current terminal settings
    tcgetattr(STDIN_FILENO, &old_tio);
    new_tio = old_tio;

    // Turn off canonical mode and echo
    new_tio.c_lflag &= (~ICANON & ~ECHO);

    // Set non-blocking read
    new_tio.c_cc[VMIN] = 0;  // Return even if no bytes are available
    new_tio.c_cc[VTIME] = 0; // No timeout

    // Apply new settings
    tcsetattr(STDIN_FILENO, TCSANOW, &new_tio);

    struct node head;
    head.col = BOARD_W / 2;
    head.row = BOARD_H / 2;
    snake[0] = head;

    while(1)
    {
        usleep(200000);
        char lastChar = getLastCharFromStdIn();
        
        if(isValidDirection(direction, lastChar)){
            direction = lastChar;
        }

        int isError = moveSnake();
        
        // clear console
        printf("\e[1;1H\e[2J");
        
        displaySnake();
        if(isError){
            printf("\n Crashed! \n");
            break;
        }
    }

    // Restore old terminal settings
    tcsetattr(STDIN_FILENO, TCSANOW, &old_tio);

    return 0;
}