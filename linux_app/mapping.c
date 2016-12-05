#include <stdio.h> 
#include <stdlib.h>
#include <string.h>
#include "mapping.h"

DWORD reverseBits(DWORD x){
    x = (((x & 0xaaaaaaaa) >> 1) | ((x & 0x55555555) << 1));
    x = (((x & 0xcccccccc) >> 2) | ((x & 0x33333333) << 2));
    x = (((x & 0xf0f0f0f0) >> 4) | ((x & 0x0f0f0f0f) << 4));
    x = (((x & 0xff00ff00) >> 8) | ((x & 0x00ff00ff) << 8));
    return((x >> 16) | (x << 16));
}

void writeValue(DWORD addr, DWORD value){
    BOOL bPass =  PCIE_Write32( hPCIe, PCIE_BAR0, addr, reverseBits(value));
    if (!bPass){
        printf("ERROR: PCIe Read Failed.\n");
        exit(1);
    }
}

DWORD readValue(DWORD addr){
    DWORD value;
    BOOL bPass =  PCIE_Read32( hPCIe, PCIE_BAR0, addr, &value);
    if (!bPass){
        printf("ERROR: PCIe Read Failed.\n");
        exit(1);
    }
    return reverseBits(value);
}

void writeDifficultyMessage(DWORD * difficulty){
	int i;
	for(i = 0; i < TARGET_WORDS; i++){       
		writeValue(TARGET_ADDRESS + i, difficulty[TARGET_WORDS - i - 1]);
	}
}

void pauseMining(){
    DWORD state = 0;
    SET_PAUSE_BIT(state);
    writeValue(CONTROL_ADDRESS, state);
}

void resumeMining(){
    DWORD state = 0;
    writeValue(CONTROL_ADDRESS, state);
}

state_t getState(){
	DWORD state = readFromStatusRegister();
	if(SUCCESS_BIT_SET(state)){
		if(STOPPED_BIT_SET(state)){
            return SUCCESSFUL;
        }else{
            return UNKNOWN;
        }
	}else{
        if(STOPPED_BIT_SET(state)){
            return WAITING;
        }else{
            return MINING;
        }
	}
}

void writeToControlRegister(DWORD value){
	writeValue(CONTROL_ADDRESS, value);
}

DWORD readFromStatusRegister(){
    return readValue(STATUS_ADDRESS);
}

void writeBitcoinMessage(DWORD * data){
	int i;
    for(i = 0; i < BITCOIN_WORDS; i++){
        writeValue(BITCOIN_ADDRESS + i, data[i]);
    }
}

void readBitcoin(DWORD * data){
	int i;
    for(i = 0; i < BITCOIN_WORDS; i++){
        data[BITCOIN_WORDS - i - 1] = readValue(BITCOIN_ADDRESS + i);
    }
    data[BITCOIN_WORDS] = readValue(NONCE_ADDRESS);
}
