module comparator
(
	input wire [255:0] target,
	input wire [255:0] SHAoutput,
	output wire valid
);

assign valid = SHAoutput < target;

endmodule
