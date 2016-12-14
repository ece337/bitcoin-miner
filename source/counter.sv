// File name:   counter.sv
// Created:     11/28/2016
// Author:      Joe Aronson
// Lab Section: 337-01
// Version:     2.0 Counter with NUM_BITS parameter
// Description: Counter with restart and maximum values

module counter
#(
	parameter NUM_BITS = 7,    // number of bits needed to store count value
	parameter RESTART_VAL = 0, // value to set count back to
	parameter MAX_VAL = 64     // upper limit of count
)
(
	input wire clk,                        // clock
	input wire n_rst,                      // n_reset
	input wire enable,                     // enable signal to count up
	input wire restart,                    // restart signal to go back to restart value
	output wire complete,                  // complete asserted when counter reaches max value
	output reg [NUM_BITS-1:0] currentCount // current count
);

reg [NUM_BITS-1:0] nextCount;

assign complete = currentCount == MAX_VAL; // complete when current count reaches max value

always_ff @ (posedge clk, negedge n_rst) begin
	if(!n_rst)
		currentCount <= RESTART_VAL;
	else
		currentCount <= nextCount;
end

always_comb begin
	nextCount = currentCount;
	if (restart) // reset count if given restart signal
		nextCount = RESTART_VAL;
	else if (enable) begin
		if (currentCount < MAX_VAL)
			nextCount = currentCount + 1; // count up if max value won't be reached
		else
			nextCount = RESTART_VAL; // wrap around to restart value if max value has been reached
	end
end

endmodule
