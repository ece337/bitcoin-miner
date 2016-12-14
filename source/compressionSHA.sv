// File name:   compressionSHA.sv
// Created:     11/15/2016
// Author:      Weston Spalding
// Lab Section: 337-01
// Version:     2.0 Compression loop w/ registers
// Description: SHA Compression loop calculator

module compressionSHA
(
	input wire clk,          // clock
	input wire n_rst,        // n_reset
	input wire enable,       // enable signal to move through compression loop
	input wire loadHash,     // signal to load in current hash value
	input wire [255:0] hash, // current hash value
	input wire [31:0] w_i,   // w word from extension
	input wire [31:0] k_i,   // k word from initialization
	output reg [31:0] a,     // hash output 1
	output reg [31:0] b,     // hash output 2
	output reg [31:0] c,     // hash output 3
	output reg [31:0] d,     // hash output 4
	output reg [31:0] e,     // hash output 5
	output reg [31:0] f,     // hash output 6
	output reg [31:0] g,     // hash output 7
	output reg [31:0] h      // hash output 8
);

reg [31:0] na, nb, nc, nd, ne, nf, ng, nh; // next state for hash outputs
reg [31:0] s1, ch, temp1, s0, maj, temp2;
reg [31:0] er6, er11, er25, ar2, ar13, ar22;

assign er6 = {e[5:0],e[31:6]}; // e rotated right 6 bits
assign er11 = {e[10:0],e[31:11]}; // e rotated right 11 bits
assign er25 = {e[24:0],e[31:25]}; // e rotated right 25 bits
assign ar2 = {a[1:0],a[31:2]}; // a rotated right 2 bits
assign ar13 = {a[12:0],a[31:13]}; // a rotated right 13 bits
assign ar22 = {a[21:0],a[31:22]}; // a rotated right 22 bits

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
	end else if (loadHash) begin // load in current hash value
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
	
	// compression loop bit operations and additions
	s1 = er6 ^ er11 ^ er25;
	ch = (e & f) ^ ((~e) & g);
	temp1 = h + s1 + ch + k_i + w_i;
	s0 = ar2 ^ ar13 ^ ar22;
	maj = (a & b) ^ (a & c) ^ (b & c);
	temp2 = s0 + maj;
	
	if (enable) begin // compression loop next values
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
