module topLevelMiner
(
	input logic clk,
	input logic n_rst,
	input logic [4:0] slaveAddr,
	input logic [31:0] slaveWriteData,
	input logic slaveWrite,
	input logic slaveRead,
	input logic slaveChipSelect,
	output logic [31:0] slaveReadData
);

localparam MESSAGE_SIZE = 608;
localparam NONCE_SIZE = 32;
localparam DATAWIDTH = 32;
localparam TOTAL_SIZE = MESSAGE_SIZE + NONCE_SIZE;
localparam NUMBER_OF_REGISTERS = 30;

wire validFromComparator, overflowFromNonceGen, ltFromController,
lmFromController, resetFromController, incFromController, errFromController,
beginComputationFromController, newTargetFromED, newMsgFromED, computationCompleteFromSHA,
btcFoundFromController;

logic [NONCE_SIZE - 1:0] nonce;

wire [MESSAGE_SIZE - 1:0] messageFromRegisters;
wire [TOTAL_SIZE - 1:0] messageWithNonce;

logic [NUMBER_OF_REGISTERS - 1:0][DATAWIDTH - 1:0] registersFromSlave;
wire [255:0] SHAoutfromSHABlock;
logic [255:0] finishedSHA;
logic [33:0] resultsReg;

assign messageFromRegisters = registersFromSlave[29:11];
assign messageWithNonce = {messageFromRegisters, nonce};


custom_slave #(
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

controller INTCONTROLLER
(
	.clk(clk),
	.n_rst(n_rst),
	.newTarget(newTargetFromED),
	.newMsg(newMsgFromED),
	.complete(computationCompleteFromSHA),
	.valid(validFromComparator),
	.overflow(overflowFromNonceGen),
	.loadTarget(ltFromController),
	.loadMsg(lmFromController),
	.reset(resetFromController),
	.beginSHA(beginComputationFromController),
	.increment(incFromController),
	.btcFound(btcFoundFromController),
	.error(errFromController)
);

risingEdgeDetect NEWTARGET
(
	.clk(clk),
	.n_rst(n_rst),
	.currentValue(registersFromSlave[1][0]),
	.risingEdgeDetected(newTargetFromED)
);

risingEdgeDetect NEWMSG
(
	.clk(clk),
	.n_rst(n_rst),
	.currentValue(registersFromSlave[1][1]),
	.risingEdgeDetected(newMsgFromED)
);

SHAcomputationalBlock #(TOTAL_SIZE) SHABLOCK 
(
	.clk(clk),
	.n_rst(n_rst),
	.inputMsg(messageWithNonce),
	.beginComputation(beginComputationFromController),
	.computationComplete(computationCompleteFromSHA),
	.SHAoutput(SHAoutfromSHABlock)
);

comparator COMPARE
(
	.target(registersFromSlave[9:2]),
	.SHAoutput(finishedSHA),
	.valid(validFromComparator)
);

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

always_ff @ (posedge clk, negedge n_rst)
begin
	if(!n_rst) begin
		resultsReg <= '0;
	end else if(btcFoundFromController) begin
		resultsReg[31:0] <= nonce;
		resultsReg[32] <= 1'b1;
		resultsReg[33] <= 1'b1;
	end else if(errFromController) begin
		resultsReg[33] <= 1'b1;
		resultsReg[32] <= 1'b0;
	end
end

nonceGenerator #(0) NONCE
(
	.clk(clk),
	.n_rst(n_rst),
	.enable(incFromController),
	.restart(newMsgFromED),
	.overflow(overflowFromNonceGen),
	.nonce(nonce)
);

endmodule
