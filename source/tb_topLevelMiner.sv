module tb_topLevelMiner();

reg tb_clk, tb_n_rst, tb_newTarget, tb_newMsg, tb_validBTC;
reg [407:0] tb_inputMsg;
reg [255:0] tb_inputTarget, tb_targetOutput, tb_SHAoutput;

topLevelMiner TLM (
	.clk(tb_clk),
	.n_rst(tb_n_rst),
	.newTarget(tb_newTarget),
	.newMsg(tb_newMsg),
	.inputTarget(tb_inputTarget),
	.inputMsg(tb_inputMsg),
	.targetOutput(tb_targetOutput),
	.SHAoutput(tb_SHAoutput),
	.validBTC(tb_validBTC)
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

task loadTarget;
	input [255:0] target;
begin
	tb_inputTarget = target;
	tb_newTarget = 1'b1;
	#(CLK_PERIOD);
	tb_newTarget = 1'b0;
	#(CLK_PERIOD*2);
	
	testcase = testcase + 1;
	assert (tb_targetOutput == target) $info("Test case %0d: SUCCESS - New target loaded in correctly!\n", testcase);
	else $error("Test case %0d: FAILURE - New target did not load in correctly\n", testcase);
end
endtask

task sendMsg;
	input [407:0] msg;
	input [255:0] expectedOutput;
begin
	tb_inputMsg = msg;
	tb_newMsg = 1'b1;
	#(CLK_PERIOD);
	tb_newMsg = 1'b0;
	#(CLK_PERIOD*230);
	
	testcase = testcase + 1;
	assert (tb_SHAoutput == expectedOutput) $info("Test case %0d: SUCCESS - SHA output is correct!\n", testcase);
	else $error("Test case %0d: FAILURE - SHA output did not match expected output\n", testcase);
end
endtask

initial begin
	tb_n_rst = 1'b1;
	tb_newTarget = 1'b0;
	tb_newMsg = 1'b0;
	tb_inputTarget = '0;
	tb_inputMsg = '0;
	
	reset;
	
	loadTarget(256'h1000000010000000100000001000000010000000100000001000000010000000);
	
	// Test case 1 - check correct SHA output for input ''
	sendMsg(408'h0, 256'he3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855);
end

endmodule
