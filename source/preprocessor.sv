module preprocessor
#(
	parameter MESSAGE_SIZE = 640
)
(
	input wire clk,
	input wire n_rst,
	input wire [MESSAGE_SIZE - 1:0] inputMsg,
	input wire beginPreprocess,
	output wire [1:0][511:0] processedMsg,
	output wire [1:0] position,
	output wire done
);

parameter [2:0] IDLE = 0,
		APPEND1 = 2,
                FINDLENGTH = 1,
                APPEND0 = 3,
                DONE = 4;

reg [2:0] state, next_state;
reg [MESSAGE_SIZE + 7:0] preCopy, next_preCopy;
reg [959:0] preprocess, next_preprocess;
reg [63:0] length, next_length, size, next_size;

assign position = (size + 64) / 512 - 1;
assign done = state == DONE;
assign processedMsg = {preprocess, length};

always_ff @ (posedge clk, negedge n_rst) begin
	if (!n_rst) begin
		state = IDLE;
		preCopy = '0;
		preprocess = '0;
		length = '0;
		size = '0;
	end else begin
		state = next_state;
		preCopy = next_preCopy;
		preprocess = next_preprocess;
		length = next_length;
		size = next_size;
	end
end

always_comb begin
	next_state = state;
	next_preCopy = preCopy;
	next_preprocess = preprocess;
	next_length = length;
	next_size = size;
	
	case (state)
	IDLE: begin
		next_state = beginPreprocess ? APPEND1 : IDLE;
	end
	APPEND1: begin
		next_state = FINDLENGTH;
		next_preCopy = {inputMsg, 8'h80};
		next_preprocess = {inputMsg, 8'h80};
		next_length = MESSAGE_SIZE;
	end
	FINDLENGTH: begin
		if (preCopy[MESSAGE_SIZE + 7:MESSAGE_SIZE-24] == 32'h0) begin
			next_state = FINDLENGTH;
			next_preCopy = preCopy << 32;
			next_length = length - 32;
		end else if (preCopy[MESSAGE_SIZE + 7:MESSAGE_SIZE-8] == 16'h0) begin
			next_state = FINDLENGTH;
			next_preCopy = preCopy << 16;
			next_length = length - 16;
		end else if (preCopy[MESSAGE_SIZE + 7:MESSAGE_SIZE] == 8'h00) begin
			next_state = FINDLENGTH;
			next_preCopy = preCopy << 8;
			next_length = length - 8;
		end else begin
			next_state = APPEND0;
			next_size = length + 8;
		end
	end
	APPEND0: begin
		if (size % 512 != 448) begin
			next_state = APPEND0;
			next_preprocess = preprocess << 8;
			next_size = size + 8;
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
