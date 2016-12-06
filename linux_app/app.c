#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <memory.h>
#include <math.h>
#include <unistd.h>

#include "PCIE.h"
#include "mapping.h"
#include "sha256.h"
#include "bitcoin.h"

void initializePCIe();
void operation_loop();

PCIE_HANDLE hPCIe;

int main(){
	initializePCIe();
	operation_loop();
	return 0;
}

void initializePCIe(){
	void *lib_handle;

	lib_handle = PCIE_Load();		// Dynamically Load the PCIE library
	if (!lib_handle){
		printf("PCIE_Load failed\n");
		exit(1);
	}
	hPCIe = PCIE_Open(0,0,0);		// Every device is a like a file in UNIX. Opens the PCIE device for reading/writing

	if (!hPCIe){
		printf("PCIE_Open failed\n");
		exit(1);
	}
}

int compareHashes(DWORD * h1, DWORD * h2){
    int i;
    for(i = 0; i < 8; i++){
        if(h1[i] > h2[i]){
            return 0;
        }
        if(h1[i] < h2[i]){
            return 1;
        }
    }
    return 1;
}

void printDWORDString(DWORD * output, int length){
    int i;
    for(i = 0; i < length; i++){
        printf("%08x", output[i]);
    }
}

void verifySHAoutput(DWORD * output, DWORD * difficulty){
	uchar hash[32];
	sha((char *)output, hash, 80);
    DWORD converted[8];
	ucharsToDWORD(hash,converted);
	if(compareHashes(converted, difficulty)){
        printf("Bitcoin is valid!\n");
    }else{
        printf("Bitcoin is not valid!\n");
    }
    printf("Bitcoin:    ");
    printDWORDString(converted,8);
    printf("\nDifficulty: ");
    printDWORDString(difficulty,8);
    printf("\n\n");
}

void operation_loop(){
    DWORD difficulty[8];
    DWORD bitcoinMessage[19];
    state_t currentState;
    calculateDifficulty(difficulty);

    

    while(1){
	pauseMining();
    constructBitcoinMessage(bitcoinMessage);
    writeBitcoinMessage(bitcoinMessage);
	printf("Writing Bitcoin:  ");
	printDWORDString(bitcoinMessage,19);
	printf("\n");
    resumeMining();
        printf("Mining...\n");
        while((currentState = getState()) == MINING){
            sleep(2);
            DWORD bitcoin[20];
            printf("\n\n\n Status Update: ");
            readBitcoin(bitcoin);
            printDWORDString(bitcoin,20);
        }
        if(currentState == SUCCESSFUL){
            printf("Prospective Bitcoin Found!\n");
            printf("verifying...\n");
            DWORD bitcoin[20];
            readBitcoin(bitcoin);
            verifySHAoutput(bitcoin,difficulty);
        }else if(currentState == WAITING){
            printf("No Bitcoins found on current block.\n");
        }else{
            printf("The miner has fallen into an unknown state.\n");
            exit(1);
        }
    }
}
