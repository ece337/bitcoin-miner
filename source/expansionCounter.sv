module expansionCounter
(
	input wire clk,
	input wire n_rst,
	input wire enable,
	input wire restart,
	output wire complete,
	output reg [6:0] currentCount
);

reg [6:0] nextCount;

assign complete = currentCount == 64;

always_ff @ (posedge clk, negedge n_rst)
begin
	if(!n_rst) begin
		currentCount <= '0;
	end else if(restart) begin
		currentCount <= 16;
	end else if(enable) begin
		currentCount <= nextCount;
	end else begin
		currentCount <= currentCount;
	end
end

always_comb
begin
	if(currentCount < 64) begin
		nextCount = currentCount + 1;
	end
end

endmodule