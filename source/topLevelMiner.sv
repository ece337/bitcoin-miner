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
localparam NUM_SHABLOCKS = 10;
localparam LOG2_NUM_SHABLOCKS = 4;

wire validFromComparator, overflowFromNonceGen, ltFromController,
lmFromController, resetFromController, incFromController, errFromController,
beginComputationFromController, newTargetFromED, newMsgFromED,
btcFoundFromController, completeFromSHAoutputCounter;
logic [NUM_SHABLOCKS - 1:0] beginSHA, computationCompleteFromSHA;
logic [LOG2_NUM_SHABLOCKS - 1:0] countFromSHAoutputCounter;

logic [NONCE_SIZE - 1:0] nonce;

wire [MESSAGE_SIZE - 1:0] messageFromRegisters;
wire [TOTAL_SIZE - 1:0] messageWithNonce;

logic [NUMBER_OF_REGISTERS - 1:0][DATAWIDTH - 1:0] registersFromSlave;
wire [NUM_SHABLOCKS - 1:0][255:0] SHAoutfromSHABlock;
logic [NUM_SHABLOCKS - 1:0][255:0] finishedSHA;
logic [33:0] resultsReg;

assign messageFromRegisters = registersFromSlave[29:11];
assign messageWithNonce = {messageFromRegisters, nonce};
assign validFromComparator = finishedSHA[countFromSHAoutputCounter] < registersFromSlave[9:2];

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

always_ff @ (posedge clk, negedge n_rst) begin
	if (!n_rst)
		beginSHA = '0;
	else if (beginComputationFromController)
		beginSHA = {(NUM_SHABLOCKS - 1) * 1'b0, 1'b1};
	else
		beginSHA = beginSHA << 1;
end

genvar i;
generate
for (i = 0; i < NUM_SHABLOCKS; i++) begin : generateBlock1
	shaComputationalBlock #(TOTAL_SIZE) SHABLOCK_X 
	(
		.clk(clk),
		.n_rst(n_rst),
		.inputMsg({messageFromRegisters, nonce + i}),
		.beginComputation(beginSHA[i]),
		.computationComplete(computationCompleteFromSHA[i]),
		.SHAoutput(SHAoutfromSHABlock[i])
	);
end
endgenerate



/*comparator COMPE
(
	.target(registersFromSlave[9:2]),
	.SHAoutput(finishedSHA[countFromSHAoutputCounter]),
	.valid(validFromComparator)
);*/

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
	if(!n_rst || newMsgFromED) begin
		resultsReg <= '0;
	end else if(btcFoundFromController) begin
		resultsReg[31:0] <= (nonce + countFromSHAoutputCounter - 1);
		resultsReg[32] <= 1'b1;
		resultsReg[33] <= 1'b1;
	end else if(errFromController) begin
		resultsReg[33] <= 1'b1;
		resultsReg[32] <= 1'b0;
	end
end

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
