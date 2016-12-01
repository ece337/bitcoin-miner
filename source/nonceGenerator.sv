module nonce_generator
(
	input wire clk,
	input wire n_rst,
	input wire enable,
	input wire restart,
	output wire overflow,
	output reg [31:0] nonce
);

reg [31:0] nextNonce;

assign overflow = (nonce == '1);

always_ff @ (posedge clk, negedge n_rst) begin
	if(!n_rst)
		nonce <= 0;
	else
		nonce <= nextNonce;
end

always_comb begin
	nextNonce = nonce;
	if (restart)
		nextNonce = '0;
	else if (enable)
		nextNonce = nonce + 1;
end

endmodule
