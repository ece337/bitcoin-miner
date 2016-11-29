module tb_SHAcomputationalBlock ();

reg tb_clk, tb_n_rst, tb_beginComputation, tb_enableComputation, tb_computationComplete;
reg [511:0] tb_inputSHAMsg;
reg [255:0] tb_shaOutput;

SHAcomputationalBlock SHA
(
	.clk(tb_clk),
	.n_rst(tb_n_rst),
	.inputSHAMsg(tb_inputSHAMsg),
	.beginComputation(tb_beginComputation),
	.enableComputation(tb_enableComputation),
	.computationComplete(tb_computationComplete),
	.shaOutput(tb_shaOutput)
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
	input [511:0] msg;
	input [255:0] expectedOutput;
begin
	tb_inputSHAMsg = msg;
	tb_beginComputation = 1'b1;
	tb_enableComputation = 1'b1;
	#(CLK_PERIOD);
	tb_beginComputation = 1'b0;
	#(CLK_PERIOD*100);
	tb_enableComputation = 1'b0;
	
	testcase = testcase + 1;
	assert (tb_computationComplete == 1'b1)
	else $error("Test case %0d: SHA computation did not complete in allotted time\n", testcase);
	assert (tb_shaOutput == expectedOutput) $info("Test case %0d: SHA output is correct!\n", testcase);
	else $error("Test case %0d: SHA output did not match expected output\n", testcase);
end
endtask

initial begin
	tb_n_rst = 1'b1;
	tb_inputSHAMsg = '0;
	tb_beginComputation = 1'b0;
	tb_enableComputation = 1'b0;
	
	reset;
	
	// Test case 1 - check correct SHA output
	sendMsg(512'b0, 256'he3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855);
end

endmodule
