module nonce_generator
#(
	parameter RESTART_VAL = 0,
	parameter MAX_VAL = 1024
)
(
	input wire clk,
	input wire n_rst,
	input wire enable,
	input wire reset,
	output wire overflow,
	output reg [31:0] nonce
);

reg [31:0] nextNonce;

assign overflow = nonce == MAX_VAL;

always_ff @ (posedge clk, negedge n_rst) begin
	if(!n_rst)
		nonce <= 0;
	else
		nonce <= nextNonce;
end

always_comb begin
	nextNonce = nonce;
	if (reset)
		nextNonce = RESTART_VAL;
	else if (enable && nonce < MAX_VAL)
		nextNonce = nonce + 1;
end

endmodule
