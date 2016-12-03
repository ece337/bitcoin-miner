
#ifndef _BITCOIN_MAPPING
#define _BITCOIN_MAPPING

#include "PCIE.h"

extern PCIE_HANDLE hPCIe;

#define CRA 0x00000000		// This is the starting address of the Custom Slave module. This maps to the address space of the custom module in the Qsys subsystem.
#define BITCOIN_WORDS 19
#define TARGET_WORDS 8
#define BITCOIN_ADDRESS 
#define TARGET_ADDRESS
#define CONTROL_ADDRESS
#define SIGNAL_ADDRESS
#define SUCCESS_BIT_SET(x)
#define MINING_BIT_SET(x)
#define SET_PAUSE_BIT(x)
#define UNSET_PAUSE_BIT(x)

enum state_t{
    PAUSED,
    MINING,
    WAITING,
    SUCCESSFUL
}



#endif
