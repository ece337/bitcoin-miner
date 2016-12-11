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

void DWORDToUCHAR(DWORD * input, uchar * output){
    int i;
    for(i = 0; i < 20; i++){
        output[(i*4)+0] = (input[i] >> 24) & 0xFF;
        output[(i*4)+1] = (input[i] >> 16) & 0xFF;
        output[(i*4)+2] = (input[i] >> 8) & 0xFF;
        output[(i*4)+3] = input[i] & 0xFF;
    }
}

void verifySHAoutput(DWORD * output, DWORD * difficulty){
	uchar * hash = malloc(32);
    uchar * message = malloc(80);
    DWORDToUCHAR(output,message);
	sha(message, hash, 80);
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
    DWORD * difficulty = (DWORD*)malloc(sizeof(DWORD)*8);
    DWORD * bitcoinMessage = (DWORD*)malloc(sizeof(DWORD)*19);
    DWORD * bitcoin = (DWORD*)malloc(sizeof(DWORD)*20);
    state_t currentState;
    pauseForTarget();
    calculateDifficulty(difficulty);
    writeDifficultyMessage(difficulty);
    resumeFromTarget();
    sleep(1);
    while(1){
        pauseMining();
        constructBitcoinMessage(bitcoinMessage);
        writeBitcoinMessage(bitcoinMessage);
        printf("Writing Bitcoin:  ");
        printDWORDString(bitcoinMessage,19);
        printf("\n");
        resumeMining();
        printf("Mining...\n");
        sleep(1);
        while((currentState = getState()) == MINING){
            sleep(1);
            
            readBitcoin(bitcoin);
            printf("\n\n Status Update: ");
            printDWORDString(bitcoin,20);
            printf("\n\n");
            readDifficulty(difficulty);
            printf(" Difficulty:    ");
            printDWORDString(difficulty,8);
            
            printf("\n");
        }
        if(currentState == SUCCESSFUL){
            printf("Prospective Bitcoin Found!\n");
            printf("verifying...\n");
            readBitcoin(bitcoin);
            printf("\n\n Current Candidate: ");
            printDWORDString(bitcoin,20);
            printf("\n\n");
            verifySHAoutput(bitcoin,difficulty);
        }else if(currentState == WAITING){
            printf("No Bitcoins found on current block.\n");
        }else{
            printf("The miner has fallen into an unknown state.\n");
            exit(1);
        }
    }
}
