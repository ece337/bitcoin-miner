module startcounter
#(
	parameter NUM_BITS = 7,
	parameter RESTART_VAL = 0,
	parameter MAX_VAL = 64
)
(
	input wire clk,
	input wire n_rst,
	input wire start,
	output reg [NUM_BITS-1:0] currentCount
);

reg [NUM_BITS-1:0] nextCount;

assign complete = currentCount == MAX_VAL;

always_ff @ (posedge clk, negedge n_rst) begin
	if(!n_rst)
		currentCount <= RESTART_VAL;
	else
		currentCount <= nextCount;
end

always_comb begin
	nextCount = currentCount;
	if (start) begin
		if (currentCount < MAX_VAL)
			nextCount = currentCount + 1;
		else
			nextCount = RESTART_VAL;
	end else begin
		if(currentCount > RESTART_VAL && currentCount < MAX_VAL)
			nextCount = currentCount + 1;
		else
			nextCount = RESTART_VAL;
	end
end

endmodule