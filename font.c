#include "seabios-font.h"
#include <stdio.h>

int main() {
    int ch = 'A';
    for (int y = 0; y < 16; y++) {
        for (int x = 0; x < 8; x++) {
            if ((seabios8x16[ch * 16 + y] >> x) & 1) {
                printf("*");
            } else {
                printf(" ");
            }
        }
        printf("\n");
    }
}