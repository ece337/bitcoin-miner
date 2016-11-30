module counter
#(
	parameter RESTART_VAL = 0,
	parameter MAX_VAL = 64
)
(
	input wire clk,
	input wire n_rst,
	input wire enable,
	input wire restart,
	output wire complete,
	output reg [6:0] currentCount
);

reg [6:0] nextCount;

assign complete = currentCount == MAX_VAL;

always_ff @ (posedge clk, negedge n_rst) begin
	if(!n_rst)
		currentCount <= RESTART_VAL;
	else
		currentCount <= nextCount;
end

always_comb begin
	nextCount = currentCount;
	if (restart)
		nextCount = RESTART_VAL;
	else if (enable) begin
		if (currentCount < MAX_VAL)
			nextCount = currentCount + 1;
		else
			nextCount = RESTART_VAL;
	end
end

endmodule
