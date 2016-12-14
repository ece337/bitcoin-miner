// File name:   tb_controller.sv
// Created:     12/3/2016
// Author:      Arjun Bery
// Lab Section: 337-01
// Version:     1.0 Controller test bench
// Description: Test bench for controller module

module tb_controller ();

reg tb_clk, tb_n_rst, tb_newTarget, tb_newMsg, tb_complete, tb_valid,
tb_overflow, tb_finishedValidating, tb_beginSHA, tb_increment, tb_btcFound, tb_error;

// controller instance
controller DUT
(
	.clk(tb_clk),
	.n_rst(tb_n_rst),
	.newTarget(tb_newTarget),
	.newMsg(tb_newMsg),
	.complete(tb_complete),
	.valid(tb_valid),
	.overflow(tb_overflow),
	.finishedValidating(tb_finishedValidating),
	.beginSHA(tb_beginSHA),
	.increment(tb_increment),
	.btcFound(tb_btcFound),
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
	input [3:0] outputArray;
	output integer same;
begin
	same = outputArray == {tb_beginSHA, tb_increment, tb_btcFound, tb_error};
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
	tb_finishedValidating = 1'b0;
	
	reset;
	
	#(CLK_PERIOD/2);
	
	// test new target state
	tb_newTarget = 1'b1;
	#(CLK_PERIOD);
	tb_newTarget = 1'b0;
	checkOutputs(4'b0000, check);
	assert(check == 1)
	else $error("incorrect outputs");
	#(CLK_PERIOD);
	
	// test begin SHA state
	tb_newMsg = 1'b1;
	#(CLK_PERIOD);
	tb_newMsg = 1'b0;
	checkOutputs(4'b1000, check);
	assert(check == 1)
	else $error("incorrect beginSHA");
	#(CLK_PERIOD);
	
	// test SHA wait state
	#(CLK_PERIOD*4);
	checkOutputs(4'b0000, check);
	assert(check == 1)
	else $error("incorrect outputs");
	#(CLK_PERIOD);
	
	// test SHA complete + invalid Bitcoin
	tb_complete = 1'b1;
	tb_finishedValidating = 1'b1;
	#(CLK_PERIOD*2);
	tb_complete = 1'b0;
	tb_finishedValidating = 1'b0;
	checkOutputs(4'b0100, check);
	assert(check == 1)
	else $error("incorrect increment");
	#(CLK_PERIOD);
	
	// test SHA complete + valid Bitcoin
	tb_complete = 1'b1;
	tb_valid = 1'b1;
	#(CLK_PERIOD*2);
	tb_complete = 1'b0;
	tb_valid = 1'b0;
	checkOutputs(4'b0010, check);
	assert(check == 1)
	else $error("incorrect btcFound");
	#(CLK_PERIOD);
	
	// test eidle state
	// idle -> begin SHA
	tb_newMsg = 1'b1;
	#(CLK_PERIOD);
	tb_newMsg = 1'b0;
	// begin SHA -> SHA wait
	#(CLK_PERIOD);
	// SHA wait -> SHA complete
	tb_complete = 1'b1;
	#(CLK_PERIOD);
	tb_complete = 1'b0;
	// SHA complete -> invalid Bitcoin
	tb_finishedValidating = 1'b1;
	#(CLK_PERIOD);
	tb_finishedValidating = 1'b0;
	// invalid Bitcoin -> eidle
	tb_overflow = 1'b1;
	#(CLK_PERIOD);
	tb_overflow = 1'b0;
	checkOutputs(4'b0001, check);
	assert (check == 1)
	else $error("incorrect error flag");
	#(CLK_PERIOD);

	$info("All tests complete");
end

endmodule
