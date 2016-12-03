#include <stdlib.h>
#include "bitcoin.h"
#include <math.h>
#include <time.h>

inline float fast_log(float val)
{
    int * const exp_ptr = (int *)(&val);
    int x = *exp_ptr;
    const int log_2 = ((x >> 23) & 255) - 128;
    x &= ~(255 << 23);
    x += 127 << 23;
    *exp_ptr = x;

    val = ((-1.0f/3) * val + 2) * val - 2.0f/3;
    return ((val + log_2) * 0.69314718f);
} 
 
float difficulty(unsigned int bits){
    double max_body = fast_log(0x00ffff);
    double scaland = fast_log(256);
    return exp(max_body - fast_log(bits & 0x00ffffff) + scaland * (0x1d - ((bits & 0xff000000) >> 24)));
}

void constructBitcoinMessage(DWORD * store){
    store[0] = VERSION;
    DWORD dummy[8];
    uchar temp[32];
    sha((uchar*)"",temp,0);
    ucharsToDWORD(temp, dummy);
    int i;
    for(i = 0; i < 8; i++){
        store[1+i] = dummy[i];
    }
    for(i = 0; i < 8; i++){
        store[9+i] = dummy[i];
    }
    store[17] = (DWORD)time(NULL);
    store[18] = DIFFICULTY;
}

void ucharsToDWORD(uchar* hash, DWORD * converted){
    int i;
	for(i = 0; i < 8; i++){
		converted[i] = *((DWORD *)(hash + (i * 4)));
	}
}

void floatToDWORDstring(float number, DWORD * result){
    int i;
    for(i = 0; i < 8; i++){
        float temp = number / exp2f((float)(32*(7-i)));
        result[i] = (DWORD)temp;
    }
}

void calculateDifficulty(DWORD * store){
    floatToDWORDstring(difficulty(DIFFICULTY),store);
}
