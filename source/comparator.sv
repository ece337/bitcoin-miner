module comparator
(
	input wire [255:0] target,
	input wire [255:0] msg,
	output wire valid
);

assign valid = msg < target;

endmodule
