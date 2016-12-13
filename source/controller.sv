module controller
(
	input wire clk,
	input wire n_rst,
	input wire newTarget,
	input wire newMsg,
	input wire complete,
	input wire valid,
	input wire overflow,
	input wire finishedValidating,
	output wire beginSHA,
	output wire increment,
	output wire btcFound,
	output wire error
);

parameter [3:0] IDLE = 0,
                NEWTARGET = 1,
                SHABEGIN = 2,
                SHAWAIT = 3,
                SHACOMPLETE = 4,
                BTCINVALID = 5,
                BTCVALID = 6,
                EIDLE = 7;

reg [4:0] state, next_state;

always_ff @ (posedge clk, negedge n_rst) begin
	if (!n_rst)
		state <= IDLE;
	else
		state <= next_state;
end

assign beginSHA = state == SHABEGIN;
assign increment = state == BTCINVALID;
assign btcFound = state == BTCVALID;
assign error = state == EIDLE;

always_comb begin
	next_state = state;
	case (state)
	IDLE: begin
		next_state = newTarget ? NEWTARGET :
		             newMsg    ? SHABEGIN  :
		                         IDLE;
	end
	NEWTARGET: begin
		next_state = IDLE;
	end
	SHABEGIN: begin
		next_state = SHAWAIT;
	end
	SHAWAIT: begin
		next_state = complete ? SHACOMPLETE : SHAWAIT;
	end
	SHACOMPLETE: begin
		next_state = finishedValidating ? BTCINVALID :
                             valid              ? BTCVALID   :
                                                  SHACOMPLETE;
	end
	BTCINVALID: begin
		next_state = overflow ? EIDLE : SHABEGIN;
	end
	BTCVALID: begin
		next_state = IDLE;
	end
	EIDLE: begin
		next_state = newTarget ? NEWTARGET :
		             newMsg    ? SHABEGIN  :
		                         EIDLE;
	end
	endcase
end

endmodule
