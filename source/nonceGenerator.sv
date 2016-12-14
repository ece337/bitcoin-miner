// File name:   nonceGenerator.sv
// Created:     11/28/2016
// Author:      Joe Aronson
// Lab Section: 337-01
// Version:     2.0 Nonce Generator/Counter w/ skip parameter
// Description: Nonce Generator for appending to Bitcoin message

module nonceGenerator
#(
	parameter START_VAL = 0, // start value of nonce
	parameter SKIP = 3       // value to count up by (number of parallel SHA blocks)
)
(
	input wire clk,          // clock
	input wire n_rst,        // n_reset
	input wire enable,       // enable signal to trigger an increment in nonce
	input wire restart,      // restart signal to trigger a reset
	output wire overflow,    // overflow signal that nonce reached its max value
	output reg [31:0] nonce  // current nonce value
);

reg [31:0] nextNonce;

assign overflow = (nonce == '1); // assert overflow if nonce is its max value

always_ff @ (posedge clk, negedge n_rst) begin
	if(!n_rst)
		nonce <= START_VAL;
	else
		nonce <= nextNonce;
end

always_comb begin
	nextNonce = nonce;
	if (restart) // if restart, set nonce back to start value
		nextNonce = START_VAL;
	else if (enable) // if enable, increase nonce by skip value
		nextNonce = nonce + SKIP;
end

endmodule
