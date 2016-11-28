module expansionSHA
(
	input clk,
	input n_rst,
	input [511:0] inputMsg,
	input [6:0] i,
	input loadInitial,
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

assign out = w[32];

always_ff @ (posedge clk, negedge n_rst)
begin
	if(!n_rst) begin
		w = '0;
	end else if(loadInitial) begin
		w[0] = inputMsg[31:0];
		w[1] = inputMsg[63:32];
		w[2] = inputMsg[95:64];
		w[3] = inputMsg[127:96];
		w[4] = inputMsg[159:128];
		w[5] = inputMsg[191:160];
		w[6] = inputMsg[223:192];
		w[7] = inputMsg[255:224];
		w[8] = inputMsg[287:256];
		w[9] = inputMsg[319:288];
		w[10] = inputMsg[351:320];
		w[11] = inputMsg[383:352];
		w[12] = inputMsg[415:384];
		w[13] = inputMsg[447:416];
		w[14] = inputMsg[479:448];
		w[15] = inputMsg[511:480];
	end else begin
		w[i] = nextW[i];
	end
end

always_comb
begin
	wr7  = {w[i - 15][6:0],w[i - 15][31:7]};
	wr18 = {w[i - 15][17:0],w[i - 15][31:18]};
	wrs3 = (w[i - 15] >> 3);
	wr17 = {w[i - 2][16:0],w[i - 2][31:17]};
	wr19 = {w[i - 2][18:0],w[i - 2][31:19]};
	wrs10= (w[i - 2] >> 10);
	s0 = wr7 ^ wr18 ^ wrs3;
	s1 = wr17 ^ wr19 ^ wrs10;
	nextW[i] = w[i - 16] + s0 + w[i - 7] + s1;
end


endmodule
