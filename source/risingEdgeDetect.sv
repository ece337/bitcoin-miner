module risingEdgeDetect
(
	input wire clk,
	input wire n_rst,
	input wire currentValue,
	output logic risingEdgeDetected
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
