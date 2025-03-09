## Snake game in gnu assembly, targeting x86 32 bit architecture.


### Commands to run the project
#### Assembling all files
```
as snake.asm -o snake.o
as last_char_from_stdin.asm -o last_char_from_stdin.o
as is_valid_direction.asm -o is_valid_direction.o
as move_snake.asm -o move_snake.o
as display_snake.asm -o display_snake.o
```

#### Statically linking all files and adding dynamicaly linked standard c library
```
ld -dynamic-linker /lib/ld-linux.so.2 -o snake.out snake.o last_char_from_stdin.o is_valid_direction.o move_snake.o display_snake.o -lc
```

#### Running final program
```
./snake.out
```