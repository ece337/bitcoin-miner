module extensionSHA
(
	input wire clk,
	input wire n_rst,
	input wire enable,
	input reg [511:0] inputSHAMsg,
	input wire [6:0] i,
	input wire loadInitial,
	output reg [63:0][31:0] w
);

reg [63:0] [31:0] nextW;
reg [31:0] s0;
reg [31:0] s1;

reg [31:0] wr7, wr18, wrs3, wr17, wr19, wrs10;

always_ff @ (posedge clk, negedge n_rst) begin
	if(!n_rst)
		w = '0;
	else if (loadInitial) begin
		w[15] = inputSHAMsg[31:0];
		w[14] = inputSHAMsg[63:32];
		w[13] = inputSHAMsg[95:64];
		w[12] = inputSHAMsg[127:96];
		w[11] = inputSHAMsg[159:128];
		w[10] = inputSHAMsg[191:160];
		w[9]  = inputSHAMsg[223:192];
		w[8]  = inputSHAMsg[255:224];
		w[7]  = inputSHAMsg[287:256];
		w[6]  = inputSHAMsg[319:288];
		w[5]  = inputSHAMsg[351:320];
		w[4]  = inputSHAMsg[383:352];
		w[3]  = inputSHAMsg[415:384];
		w[2]  = inputSHAMsg[447:416];
		w[1]  = inputSHAMsg[479:448];
		w[0]  = inputSHAMsg[511:480];
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
