#include <stdio.h> 
#include <string.h>
#include "mapping.h"


void writeDifficultyMessage(DWORD * difficulty){

}

void pauseMining(){

}

void resumeMining(){

}

void getState(){

}

void writeBitcoinMessage(DWORD * data){
    DWORD addr = BITCOIN_ADDRESS;
    for(int i = 0; i < BITCOIN_WORDS; i++){
        BOOL bPass = PCIE_Write32( hPCIe, PCIE_BAR0, addr + i, data[i]);
        if (!bPass){
            printf("test FAILED: write did not return success on bitcoin message write");
            exit(1);
        }
    }
}

void readBitcoin(DWORD * data){

}

void markRead(){
    
}
