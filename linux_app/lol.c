#include <stdio.h> 
#include <stdlib.h>
#include <string.h>

#define DWORD unsigned int


DWORD reverseBits(DWORD x){
    x = (((x & 0xaaaaaaaa) >> 1) | ((x & 0x55555555) << 1));
    x = (((x & 0xcccccccc) >> 2) | ((x & 0x33333333) << 2));
    x = (((x & 0xf0f0f0f0) >> 4) | ((x & 0x0f0f0f0f) << 4));
    x = (((x & 0xff00ff00) >> 8) | ((x & 0x00ff00ff) << 8));
    return((x >> 16) | (x << 16));
}

int main(){
	DWORD i;
	for(i = 1; i < 100000000; i*=2){
		printf("%08x,%08x", i,reverseBits(i));
	}
}