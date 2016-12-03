module compressionSHA
(
	input wire clk,
	input wire n_rst,
	input wire enable,
	input wire loadHash,
	input wire [255:0] hash,
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
		a <= '0;
		b <= '0;
		c <= '0;
		d <= '0;
		e <= '0;
		f <= '0;
		g <= '0;
		h <= '0;
	end else if (loadHash) begin
		a <= hash[255:224];
		b <= hash[223:192];
		c <= hash[191:160];
		d <= hash[159:128];
		e <= hash[127:96];
		f <= hash[95:64];
		g <= hash[63:32];
		h <= hash[31:0];
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
