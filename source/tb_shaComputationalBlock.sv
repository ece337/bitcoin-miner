// File name:   tb_shaComputationalBlock.sv
// Created:     12/3/2016
// Author:      Arjun Bery
// Lab Section: 337-01
// Version:     3.0 SHA computational block test bench w/ Bitcoin sized inputs
// Description: Test bench for SHA computational block
//              Expected outputs are generated from online SHA 256 calculator

module tb_shaComputationalBlock ();

localparam MSG_SIZE = 640;

reg tb_clk, tb_n_rst, tb_beginComputation, tb_computationComplete;
reg [MSG_SIZE - 1:0] tb_inputMsg;
reg [255:0] tb_SHAoutput;

// shaComputationalBlock instance
shaComputationalBlock SHA
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
	input [MSG_SIZE - 1:0] msg;
	input [255:0] expectedOutput;
begin
	tb_inputMsg = msg; // assign input message
	tb_beginComputation = 1'b1; // begin computation
	#(CLK_PERIOD);
	tb_beginComputation = 1'b0;
	while(~tb_computationComplete) begin // wait until computation is complete
		#(CLK_PERIOD);
	end
	
	testcase = testcase + 1;
	assert (tb_SHAoutput == expectedOutput) $info("Test case %0d: SUCCESS - SHA output is correct!\n", testcase);
	else $error("Test case %0d: FAILURE - SHA output did not match expected output\n", testcase);
	
	#(CLK_PERIOD);
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
	//sendMsg(0, 256'he3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855);
	
	// Test case 2 - check correct SHA output for input 'hello'
	//sendMsg("hello", 256'h2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824);
	
	// Test case 3 - check correct SHA output for input 'a'
	//sendMsg("a", 256'hca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb);
	
	// Test case 4 - check correct SHA output for input 'ece337'
	//sendMsg("ece337", 256'h0d2a1646240edf5d53e1898faedf59e3578cdac873c0d7f05c6be8452cbff563);
	
	// Test case 5 - check correct SHA output for input with multiple chunks 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
	//sendMsg("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 256'h11ee391211c6256460b6ed375957fadd8061cafbb31daf967db875aebd5aaad4);
	
	// Test case 6 - check correct SHA output for input with multiple chunks '00400000e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855584cc3f01d00ffff'
	sendMsg(640'h00400000e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855584cc3f01d00ffff00000001, 256'h12ab50d488d6ed958b8a51e32137b70a37609a92b7222046cccfad644c8a3f6b);
	
	// Test case 7 - check correct SHA output for input with multiple chunks '00000014'
	sendMsg({640'h00000014}, 256'ha8c1246c3560a961f4d580adc0917cbfe75b571dec02d7e8b6a2bbb23b51cec7);
	
end

endmodule
