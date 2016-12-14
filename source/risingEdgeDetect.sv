// File name:   risingEdgeDetect.sv
// Created:     12/1/2016
// Author:      Weston Spalding
// Lab Section: 337-01
// Version:     1.0 Rising Edge Detector
// Description: Rising edge detector

module risingEdgeDetect
(
	input wire clk,                 // clock
	input wire n_rst,               // n_reset
	input wire currentValue,        // signal to check for rising edge
	output logic risingEdgeDetected // output signal that rising edge has been detected or not
);

reg previousVal; // register to store previous clock cycle's value

// rising edge occurs when current clock cycle's value is asserted while previous clock cycle's value is not
assign risingEdgeDetected = (currentValue == 1'b1 && previousVal == 1'b0);

always_ff @ (posedge clk, negedge n_rst)
begin
	if(!n_rst) begin
		previousVal <= 1'b0;
	end else begin
		previousVal <= currentValue; // store current clock cycle's value
	end
end

endmodule
