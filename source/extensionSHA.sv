// File name:   extensionSHA.sv
// Created:     11/15/2016
// Author:      Weston Spalding
// Lab Section: 337-01
// Version:     2.0 Extension loop with registers
// Description: SHA extension loop calculator

module extensionSHA
(
	input wire clk,            // clock
	input wire n_rst,          // n_reset
	input wire enable,         // enable signal to move through extension loop
	input wire loadInitial,    // signal to load in 512 bit chunk words into w register array
	input reg [511:0] chunk,   // 512 bit chunk to extend
	input wire [6:0] i,        // current index of w register array to compute
	output reg [63:0][31:0] w  // w extension array
);

reg [63:0] [31:0] nextW;
reg [31:0] s0;
reg [31:0] s1;

reg [31:0] wr7, wr18, wrs3, wr17, wr19, wrs10;

always_ff @ (posedge clk, negedge n_rst) begin
	if(!n_rst)
		w = '0;
	else if (loadInitial) begin // load in chunk into w register array
		w[15] = chunk[31:0];
		w[14] = chunk[63:32];
		w[13] = chunk[95:64];
		w[12] = chunk[127:96];
		w[11] = chunk[159:128];
		w[10] = chunk[191:160];
		w[9]  = chunk[223:192];
		w[8]  = chunk[255:224];
		w[7]  = chunk[287:256];
		w[6]  = chunk[319:288];
		w[5]  = chunk[351:320];
		w[4]  = chunk[383:352];
		w[3]  = chunk[415:384];
		w[2]  = chunk[447:416];
		w[1]  = chunk[479:448];
		w[0]  = chunk[511:480];
		w[63:16] = '0;
	end else
		w = nextW;
end

always_comb begin
	nextW = w;
	if (enable) begin // extension loop calculations
		wr7  = {w[i - 15][6:0], w[i - 15][31:7]}; // w[i-15] rotated right 7 bits
		wr18 = {w[i - 15][17:0], w[i - 15][31:18]}; // w[i-15] rotated right 18 bits
		wrs3 = (w[i - 15] >> 3); // w[i-15] shifted right 3 bits
		wr17 = {w[i - 2][16:0], w[i - 2][31:17]}; // w[i-2] rotated right 17 bits
		wr19 = {w[i - 2][18:0], w[i - 2][31:19]}; // w[i-2] rotated right 19 bits
		wrs10= (w[i - 2] >> 10); // w[i-2] shifted right 10 bits
		s0 = wr7 ^ wr18 ^ wrs3; // extension bit operation
		s1 = wr17 ^ wr19 ^ wrs10; // extension bit operation
		nextW[i] = w[i - 16] + s0 + w[i - 7] + s1; // w[i] calculation
	end else begin
		wr7  = 0;
		wr18 = 0;
		wrs3 = 0;
		wr17 = 0;
		wr19 = 0;
		wrs10= 0;
		s0 = 0;
		s1 = 0;
		//nextW[i] = w[i - 16];
	end
end

endmodule
