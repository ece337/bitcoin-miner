module compressionCounter
(
	input wire clk,
	input wire n_rst,
	input wire restart,
	output wire complete,
	output reg [6:0] currentCount
);

counter #(0, 64) CCOUNT (
	.clk(clk),
	.n_rst(n_rst),
	.restart(restart),
	.complete(complete),
	.currentCount(currentCount)
);

endmodule
