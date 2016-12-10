
#ifndef _BITCOIN_MAPPING
#define _BITCOIN_MAPPING

#include "PCIE.h"

extern PCIE_HANDLE hPCIe;

#define FACTOR 4
#define CRA 0x00000000		// This is the starting address of the Custom Slave module. This maps to the address space of the custom module in the Qsys subsystem.
#define BITCOIN_WORDS 19
#define TARGET_WORDS 8
#define BITCOIN_ADDRESS (CRA + (11*FACTOR))
#define TARGET_ADDRESS (CRA + (2*FACTOR))
#define CONTROL_ADDRESS (CRA + (1*FACTOR))
#define STATUS_ADDRESS (CRA)
#define NONCE_ADDRESS (CRA + (10*FACTOR))
#define SUCCESS_BIT_SET(x) (x & 0x00000002)
#define STOPPED_BIT_SET(x) (x & 0x00000001)
#define UNSET_PAUSE_BIT(x) (x |= 0xFFFFFFFF)
#define SET_PAUSE_BIT(x) (x &= 0x00000000)

enum state_type{
    MINING,
    WAITING,
    SUCCESSFUL,
    UNKNOWN
};

typedef enum state_type state_t;

DWORD reverseBits(DWORD x);
void writeValue(DWORD addr, DWORD value);
DWORD readValue(DWORD addr);
void writeDifficultyMessage(DWORD * difficulty);
void pauseMining();
void resumeMining();
state_t getState();
void writeToControlRegister(DWORD value);
DWORD readFromStatusRegister();
void writeBitcoinMessage(DWORD * data);
void readBitcoin(DWORD * data);
void readDifficulty(DWORD * data);

#endif
