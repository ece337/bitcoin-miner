module tb_SHAcomputationalBlock ();

reg tb_clk, tb_n_rst, tb_beginComputation, tb_computationComplete;
reg [439:0] tb_inputMsg;
reg [255:0] tb_SHAoutput;

SHAcomputationalBlock SHA
(
	.clk(tb_clk),
	.n_rst(tb_n_rst),
	.inputMsg(tb_inputMsg),
	.beginComputation(tb_beginComputation),
	.computationComplete(tb_computationComplete),
	.SHAoutput(tb_SHAoutput)
);

localparam CLK_PERIOD = 20ns;
integer testcase = 0;
integer length = 0;

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
	input [439:0] msg;
	input [255:0] expectedOutput;
begin
	tb_inputMsg = msg;
	tb_beginComputation = 1'b1;
	#(CLK_PERIOD);
	tb_beginComputation = 1'b0;
	#(CLK_PERIOD*230);
	
	testcase = testcase + 1;
	assert (tb_computationComplete == 1'b1)
	else $error("Test case %0d: FAILURE - SHA computation did not complete in allotted time\n", testcase);
	assert (tb_SHAoutput == expectedOutput) $info("Test case %0d: SUCCESS - SHA output is correct!\n", testcase);
	else $error("Test case %0d: FAILURE - SHA output did not match expected output\n", testcase);
end
endtask

task strlen;
	input string msg;
	output integer length;
begin
	integer q = 0;
	while(msg[q] != '\0')
	begin
		q = q + 1;
	end
	length = q;
end

initial begin
	tb_n_rst = 1'b1;
	tb_inputMsg = '0;
	tb_beginComputation = 1'b0;
	
	reset;
	
	// Test case 1 - check correct SHA output for input ''
	sendMsg(440'd0,          256'he3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855);
	
	reset;
	
	// Test case 2 - check correct SHA output for input 'hello'
	sendMsg(440'h68656c6c6f, 256'h2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824);
	
	reset;
	
	// Test case 3 - check correct SHA output for input 'a'
	sendMsg(440'd97,         256'hca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb);

	reset; 
	
	length = 440 - strlen("hello");
	sendMsg({length * 1'd0, "hello"}, 256'h2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824);
end

endmodule
