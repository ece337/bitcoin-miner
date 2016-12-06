module tb_nonceGenerator ();

reg tb_clk, tb_n_rst, tb_enable, tb_restart, tb_overflow;
reg [31:0] tb_nonce;

nonceGenerator #(0,1) DUT
(
	.clk(tb_clk),
	.n_rst(tb_n_rst),
	.enable(tb_enable),
	.restart(tb_restart),
	.overflow(tb_overflow),
	.nonce(tb_nonce)
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

initial begin
	tb_n_rst = 1'b1;
	tb_enable = 1'b0;
	tb_restart = 1'b0;
	
	reset;
	
	#(0.1)
	
	// Test case 1 - check basic incrementing
	assert(tb_nonce == 0)
	else $error("incorrect nonce value");

	for(i = 0; i < 65565; i++)
	begin
		tb_enable = 1'b1;
		#(CLK_PERIOD);
		tb_enable = 1'b0;
		#(CLK_PERIOD);
		assert(tb_nonce == i+1)
		else $error("incorrect nonce value");
		assert(tb_overflow == 0)
		else $error("incorrect nonce value");
	end

	reset;
	assert(tb_nonce == 0)
	else $error("incorrect nonce value");

	for(i = 0; i < 100; i++)
	begin
		tb_enable = 1'b1;
		#(CLK_PERIOD);
		tb_enable = 1'b0;
		#(CLK_PERIOD);
		assert(tb_nonce == i+1)
		else $error("incorrect nonce value");
	end

	tb_restart = 1'b1;
	#(CLK_PERIOD);
	tb_restart = 1'b0;
	#(CLK_PERIOD);

	assert(tb_nonce == 0)
	else $error("incorrect nonce value");

	for(i = 0; i < 100; i++)
	begin
		tb_enable = 1'b1;
		#(CLK_PERIOD);
		tb_enable = 1'b0;
		#(CLK_PERIOD);
		assert(tb_nonce == i+1)
		else $error("incorrect nonce value");
	end

	$info("All tests complete!");
end

endmodule
