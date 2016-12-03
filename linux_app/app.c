#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <memory.h>
#include <math.h>

#include "PCIE.h"
#include "mapping.h"
#include "sha256.c"
#include "bitcoin.h"

void initializePCIe();
void operation_loop();
void dummy_loop();
void constructBitcoinMessage(DWORD*);
float difficulty(unsigned int bits)

PCIE_HANDLE hPCIe;

char * usage = "For dummy mode, pass the flag -d.\n";

int main(argc, char ** argv)
{
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
    for(int i = 0; i < 8; i++){
        if(h1[i] > h2[i]){
            return 0;
        }
        if(h1[i] < h2[i]){
            return 1;
        }
    }
    return 1;
}

void printDWORDString(DWORD * output){
    for(int i = 0; i < 8; i++){
        printf("%04x", output[i]);
    }
}

void verifySHAoutput(char * output, DWORD * difficulty){
	uchar hash[32];
	sha(output, hash, 20);
    DWORD converted[8];
	ucharsToDWORD(hash,converted);
	if(compareHashes(converted, difficulty)){
        printf("Bitcoin is valid!\n");
    }else{
        printf("Bitcoin is not valid!\n");
    }
    printf("Bitcoin:    ");
    printDWORDString(converted);
    printf("\nDifficulty: ");
    printDWORDString(difficulty);
    printf("\n\n");
}

void operation_loop(){
    DWORD difficulty[8];
    DWORD bitcoinMessage[19];
    state_t currentState;
    calculateDifficulty(difficulty);

    pauseMining();
    constructBitcoinMessage(bitcoinMessage);
    writeBitcoinMessage(bitcoinMessage);
    resumeMining();

    while(true){
        printf("Mining...");
        while((current_state = getState()) == MINING);
        if(current_state == SUCCESSFUL){
            printf("Prospective Bitcoin Found!\n");
            printf("verifying...\n");
            DWORD bitcoin[20];
            readBitcoin(bitcoin);
            verifySHAoutput(bitcoin,difficulty);
        }else if(current_state == WAITING){
            printf("No Bitcoins found on current block.\n");
            pauseMining();
            constructBitcoinMessage(bitcoinMessage);
            writeBitcoinMessage(bitcoinMessage);
            resumeMining();
        }else{
            printf("The miner has fallen into an unknown state.\n");
            exit(1);
        }
    }
}
