module preprocessor
#(
	parameter MESSAGE_SIZE = 640
)
(
	input wire [MESSAGE_SIZE - 1:0] inputMsg,
	output wire [1:0][511:0] processedMsg
);

reg [383:0] append = {8'h80, 312'h0, 64'd640}; // append 1, then 0's, then length of 640

assign processedMsg = {inputMsg, append};

endmodule
