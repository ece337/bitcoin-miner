#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <memory.h>
#include <math.h>

#include "PCIE.h"
#include "sha256.c"

//MAX BUFFER FOR DMA
#define MAXDMA 32

#define BITCOIN_WORDS 19
#define 

//BASE ADDRESS FOR CONTROL REGISTER
#define CRA 0x00000000		// This is the starting address of the Custom Slave module. This maps to the address space of the custom module in the Qsys subsystem.

//BASE ADDRESS TO SDRAM
#define SDRAM 0x08000000	// This is the starting address of the SDRAM controller. This maps to the address space of the SDRAM controller in the Qsys subsystem.
#define START_BYTE 0xF00BF00B
#define RWSIZE (32 / 8)
PCIE_BAR pcie_bars[] = { PCIE_BAR0, PCIE_BAR1 , PCIE_BAR2 , PCIE_BAR3 , PCIE_BAR4 , PCIE_BAR5 };

void initializePCIe();
void operation_loop();
void dummy_loop();
void constructBitcoinMessage(DWORD*)

PCIE_HANDLE hPCIe;
DWORD writeAddress = CRA;
DWORD nonceAddress  = CRA + BITCOIN_WORDS;
DWORD controlAddress = CRA + BITCOIN_WORDS + 1;
DWORD signalAddress = CRA + BITCOIN_WORDS + 2;


char * usage = "For dummy mode, pass the flag -d.\n";

int main(argc, char ** argv)
{
	initializePCIe();

	DWORD * data = malloc(sizeof(DWORD)*BITCOIN_WORDS);

	if(argc == 1){
		operation_loop();
	}else if(strcmp(argv[1], "-d") == 0){
		dummy_loop();
	}else{
		printf(usage);
		exit(1);
	}
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

inline float fast_log(float val)
{
   int * const exp_ptr = reinterpret_cast <int *>(&val);
   int x = *exp_ptr;
   const int log_2 = ((x >> 23) & 255) - 128;
   x &= ~(255 << 23);
   x += 127 << 23;
   *exp_ptr = x;
 
   val = ((-1.0f/3) * val + 2) * val - 2.0f/3;
   return ((val + log_2) * 0.69314718f);
} 
 
float difficulty(unsigned int bits){
    static double max_body = fast_log(0x00ffff), scaland = fast_log(256);
    return exp(max_body - fast_log(bits & 0x00ffffff) + scaland * (0x1d - ((bits & 0xff000000) >> 24)));
}

void verifySHAoutput(char * output, difficulty){
	uchar hash[32];
	SHA256_CTX ctx;
	sha256_init(&ctx);
	sha256_update(&ctx,output,BITCOIN_WORDS + 1);
	sha256_final(&ctx,hash);
	
}

void constructBitcoinMessage(DWORD * data){

}

void updateBitcoinMessage(){

}

void writeBitcoinMessage(DWORD * data){
	for(int i = 0; i < BITCOIN_WORDS; i++){
		BOOL bPass = PCIE_Write32( hPCIe, pcie_bars[0], addr + i, data[i]);
		if (!bPass){
			printf("test FAILED: write did not return success on setup");
			return;
		}
	}
}

//Tests 16 consecutive PCIE_Write32 to addresses mapping to the Custom Slave

void test32( PCIE_HANDLE hPCIe, DWORD addr ){
	BOOL bPass;
	DWORD testVal = 0xf;
	DWORD readVal;

	WORD i = 0;
	for (i = 0; i < 16 ; i++ )
	{
		printf("Testing register %d at addr %x with value %x\n", i, addr, testVal);
		bPass = PCIE_Write32( hPCIe, pcie_bars[0], addr, testVal);
		if (!bPass)
		{
			printf("test FAILED: write did not return success");
			return;
		}
		bPass = PCIE_Read32( hPCIe, pcie_bars[0], addr, &readVal);
		if (!bPass)
		{
			printf("test FAILED: read did not return success");
			return;
		}
		if (testVal == readVal)
		{
			printf("Test PASSED: expected %x, received %x\n", testVal, readVal);
		}
		else
		{
			printf("Test FAILED: expected %x, received %x\n", testVal, readVal);
		}
		testVal = testVal + 1;
		addr = addr + 4;
	}
	return;
}
