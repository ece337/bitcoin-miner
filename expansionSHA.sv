module firstSHA
(
	input clk,
	input n_rst,
	input [511:0] inputMsg,
	output [255:0] hash,
	output computationComplete		
);

reg h0 = 32'h6a09e667;
reg h1 = 32'hbb67ae85;
reg h2 = 32'h3c6ef372;
reg h3 = 32'ha54ff53a;
reg h4 = 32'h510e527f;
reg h5 = 32'h9b05688c;
reg h6 = 32'h1f83d9ab;
reg h7 = 32'h5be0cd19;

reg [63:0] k;
reg [63:0] [31:0] w;
reg [31:0] s0;
reg [31:0] s1;
integer i;

reg [31:0] wr7, wr18, wrs3, wr17, wr19, wrs10;

assign wr7  = {w[i - 15][6:0],w[i - 15][31:7]};
assign wr18 = {w[i - 15][17:0],w[i - 15][31:18]};
assign wrs3 = (w[i - 15] >> 3);
assign wr17 = {w[i - 2][16:0],w[i - 2][31:17]};
assign wr19 = {w[i - 2][18:0],w[i - 2][31:19]};
assign wrs10= (w[i - 2] >> 10);

initial begin
	k[0] = 32'h428a2f98;
	k[1] = 32'h71374491;
	k[2] = 32'hb5c0fbcf;
	k[3] = 32'he9b5dba5;
	k[4] = 32'h3956c25b;
	k[5] = 32'h59f111f1;
	k[6] = 32'h923f82a4;
	k[7] = 32'hab1c5ed5;
	k[8] = 32'hd807aa98;
	k[9] = 32'h12835b01;
	k[10] = 32'h243185be;
	k[11] = 32'h550c7dc3;
	k[12] = 32'h72be5d74;
	k[13] = 32'h80deb1fe;
	k[14] = 32'h9bdc06a7;
	k[15] = 32'hc19bf174;
	k[16] = 32'he49b69c1;
	k[17] = 32'hefbe4786;
	k[18] = 32'h0fc19dc6;
	k[19] = 32'h240ca1cc;
	k[20] = 32'h2de92c6f;
	k[21] = 32'h4a7484aa;
	k[22] = 32'h5cb0a9dc;
	k[23] = 32'h76f988da;
	k[24] = 32'h983e5152;
	k[25] = 32'ha831c66d;
	k[26] = 32'hb00327c8;
	k[27] = 32'hbf597fc7;
	k[28] = 32'hc6e00bf3;
	k[29] = 32'hd5a79147;
	k[30] = 32'h06ca6351;
	k[31] = 32'h14292967;
	k[32] = 32'h27b70a85;
	k[33] = 32'h2e1b2138;
	k[34] = 32'h4d2c6dfc;
	k[35] = 32'h53380d13;
	k[36] = 32'h650a7354;
	k[37] = 32'h766a0abb;
	k[38] = 32'h81c2c92e;
	k[39] = 32'h92722c85;
	k[40] = 32'ha2bfe8a1;
	k[41] = 32'ha81a664b;
	k[42] = 32'hc24b8b70;
	k[43] = 32'hc76c51a3;
	k[44] = 32'hd192e819;
	k[45] = 32'hd6990624;
	k[46] = 32'hf40e3585;
	k[47] = 32'h106aa070;
	k[48] = 32'h19a4c116;
	k[49] = 32'h1e376c08;
	k[50] = 32'h2748774c;
	k[51] = 32'h34b0bcb5;
	k[52] = 32'h391c0cb3;
	k[53] = 32'h4ed8aa4a;
	k[54] = 32'h5b9cca4f;
	k[55] = 32'h682e6ff3;
	k[56] = 32'h748f82ee;
	k[57] = 32'h78a5636f;
	k[58] = 32'h84c87814;
	k[59] = 32'h8cc70208;
	k[60] = 32'h90befffa;
	k[61] = 32'ha4506ceb;
	k[62] = 32'hbef9a3f7;
	k[63] = 32'hc67178f2;
end



always_comb
begin
	s0 = wr7 ^ wr18 ^ wrs3;
	s1 = wr17 ^ wr19 ^ wrs10;
	w[i] = w[i - 16] + s0 + w[i - 7] + s1;
end


endmodule