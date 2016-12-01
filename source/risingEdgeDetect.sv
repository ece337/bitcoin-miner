module risingEdgeDetect
(
	input clk,
	input n_rst,
	input logic currentValue,
	input logic risingEdgeDetected
);

reg previousVal;

assign risingEdgeDetected = (currentValue == 1'b1 && previousVal == 1'b0);

always_ff @ (posedge clk, negedge n_rst)
begin
	if(!n_rst) begin
		previousVal <= 1'b0;
	end else begin
		previousVal <= currentValue;
	end
end


endmodule