module preprocessor
(
	input wire clk,
	input wire n_rst,
	input reg [446:0] inputMsg,
	input wire [63:0] length,
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

assign done = state == DONE;
assign processedMsg = preprocess;

always_ff @ (posedge clk, negedge n_rst) begin
	if (!n_rst) begin
		state = IDLE;
		preprocess = '0;
	end else begin
		state = next_state;
		preprocess = next_preprocess;
	end
end

always_comb begin
	next_state = state;
	next_preprocess = preprocess;
	case (state)
	IDLE: begin
		next_state = beginPreprocess ? APPEND1 : IDLE;
		next_preprocess = {inputMsg, 1'b0};
	end
	APPEND1: begin
		next_state = APPEND0;
		next_preprocess = {inputMsg, 1'b1};
	end
	APPEND0: begin
		next_state = preprocess[447:444] == 4'b0 ? APPEND0 : DONE;
		next_preprocess = preprocess[447:444] == 4'b0 ? {preprocess[443:0], 4'b0} : preprocess;
	end
	DONE: begin
		next_state = IDLE;
	end
	endcase
end

endmodule
