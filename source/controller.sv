module controller
(
	input wire clk,
	input wire n_rst,
	input wire newTarget,
	input wire newMsg,
	input wire complete,
	input wire valid,
	input wire overflow,
	output wire loadTarget,
	output wire loadMsg,
	output wire reset,
	output wire beginSHA,
	output wire increment,
	output wire error
);

parameter [4:0] IDLE = 0,
                NEWTARGET = 1,
                NEWMSG = 2,
                SHABEGIN = 3,
                SHAWAIT = 4,
                SHACOMPLETE = 5,
                BTCVALID = 6,
                BTCINVALID = 7,
                EIDLE = 8;

reg [4:0] state, next_state;

always_ff @ (posedge clk, negedge n_rst) begin
	if (!n_rst)
		state <= IDLE;
	else
		state <= next_state;
end

assign loadTarget = state == NEWTARGET;
assign loadMsg = state == NEWMSG;
assign reset = state == NEWMSG;
assign beginSHA = state == SHABEGIN;
assign increment = state == BTCINVALID;
assign error = state == EIDLE;

always_comb begin
	next_state = state;
	case (state)
	IDLE: begin
		next_state = newTarget ? NEWTARGET :
		             newMsg    ? NEWMSG    :
		                         IDLE;
	end
	NEWTARGET: begin
		next_state = IDLE;
	end
	NEWMSG: begin
		next_state = SHABEGIN;
	end
	SHABEGIN: begin
		next_state = SHAWAIT;
	end
	SHAWAIT: begin
		next_state = complete ? SHACOMPLETE : SHAWAIT;
	end
	SHACOMPLETE: begin
		next_state = valid ? BTCVALID : BTCINVALID;
	end
	BTCVALID: begin
		next_state = IDLE;
	end
	BTCINVALID: begin
		next_state = overflow ? EIDLE : SHABEGIN;
	end
	EIDLE: begin
		next_state = newTarget ? NEWTARGET :
		             newMsg    ? NEWMSG    :
		                         EIDLE;
	end
	endcase
end

endmodule
