module compressionCounter
(
	input wire clk,
	input wire n_rst,
	input wire enable,
	input wire restart,
	output wire complete,
	output reg [6:0] currentCount
);

cCount #(0, 64) counter (
	.clk(clk),
	.n_rst(n_rst),
	.enable(enable),
	.restart(restart),
	.complete(complete),
	.currentCount(currentCount)
);

endmodule
