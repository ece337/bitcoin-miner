// File name:   topLevelMiner.sv
// Created:     12/1/2016
// Author:      Weston Spalding
// Lab Section: 337-01
// Version:     5.0 Top level module w/ parameters and parallel SHA blocks
// Description: Top level module for Bitcoin miner includes an internal controller, Avalon slave interface,
//              parallel SHA computational blocks, SHA block counter/tracker, and nonce generator

module topLevelMiner
(
	input logic clk,                   // clock
	input logic n_rst,                 // n_reset
	input logic [4:0] slaveAddr,       // slave address to read from or write to
	input logic [31:0] slaveWriteData, // slave write data
	input logic slaveWrite,            // signal that triggers write mode
	input logic slaveRead,             // signal that triggers read mode
	input logic slaveChipSelect,       // signal that lets Avalon slave know it is being communicated with
	output logic [31:0] slaveReadData  // slave read data
);

localparam MESSAGE_SIZE = 608; // input message size
localparam NONCE_SIZE = 32; // number of bits in nonce
localparam DATAWIDTH = 32; // width of slave registers
localparam TOTAL_SIZE = MESSAGE_SIZE + NONCE_SIZE; // size of full Bitcoin message
localparam NUMBER_OF_REGISTERS = 30; // number of slave registers
localparam NUM_SHABLOCKS = 10; // number of parallel SHA computational blocks
localparam LOG2_NUM_SHABLOCKS = 4; // width of counter/tracker for SHA blocks

wire validFromComparator, overflowFromNonceGen, incFromController, errFromController,
beginComputationFromController, newTargetFromED, newMsgFromED,
btcFoundFromController, completeFromSHAoutputCounter;
logic [NUM_SHABLOCKS - 1:0] beginSHA, computationCompleteFromSHA; // red hot counters/triggers/trackers for parallel SHA blocks
logic [LOG2_NUM_SHABLOCKS - 1:0] countFromSHAoutputCounter; // value counter/tracker for parallel SHA blocks

logic [NONCE_SIZE - 1:0] nonce; // nonce value

wire [MESSAGE_SIZE - 1:0] messageFromRegisters; // input message

logic [NUMBER_OF_REGISTERS - 1:0][DATAWIDTH - 1:0] registersFromSlave; // Avalon slave registers
wire [NUM_SHABLOCKS - 1:0][255:0] SHAoutfromSHABlock; // all outputs from SHA blocks
logic [NUM_SHABLOCKS - 1:0][255:0] finishedSHA; // top level register of all outputs from SHA blocks
logic [33:0] resultsReg; // [31:0] = nonce, [33] = computation complete, [32] = Bitcoin found
                         // this gets written to slave registers

assign messageFromRegisters = registersFromSlave[29:11]; // input message read from slave registers
assign validFromComparator = finishedSHA[countFromSHAoutputCounter] < registersFromSlave[9:2]; // comparator to check if Bitcoin is valid or not

// Avalon slave instance
my_slave #(
	.SLAVE_ADDRESSWIDTH(5),  	// ADDRESSWIDTH specifies how many addresses the slave needs to be mapped to. log(NUMREGS)
	.DATAWIDTH(DATAWIDTH),    		// DATAWIDTH specifies the data width. Default 32 bits
	.NUMREGS(NUMBER_OF_REGISTERS),       		// Number of Internal Registers for Custom Logic
	.REGWIDTH(DATAWIDTH)       		// Data Width for the Internal Registers. Default 32 bits
) avalonSlave
(	
	.clk(clk),
        .reset_n(n_rst),
	
	// Bus Slave Interface
	.foundNonce(resultsReg[31:0]),
	.complete(resultsReg[33]),
	.found(resultsReg[32]),
        .slave_address(slaveAddr),
        .slave_writedata(slaveWriteData),
        .slave_write(slaveWrite),
        .slave_read(slaveRead),
        .slave_chipselect(slaveChipSelect),
//      input logic  slave_readdatavalid, 			// These signals are for variable latency reads. 
//	output logic slave_waitrequest,   			// See the Avalon Specifications for details  on how to use them.
        .slave_readdata(slaveReadData),
	.csr_registers(registersFromSlave)
);

