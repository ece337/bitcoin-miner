module preprocessor
(
	input reg [446:0] inputMsg,
	input wire [63:0] length,
	input wire newMsg,
	output reg [511:0] processedMsg,
	output reg done
);

reg [447:0] preprocess;

always @ (posedge newMsg) begin
	done = 1'b0;
	preprocess = {inputMsg, 1'b1};
	while (preprocess[447] == 1'b0) begin
		preprocess = {preprocess[446:0], 1'b0};
	end
	processedMsg = {inputMsg, 1'b1, length};
	done = 1'b1;
end

endmodule
