module preprocessor
(
	input wire clk,
	input wire n_rst,
	input reg [439:0] inputMsg,
	input wire beginPreprocess,
	output wire [511:0] processedMsg,
	output wire done
);

parameter [1:0] IDLE = 0,
		APPEND1 = 1,
                APPEND0 = 2,
                DONE = 3;

reg [1:0] state, next_state;
reg [447:0] preprocess, next_preprocess;
reg [63:0] length, next_length;

assign done = state == DONE;
assign processedMsg = {preprocess, length};

always_ff @ (posedge clk, negedge n_rst) begin
	if (!n_rst) begin
		state = IDLE;
		preprocess = '0;
		length = 64'd440;
	end else begin
		state = next_state;
		preprocess = next_preprocess;
		length = next_length;
	end
end

always_comb begin
	next_state = state;
	next_preprocess = preprocess;
	next_length = length;
	case (state)
	IDLE: begin
		next_state = beginPreprocess ? APPEND1 : IDLE;
	end
	APPEND1: begin
		next_state = APPEND0;
		next_preprocess = {inputMsg, 8'h80};
	end
	APPEND0: begin
		if (preprocess[447:440] == 8'h00) begin
			next_state = APPEND0;
			next_preprocess = {preprocess[439:0], 8'h00};
			next_length = length - 8;
		end else begin
			next_state = DONE;
		end
	end
	DONE: begin
		next_state = IDLE;
	end
	endcase
end

endmodule
