module tb_test ();

reg tb_clk, tb_n_rst, tb_beginComputation, tb_computationComplete, tb_temp, tb_extEnable, tb_beginExt;
reg [639:0] tb_inputMsg;
reg [1:0][511:0] tb_processed;
reg [255:0] tb_SHAoutput, tb_outout;
reg [63:0][31:0] tb_wext;

test DUT
(
	.clk(tb_clk),
	.n_rst(tb_n_rst),
	.inputMsg(tb_inputMsg),
	.beginComputation(tb_beginComputation),
	.computationComplete(tb_computationComplete),
	.SHAoutput(tb_SHAoutput),
	.processedMsg(tb_processed),
	.extEnable(tb_extEnable),
	.beginExt(tb_beginExt),
	.outout(tb_outout),
	.w_extSHA(tb_wext)
);

localparam CLK_PERIOD = 20ns;
integer testcase = 0;
integer size = 0;

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
	input [639:0] msg;
	input [255:0] expectedOutput;
begin
	tb_inputMsg = msg;
	tb_beginComputation = 1'b1;
	#(CLK_PERIOD);
	tb_beginComputation = 1'b0;
	#(CLK_PERIOD*230);
	#(CLK_PERIOD*70);
	
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
	length = 0;
	while(msg[length] != 0)
	begin
		length = length + 1;
	end
end
endtask

initial begin
	tb_n_rst = 1'b1;
	tb_inputMsg = '0;
	tb_beginComputation = 1'b0;
	
	reset;
	
	// Test case 1 - check correct SHA output for input ''
	sendMsg(640'd0,          256'he3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855);
	
	reset;
	
	// Test case 2 - check correct SHA output for input 'hello'
	sendMsg(640'h68656c6c6f, 256'h2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824);
	
	reset;
	
	// Test case 3 - check correct SHA output for input 'a'
	sendMsg(640'd97,         256'hca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb);

	reset; 
	
	strlen("hello", size);
	sendMsg({(640 - size) * 1'd0, "hello"}, 256'h2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824);
end

endmodule
