module extensionSHA
(
	input wire clk,
	input wire n_rst,
	input wire enable,
	input reg [511:0] inputMsg,
	input wire [6:0] i,
	input wire loadInitial,
	output reg [63:0][31:0] w
);

reg h0 = 32'h6a09e667;
reg h1 = 32'hbb67ae85;
reg h2 = 32'h3c6ef372;
reg h3 = 32'ha54ff53a;
reg h4 = 32'h510e527f;
reg h5 = 32'h9b05688c;
reg h6 = 32'h1f83d9ab;
reg h7 = 32'h5be0cd19;

reg [63:0] [31:0] nextW;
reg [31:0] s0;
reg [31:0] s1;

reg [31:0] wr7, wr18, wrs3, wr17, wr19, wrs10;

always_ff @ (posedge clk, negedge n_rst) begin
	if(!n_rst)
		w = '0;
	else if (loadInitial) begin
		w[0] = {inputMsg[7:0], inputMsg[15:8], inputMsg[23:16], inputMsg[31:24]};
		w[1] = {inputMsg[41:32], inputMsg[49:42], inputMsg[55:48], inputMsg[63:56]};
		w[2] = {inputMsg[71:64], inputMsg[79:72], inputMsg[87:80], inputMsg[95:88]};
		w[3] = {inputMsg[103:96], inputMsg[111:104], inputMsg[119:112], inputMsg[127:120]};
		w[4] = {inputMsg[135:128], inputMsg[143:136], inputMsg[151:144], inputMsg[159:152]};
		w[5] = {inputMsg[167:160], inputMsg[175:168], inputMsg[183:176], inputMsg[191:184]};
		w[6] = {inputMsg[199:192], inputMsg[207:200], inputMsg[215:208], inputMsg[223:216]};
		w[7] = {inputMsg[231:224], inputMsg[239:232], inputMsg[247:240], inputMsg[255:248]};
		w[8] = {inputMsg[263:256], inputMsg[271:264], inputMsg[279:272], inputMsg[287:280]};
		w[9] = {inputMsg[295:288], inputMsg[303:296], inputMsg[311:304], inputMsg[319:312]};
		w[10] = {inputMsg[327:320], inputMsg[335:328], inputMsg[343:336], inputMsg[351:344]};
		w[11] = {inputMsg[359:352], inputMsg[367:360], inputMsg[375:368], inputMsg[383:376]};
		w[12] = {inputMsg[391:384], inputMsg[399:392], inputMsg[407:400], inputMsg[415:408]};
		w[13] = {inputMsg[423:416], inputMsg[431:424], inputMsg[446:432], inputMsg[447:440]};
		w[14] = {inputMsg[455:448], inputMsg[463:456], inputMsg[471:464], inputMsg[479:472]};
		w[15] = {inputMsg[487:480], inputMsg[495:488], inputMsg[503:496], inputMsg[511:504]};
	end else
		w[i] = nextW[i];
end

always_comb begin
	nextW[i] = w[i];
	if (enable) begin
		wr7  = {w[i - 15][6:0], w[i - 15][31:7]};
		wr18 = {w[i - 15][17:0], w[i - 15][31:18]};
		wrs3 = (w[i - 15] >> 3);
		wr17 = {w[i - 2][16:0], w[i - 2][31:17]};
		wr19 = {w[i - 2][18:0], w[i - 2][31:19]};
		wrs10= (w[i - 2] >> 10);
		s0 = wr7 ^ wr18 ^ wrs3;
		s1 = wr17 ^ wr19 ^ wrs10;
		nextW[i] = w[i - 16] + s0 + w[i - 7] + s1;
	end
end

endmodule
