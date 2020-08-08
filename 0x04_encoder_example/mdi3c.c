
// nasm -f elf32 mdi3.asm 
// gcc -c mdi3c.c
// gcc -m32 -o mdi3 mdi3.o mdi3c.o
// ./mdi3


#include <stdio.h>
#include <string.h>

char * test = "deneme 123";



char * encoder(char *); // asm


void main() {
    printf("%s", test);
    printf("\n");
    
    char * b = encoder(test);
    printf("%s",b);
    printf("\n");
}

