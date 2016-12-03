module tb_controller ();

reg tb_clk, tb_n_rst, tb_newTarget, tb_newMsg, tb_complete, tb_valid,
tb_overflow, tb_loadTarget, tb_loadMsg, tb_reset, tb_beginSHA,
tb_increment, tb_loadResults, tb_error;

controller DUT
(
	.clk(tb_clk),
	.n_rst(tb_n_rst),
	.newTarget(tb_newTarget),
	.newMsg(tb_newMsg),
	.complete(tb_complete),
	.valid(tb_valid),
	.overflow(tb_overflow),
	.loadTarget(tb_loadTarget),
	.loadMsg(tb_loadMsg),
	.reset(tb_reset),
	.beginSHA(tb_beginSHA),
	.increment(tb_increment),
	.loadResults(tb_loadResults),
	.error(tb_error)
);

localparam CLK_PERIOD = 20ns;
integer testcase = 0;
integer i = 0;

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

task checkOutputs;
	input [6:0] outputArray;
	output integer same;
begin
	same = outputArray == {tb_loadTarget, tb_loadMsg, tb_reset, tb_beginSHA, tb_increment, tb_loadResults, tb_error};
end
endtask

initial begin
	integer check;
	tb_n_rst = 1'b1;
	tb_newTarget = 1'b0;
	tb_newMsg = 1'b0;
	tb_complete = 1'b0;
	tb_valid = 1'b0;
	tb_overflow = 1'b0;
	
	reset;
	
	#(0.01)
	
	tb_newTarget = 1'b1;
	#(CLK_PERIOD);
	tb_newTarget = 1'b0;
	checkOutputs(7'b1000000, check);
	assert(check == 1'b1)
	else $error("incorrect loadTarget");
	
	tb_newMsg = 1'b1;
	#(CLK_PERIOD);
	tb_newMsg = 1'b0;
	checkOutputs(7'b0100000, check);
	assert(check == 1)
	else $error("incorrect loadMsg");

	#(CLK_PERIOD);
	checkOutputs(7'b0001000, check);
	assert(check == 1)
	else $error("incorrect beginSHA");

	#(CLK_PERIOD);
	checkOutputs(7'b0000000, check);
	assert(check == 1)
	else $error("incorrect outputs");

	#(CLK_PERIOD);
	checkOutputs(7'b0000000, check);
	assert(check == 1)
	else $error("incorrect outputs");

	#(CLK_PERIOD);
	checkOutputs(7'b0000000, check);
	assert(check == 1)
	else $error("incorrect outputs");

	#(CLK_PERIOD);
	checkOutputs(7'b0000000, check);
	assert(check == 1)
	else $error("incorrect outputs");

	
	// Test case 1 - check basic incrementing
	

	$info("All tests complete");
end

endmodule