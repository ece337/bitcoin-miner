module tb_preprocessor ();

reg tb_clk, tb_n_rst, tb_beginPreprocess, tb_done;
reg [1:0] tb_position;
reg [1975:0] tb_inputMsg;
reg [3:0][511:0] tb_processedMsg;

preprocessor PRE
(
	.clk(tb_clk),
	.n_rst(tb_n_rst),
	.inputMsg(tb_inputMsg),
	.beginPreprocess(tb_beginPreprocess),
	.processedMsg(tb_processedMsg),
	.position(tb_position),
	.done(tb_done)
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

task preprocessMsg;
	input [1975:0] msg;
	input [3:0][511:0] expectedOutput;
begin
	tb_inputMsg = msg;
	tb_beginPreprocess = 1'b1;
	#(CLK_PERIOD);
	tb_beginPreprocess = 1'b0;
	#(CLK_PERIOD*315);
	
	testcase = testcase + 1;
	assert (tb_done == 1'b1)
	else $error("Test case %0d: FAILURE - Preprocess did not complete in allotted time\n", testcase);
	assert (tb_processedMsg == expectedOutput) $info("Test case %0d: SUCCESS - Processed output is correct!\n", testcase);
	else $error("Test case %0d: FAILURE - Processed output did not match expected output\n", testcase);
end
endtask

initial begin
	tb_n_rst = 1'b1;
	tb_inputMsg = '0;
	tb_beginPreprocess = 1'b0;
	
	reset;
	
	// Test case 1 - check correct preprocessed output of size < 448
	preprocessMsg(1976'd97, 512'h61800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008);
	
	reset;
	
	// Test case 2 - check correct preprocessed output of size > 448
	preprocessMsg(1976'h80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
                      2048'h8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200);
end

endmodule
