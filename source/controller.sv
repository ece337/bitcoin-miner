// File name:   controller.sv
// Created:     11/28/2016
// Author:      Joe Aronson
// Lab Section: 337-01
// Version:     4.0 Controller loop w/ only necessary signals
// Description: Internal controller for Bitcoin miner

module controller
(
	input wire clk,                // clock
	input wire n_rst,              // n_reset
	input wire newTarget,          // signal that new target is loaded
	input wire newMsg,             // signal that new message is loaded
	input wire complete,           // signal that first SHA block is done
	input wire valid,              // signal that a valid Bitcoin has been found
	input wire overflow,           // signal that nonce has overflowed and exhausted all values
	input wire finishedValidating, // signal that no SHA blocks found a valid Bitcoin for that nonce
	output wire beginSHA,          // signal to SHA blocks to begin computation
	output wire increment,         // signal to nonce to increment to next value
	output wire btcFound,          // signal that a Bitcoin has been found
	output wire error              // signal that controller has entered an error state
);

parameter [3:0] IDLE = 0,
                NEWTARGET = 1,
                SHABEGIN = 2,
                SHAWAIT = 3,
                SHACOMPLETE = 4,
                BTCINVALID = 5,
                BTCVALID = 6,
                EIDLE = 7;

reg [4:0] state, next_state;

always_ff @ (posedge clk, negedge n_rst) begin
	if (!n_rst)
		state <= IDLE;
	else
		state <= next_state;
end

// signals that go with certain states
assign beginSHA = state == SHABEGIN;
assign increment = state == BTCINVALID;
assign btcFound = state == BTCVALID;
assign error = state == EIDLE;

always_comb begin
	next_state = state;
	case (state)
	IDLE: begin
		// idle state waits for new target or message to be loaded
		next_state = newTarget ? NEWTARGET :
		             newMsg    ? SHABEGIN  :
		                         IDLE;
	end
	NEWTARGET: begin
		// go back to idle state after seeing target has been loaded
		next_state = IDLE;
	end
	SHABEGIN: begin
		// send SHA begin signal then enter wait state
		next_state = SHAWAIT;
	end
	SHAWAIT: begin
		// wait for SHA blocks to compute their outputs
		next_state = complete ? SHACOMPLETE : SHAWAIT;
	end
	SHACOMPLETE: begin
		// if no Bitcoins were found, go to Bitcoin invalid state;
		// if a Bitcoin was found, go to Bitcoin valid state;
		// else state in SHA complete state until all SHA blocks have reported
		next_state = finishedValidating ? BTCINVALID :
                             valid              ? BTCVALID   :
                                                  SHACOMPLETE;
	end
	BTCINVALID: begin
		// increment nonce and begin SHA again or go to eidle state if nonce has been exhausted
		next_state = overflow ? EIDLE : SHABEGIN;
	end
	BTCVALID: begin
		// once Bitcoin has been found, go back to idle state
		next_state = IDLE;
	end
	EIDLE: begin
		// eidle state waits for new target or message to be loaded
		next_state = newTarget ? NEWTARGET :
		             newMsg    ? SHABEGIN  :
		                         EIDLE;
	end
	endcase
end

endmodule
