module tb_SHAcomputationalBlock ();

reg tb_clk, tb_n_rst, tb_newMsg, tb_beginComputation, tb_computationComplete;
reg [446:0] tb_inputMsg;
reg [63:0] tb_inputLength;
reg [255:0] tb_SHAoutput;

SHAcomputationalBlock SHA
(
	.clk(tb_clk),
	.n_rst(tb_n_rst),
	.inputMsg(tb_inputMsg),
	.inputLength(tb_inputLength),
	.newMsg(tb_newMsg),
	.beginComputation(tb_beginComputation),
	.computationComplete(tb_computationComplete),
	.SHAoutput(tb_SHAoutput)
);

localparam CLK_PERIOD = 20ns;
integer testcase = 0;

always begin
	tb_clk = 1'b0;
	#(CLK_PERIOD/2);
	tb_clk = 1'b1;
	#(CLK_PERIOD/2);
end

task reset;
begin
	tb_n_rst = 1'b0;
	#(CLK_PERIOD*2);
	tb_n_rst = 1'b1;
	#(CLK_PERIOD);
end
endtask

task sendMsg;
	input [446:0] msg;
	input [63:0] length;
	input [255:0] expectedOutput;
begin
	tb_inputMsg = msg;
	tb_newMsg = 1'b1;
	tb_beginComputation = 1'b1;
	#(CLK_PERIOD);
	tb_newMsg = 1'b0;
	tb_beginComputation = 1'b0;
	#(CLK_PERIOD*10000);
	
	testcase = testcase + 1;
	assert (tb_computationComplete == 1'b1)
	else $error("Test case %0d: SHA computation did not complete in allotted time\n", testcase);
	assert (tb_SHAoutput == expectedOutput) $info("Test case %0d: SHA output is correct!\n", testcase);
	else $error("Test case %0d: SHA output did not match expected output\n", testcase);
end
endtask

initial begin
	tb_n_rst = 1'b1;
	tb_newMsg = 1'b0;
	tb_inputMsg = '0;
	tb_beginComputation = 1'b0;
	
	reset;
	
	// Test case 1 - check correct SHA output
	sendMsg(447'd97, 64'd7, 256'hca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb);
end

endmodule
