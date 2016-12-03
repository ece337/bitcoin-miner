module tb_topLevelMiner();

reg tb_clk, tb_n_rst, tb_slaveWrite, tb_slaveRead, tb_slaveChipSelect;
reg [4:0] tb_slaveAddr;
reg [31:0] tb_slaveWriteData, tb_slaveReadData;

topLevelMiner DUT
(
	.clk(tb_clk),
	.n_rst(tb_n_rst),
	.slaveAddr(tb_slaveAddr),
	.slaveWriteData(tb_slaveWriteData),
	.slaveWrite(tb_slaveWrite),
	.slaveRead(tb_slaveRead),
	.slaveChipSelect(tb_slaveChipSelect),
	.slaveReadData(tb_slaveReadData)
);

localparam CLK_PERIOD = 20ns;
integer testcase = 0;
integer length;

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
	tb_slaveWrite = 1'b1;
	tb_slaveChipSelect = 1'b1;

	tb_slaveAddr = 9;
	tb_slaveWriteData = target[255:224];
	#(CLK_PERIOD);
	tb_slaveAddr = 8;
	tb_slaveWriteData = target[223:192];
	#(CLK_PERIOD);
	tb_slaveAddr = 7;
	tb_slaveWriteData = target[191:160];
	#(CLK_PERIOD);
	tb_slaveAddr = 6;
	tb_slaveWriteData = target[159:128];
	#(CLK_PERIOD);
	tb_slaveAddr = 5;
	tb_slaveWriteData = target[127:96];
	#(CLK_PERIOD);
	tb_slaveAddr = 4;
	tb_slaveWriteData = target[95:64];
	#(CLK_PERIOD);
	tb_slaveAddr = 3;
	tb_slaveWriteData = target[63:32];
	#(CLK_PERIOD);
	tb_slaveAddr = 2;
	tb_slaveWriteData = target[31:0];
	#(CLK_PERIOD);
	tb_slaveAddr = 1;
	tb_slaveWriteData = 32'h00000001;
	#(CLK_PERIOD);
	
	tb_slaveWrite = 1'b0;
end
endtask

task loadMessage;
	input [607:0] msg;
begin
	tb_slaveWrite = 1'b1;
	tb_slaveChipSelect = 1'b1;
	tb_slaveWriteData = msg[(607-((29 - 29) * 32)):(607-((29 - 29) * 32))-31];
	tb_slaveAddr = 29;
	#(CLK_PERIOD);
	tb_slaveWriteData = msg[(607-((29 - 28) * 32)):(607-((29 - 28) * 32))-31];
	tb_slaveAddr = 28;
	#(CLK_PERIOD);
	tb_slaveWriteData = msg[(607-((29 - 27) * 32)):(607-((29 - 27) * 32))-31];
	tb_slaveAddr = 27;
	#(CLK_PERIOD);
	tb_slaveWriteData = msg[(607-((29 - 26) * 32)):(607-((29 - 26) * 32))-31];
	tb_slaveAddr = 26;
	#(CLK_PERIOD);
	tb_slaveWriteData = msg[(607-((29 - 25) * 32)):(607-((29 - 25) * 32))-31];
	tb_slaveAddr = 25;
	#(CLK_PERIOD);
	tb_slaveWriteData = msg[(607-((29 - 24) * 32)):(607-((29 - 24) * 32))-31];
	tb_slaveAddr = 24;
	#(CLK_PERIOD);
	tb_slaveWriteData = msg[(607-((29 - 23) * 32)):(607-((29 - 23) * 32))-31];
	tb_slaveAddr = 23;
	#(CLK_PERIOD);
	tb_slaveWriteData = msg[(607-((29 - 22) * 32)):(607-((29 - 22) * 32))-31];
	tb_slaveAddr = 22;
	#(CLK_PERIOD);
	tb_slaveWriteData = msg[(607-((29 - 21) * 32)):(607-((29 - 21) * 32))-31];
	tb_slaveAddr = 21;
	#(CLK_PERIOD);
	tb_slaveWriteData = msg[(607-((29 - 20) * 32)):(607-((29 - 20) * 32))-31];
	tb_slaveAddr = 20;
	#(CLK_PERIOD);
	tb_slaveWriteData = msg[(607-((29 - 19) * 32)):(607-((29 - 19) * 32))-31];
	tb_slaveAddr = 19;
	#(CLK_PERIOD);
	tb_slaveWriteData = msg[(607-((29 - 18) * 32)):(607-((29 - 18) * 32))-31];
	tb_slaveAddr = 18;
	#(CLK_PERIOD);
	tb_slaveWriteData = msg[(607-((29 - 17) * 32)):(607-((29 - 17) * 32))-31];
	tb_slaveAddr = 17;
	#(CLK_PERIOD);
	tb_slaveWriteData = msg[(607-((29 - 16) * 32)):(607-((29 - 16) * 32))-31];
	tb_slaveAddr = 16;
	#(CLK_PERIOD);
	tb_slaveWriteData = msg[(607-((29 - 15) * 32)):(607-((29 - 15) * 32))-31];
	tb_slaveAddr = 15;
	#(CLK_PERIOD);
	tb_slaveWriteData = msg[(607-((29 - 14) * 32)):(607-((29 - 14) * 32))-31];
	tb_slaveAddr = 14;
	#(CLK_PERIOD);
	tb_slaveWriteData = msg[(607-((29 - 13) * 32)):(607-((29 - 13) * 32))-31];
	tb_slaveAddr = 13;
	#(CLK_PERIOD);
	tb_slaveWriteData = msg[(607-((29 - 12) * 32)):(607-((29 - 12) * 32))-31];
	tb_slaveAddr = 12;
	#(CLK_PERIOD);
	tb_slaveWriteData = msg[(607-((29 - 11) * 32)):(607-((29 - 11) * 32))-31];
	tb_slaveAddr = 11;
	#(CLK_PERIOD);

	tb_slaveAddr = 1;
	tb_slaveWriteData = 32'h00000002;
	#(CLK_PERIOD);	
	tb_slaveWrite = 1'b0;
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
	
	tb_slaveAddr = '0;
	tb_slaveWriteData = '0;
	tb_slaveWrite = 1'b0;
	tb_slaveRead = 1'b0;
	tb_slaveChipSelect = 1'b0;
	
	reset;
	
	loadTarget(256'h0100000000000000000000000000000000000000000000000000000000000000);

	strlen("a", length);
	loadMessage("a");

	tb_slaveChipSelect = 1'b1;
	tb_slaveRead = 1'b1;
	tb_slaveAddr = 0;
	#(CLK_PERIOD);
	while(tb_slaveReadData != 32'h3) begin
		#(CLK_PERIOD);
	end
	tb_slaveAddr = 10;
	#(CLK_PERIOD);
	$info("nonce found is %0d", tb_slaveReadData);
end

endmodule
