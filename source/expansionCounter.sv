module expansionCounter
(
	input wire clk,
	input wire n_rst,
	input wire restart,
	output wire complete,
	output reg [6:0] currentCount
);

counter #(16, 64) ECOUNT (
	.clk(clk),
	.n_rst(n_rst),
	.restart(restart),
	.complete(complete),
	.currentCount(currentCount)
);

endmodule