// controller instance
controller INTCONTROLLER
(
	.clk(clk),
	.n_rst(n_rst),
	.newTarget(newTargetFromED),
	.newMsg(newMsgFromED),
	.complete(computationCompleteFromSHA[0]),
	.valid(validFromComparator),
	.overflow(overflowFromNonceGen),
	.finishedValidating(completeFromSHAoutputCounter),
	.beginSHA(beginComputationFromController),
	.increment(incFromController),
	.btcFound(btcFoundFromController),
	.error(errFromController)
);

// rising edge detector for new target
risingEdgeDetect NEWTARGET
(
	.clk(clk),
	.n_rst(n_rst),
	.currentValue(registersFromSlave[1][0]),
	.risingEdgeDetected(newTargetFromED)
);

// rising edge detector for new message
risingEdgeDetect NEWMSG
(
	.clk(clk),
	.n_rst(n_rst),
	.currentValue(registersFromSlave[1][1]),
	.risingEdgeDetected(newMsgFromED)
);

always_ff @ (posedge clk, negedge n_rst) begin
	if (!n_rst)
		beginSHA = '0;
	else if (beginComputationFromController) // every SHA begin state, reset parallel SHA begin signal
		beginSHA = {(NUM_SHABLOCKS - 1) * 1'b0, 1'b1}; // least significant bit [0] is set to 1
	else
		beginSHA = beginSHA << 1; // shifting parallel SHA begin signal to left staggers start time of each SHA block by one clock cycle
end

genvar i;
generate // generate parallel SHA blocks
for (i = 0; i < NUM_SHABLOCKS; i++) begin : generateBlock1
	shaComputationalBlock #(TOTAL_SIZE) SHABLOCK_X 
	(
		.clk(clk),
		.n_rst(n_rst),
		.inputMsg({messageFromRegisters, nonce + i}), // each block receives the same message with an incremented nonce based on its index
		.beginComputation(beginSHA[i]), // begin computation signal from parallel SHA begin signal
		.computationComplete(computationCompleteFromSHA[i]), // computation complete signal output to parallel computation complete signal
		.SHAoutput(SHAoutfromSHABlock[i]) // SHA output sent to index of all SHA outputs
	);
end
endgenerate

// all SHA outputs register
always_ff @ (posedge clk, negedge n_rst)
begin
	if(!n_rst) begin
		finishedSHA <= '0;
	end else if(computationCompleteFromSHA) begin
		finishedSHA <= SHAoutfromSHABlock;
	end else begin
		finishedSHA <= finishedSHA;
	end
end

// results register being written based on controller state/signals
always_ff @ (posedge clk, negedge n_rst)
begin
	if(!n_rst) begin
		resultsReg <= '0;
	end else if(newMsgFromED) begin
		resultsReg <= '0; // reset for every new input message
	end else if(btcFoundFromController) begin
		resultsReg[31:0] <= (nonce + countFromSHAoutputCounter - 1); // update nonce with current nonce value plus index of SHA block that found valid Bitcoin
		resultsReg[32] <= 1'b1; // update complete to 1
		resultsReg[33] <= 1'b1; // update found to 1
	end else if(errFromController) begin
		resultsReg[33] <= 1'b1; // update complete to 1
		resultsReg[32] <= 1'b0; // update found to 0
	end
end

// nonce generator instance
nonceGenerator #(0, NUM_SHABLOCKS) NONCE
(
	.clk(clk),
	.n_rst(n_rst),
	.enable(incFromController),
	.restart(newMsgFromED),
	.overflow(overflowFromNonceGen),
	.nonce(nonce)
);

reg SHAoutputCounterEnable, next_SHAoutputCounterEnable;

always_ff @ (posedge clk, negedge n_rst) begin
	if (!n_rst)
		SHAoutputCounterEnable = 1'b0;
	else
		SHAoutputCounterEnable = next_SHAoutputCounterEnable;
end

always_comb begin
	next_SHAoutputCounterEnable = SHAoutputCounterEnable;
	if (computationCompleteFromSHA[0])
		next_SHAoutputCounterEnable = 1'b1;
	else if (completeFromSHAoutputCounter)
		next_SHAoutputCounterEnable = 1'b0;
end

// SHA block counter/tracker instance
counter #(LOG2_NUM_SHABLOCKS, 0, NUM_SHABLOCKS) SHAOUTPUTCOUNTER
(
	.clk(clk),
	.n_rst(n_rst),
	.enable(SHAoutputCounterEnable),
	.restart(computationCompleteFromSHA[0]),
	.complete(completeFromSHAoutputCounter),
	.currentCount(countFromSHAoutputCounter)
);

endmodule
