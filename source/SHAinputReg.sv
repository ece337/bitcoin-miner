module SHAinputReg
(
	input clk,
	input n_rst,
	input loadControl,
	input [31:0] nonce,
	input [414:0] msg,
	output [511:0] SHAinput
);

reg [511:0] currentInput, nextInput;

assign SHAipnut = currentInput;

always_ff @ (posedge clk, negedge n_rst)
begin
	if(!n_rst) begin
		currentInput <= 0;
	end else if(loadControl) begin
		currentInput <= {msg[414:0], nonce[31:0], 1'b1, 64'd414};
	end else begin
		currentInput <= currentInput;
	end
end

endmodule