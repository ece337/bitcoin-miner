module topLevelMiner
(
	input logic clk,
	input logic n_rst,
	
);

wire validFromComparator, overflowFromNonceGen, ltFromController,
lmFromController, resetFromController, incFromController, errFromController,
beginComputationFromController;

logic [94:0][31:0] registersFromSlave;
wire [255:0] SHAoutfromSHABlock;
logic [255:0] finishedSHA; 

custom_slave #(
	MASTER_ADDRESSWIDTH = 26 ,  	// ADDRESSWIDTH specifies how many addresses the Master can address 
	SLAVE_ADDRESSWIDTH = 3 ,  	// ADDRESSWIDTH specifies how many addresses the slave needs to be mapped to. log(NUMREGS)
	DATAWIDTH = 32 ,    		// DATAWIDTH specifies the data width. Default 32 bits
	NUMREGS = 95 ,       		// Number of Internal Registers for Custom Logic
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

);

SHAcomputationalBlock SHABlock
(
	.clk(clk),
	.n_rst(n_rst),
	.inputMsg(messageFromRegisters),
	.beginComputation(beginComputationFromController),
	.computationComplete(computationCompleteFromSHA),
	.SHAoutput(SHAoutfromSHABlock)
);

comparator compare
(
	.target(targetFromRegister),
	.msg(finishedSHA),
	.valid(validFromComparator)
);

controller internalController
(
	.clk(clk),
	.n_rst(n_rst),
	.newTarget,
	.newMsg,
	.complete,
	.valid(validFromComparator),
	.overflow(overflowFromNonceGen),
	.loadTarget(ltFromController),
	.loadMsg(lmFromController),
	.reset(resetFromController),
	.increment(incFromController),
	.error(errFromController)
	.beginComputation(beginComputationFromController)
);

always_ff @ (posedge clk, negedge n_rst)
begin
	if(!n_rst) begin
		finishedSHA <= 0';
	end else begin
		finishedSHA <= SHAoutfromSHABlock;
	end
end

endmodule