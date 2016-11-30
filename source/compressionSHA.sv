module compressionSHA
(
	input wire clk,
	input wire n_rst,
	input wire enable,
	input wire [31:0] w_i,
	input wire [31:0] k_i,
	output reg [31:0] a,
	output reg [31:0] b,
	output reg [31:0] c,
	output reg [31:0] d,
	output reg [31:0] e,
	output reg [31:0] f,
	output reg [31:0] g,
	output reg [31:0] h
);

reg [31:0] na, nb, nc, nd, ne, nf, ng, nh;
reg [31:0] s1, ch, temp1, s0, maj, temp2;
reg [31:0] er6, er11, er25, ar2, ar13, ar22;

assign er6 = {e[5:0],e[31:6]};
assign er11 = {e[10:0],e[31:11]};
assign er25 = {e[24:0],e[31:25]};
assign ar2 = {a[1:0],a[31:2]};
assign ar13 = {a[12:0],a[31:13]};
assign ar22 = {a[21:0],a[31:22]};

always_ff @ (posedge clk, negedge n_rst) begin
	if(!n_rst) begin
		a <= 32'h6a09e667;
		b <= 32'hbb67ae85;
		c <= 32'h3c6ef372;
		d <= 32'ha54ff53a;
		e <= 32'h510e527f;
		f <= 32'h9b05688c;
		g <= 32'h1f83d9ab;
		h <= 32'h5be0cd19;
	end else begin
		a <= na;
		b <= nb;
		c <= nc;
		d <= nd;
		e <= ne;
		f <= nf;
		g <= ng;
		h <= nh;
	end
end

always_comb begin
	na = a;
	nb = b;
	nc = c;
	nd = d;
	ne = e;
	nf = f;
	ng = g;
	nh = h;
	
	if (enable) begin
		s1 = er6 ^ er11 ^ er25;
		ch = (e & f) ^ ((~e) & g);
		temp1 = h + s1 + ch + k_i + w_i;
		s0 = ar2 ^ ar13 ^ ar22;
		maj = (a & b) ^ (a & c) ^ (b & c);
		temp2 = s0 + maj;
		
		nh = g;
		ng = f;
		nf = e;
		ne = d + temp1;
		nd = c;
		nc = b;
		nb = a;
		na = temp1 + temp2;
	end
end

endmodule
