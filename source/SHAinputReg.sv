module SHAinputReg
(
	input clk,
	input n_rst,
	input loadControl,
	input [439:0] msg,
	output [439:0] SHAinput
);

reg [439:0] currentInput, nextInput;

assign SHAipnut = currentInput;

always_ff @ (posedge clk, negedge n_rst)
begin
	if(!n_rst) begin
		currentInput <= 0;
	end else if(loadControl) begin
		currentInput <= msg;
	end else begin
		currentInput <= currentInput;
	end
end

endmodule