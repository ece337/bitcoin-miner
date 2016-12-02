module topLevelMiner
(
	input logic clk,
	input logic n_rst,
	input logic newTarget,
	input logic newMsg,
	input logic [255:0] inputTarget,
	input logic [407:0] inputMsg,
	output logic [255:0] targetOutput,
	output logic [255:0] SHAoutput,
	output logic validBTC
);

wire validFromComparator, overflowFromNonceGen, ltFromController,
lmFromController, resetFromController, incFromController, errFromController,
beginComputationFromController, newTargetFromED, newMsgFromED, computationCompleteFromSHA;

logic [31:0] nonce;

wire [407:0] messageFromRegisters;
wire [439:0] messageWithNonce;

logic [23:0][31:0] registersFromSlave;
wire [255:0] SHAoutfromSHABlock;
logic [255:0] finishedSHA; 

assign registersFromSlave[0][1] = newMsg;
assign registersFromSlave[0][0] = newTarget;
assign registersFromSlave[15:4] = inputMsg[407:24];
assign registersFromSlave[3][31:8] = inputMsg[23:0];
assign registersFromSlave[23:16] = inputTarget;

assign messageFromRegisters = {registersFromSlave[15:4], registersFromSlave[3][31:8]};
assign messageWithNonce = {messageFromRegisters, nonce};

assign targetOutput = registersFromSlave[23:16];
assign SHAoutput = finishedSHA;
assign validBTC = validFromComparator;

/*custom_slave #(
	MASTER_ADDRESSWIDTH = 26 ,  	// ADDRESSWIDTH specifies how many addresses the Master can address 
	SLAVE_ADDRESSWIDTH = 3 ,  	// ADDRESSWIDTH specifies how many addresses the slave needs to be mapped to. log(NUMREGS)
	DATAWIDTH = 32 ,    		// DATAWIDTH specifies the data width. Default 32 bits
	NUMREGS = 24 ,       		// Number of Internal Registers for Custom Logic
	REGWIDTH = 32       		// Data Width for the Internal Registers. Default 32 bits
) avalonSlave
(	
	.clk(clk),
        .reset_n(n_rst),
	
	// Interface to Top Level
	.rdwr_cntl(,					// Control Read or Write to a slave module.
	.n_action(,					// Trigger the Read or Write. Additional control to avoid continuous transactions. Not a required signal. Can and should be removed for actual application.
	.add_data_sel(,				// Interfaced to switch. Selects either Data or Address to be displayed on the Seven Segment Displays.
	.rdwr_address(,	// read_address if required to be sent from another block. Can be unused if consecutive reads are required.

	// Bus Slave Interface
        .slave_address(,
        .slave_writedata(,
        .slave_write(,
        .slave_read(,
        .slave_chipselect(,
//      input logic  slave_readdatavalid, 			// These signals are for variable latency reads. 
//	output logic slave_waitrequest,   			// See the Avalon Specifications for details  on how to use them.
        .slave_readdata(,
	.csr_registers(registersFromSlave)

);*/

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
	.target(registersFromSlave[23:16]),
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
