#ifndef _BITCOIN
#define _BITCOIN

#include "PCIE.h"
#include "sha256.h"

#define DIFFICULTY 0x1d00ffff
#define VERSION 0x0400000

float difficulty(unsigned int bits);
void constructBitcoinMessage(DWORD * store);
void ucharsToDWORD(uchar* hash, DWORD * converted);
void floatToDWORDstring(float number, DWORD * result);
void calculateDifficulty(DWORD * store);

#endif
