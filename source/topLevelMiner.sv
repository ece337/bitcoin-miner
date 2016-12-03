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

wire validFromComparator, overflowFromNonceGen, ltFromController,
lmFromController, resetFromController, incFromController, errFromController,
beginComputationFromController, newTargetFromED, newMsgFromED, computationCompleteFromSHA;

logic [31:0] nonce;

wire [1943:0] messageFromRegisters;
wire [1975:0] messageWithNonce;

logic [71:0][31:0] registersFromSlave;
wire [255:0] SHAoutfromSHABlock;
logic [255:0] finishedSHA; 

assign messageFromRegisters = {registersFromSlave[63:4], registersFromSlave[3][31:8]};
assign messageWithNonce = {messageFromRegisters, nonce};


custom_slave #(
	.SLAVE_ADDRESSWIDTH(5),  	// ADDRESSWIDTH specifies how many addresses the slave needs to be mapped to. log(NUMREGS)
	.DATAWIDTH(32),    		// DATAWIDTH specifies the data width. Default 32 bits
	.NUMREGS(24),       		// Number of Internal Registers for Custom Logic
	.REGWIDTH(32)       		// Data Width for the Internal Registers. Default 32 bits
) avalonSlave
(	
	.clk(clk),
        .reset_n(n_rst),
	
	// Bus Slave Interface
	.foundNonce(nonce),
	.complete(computationCompleteFromSHA),
	.found(validFromComparator),
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
	.error(errFromController)
);

risingEdgeDetect NEWTARGET
(
	.clk(clk),
	.n_rst(n_rst),
	.currentValue(registersFromSlave[0][0]),
	.risingEdgeDetected(newTargetFromED)
);

risingEdgeDetect NEWMSG
(
	.clk(clk),
	.n_rst(n_rst),
	.currentValue(registersFromSlave[0][1]),
	.risingEdgeDetected(newMsgFromED)
);

SHAcomputationalBlock SHABLOCK
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
	.target(registersFromSlave[71:64]),
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
