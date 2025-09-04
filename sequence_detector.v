// Moore FSM
module sequence_detector(
    input clk,
    input rst,
    input din,
    output detected
);

parameter IDLE = 3'd0;
parameter S1 = 3'd1;
parameter S11 = 3'd2;
parameter S110 = 3'd3;
parameter DETECT = 3'd4;

reg [2:0] state, next_state;

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

always @ (*) begin
    case (state)
        IDLE : next_state = (din) ? S1 : IDLE;
        S1   : next_state = (din) ? S11 : IDLE;
        S11  : next_state = (din) ? S11 : S110;
        S110 : next_state = (din) ? DETECT : IDLE;
        DETECT : next_state = (din) ? S1 : IDLE;
        default: next_state = IDLE;
    endcase
end

assign detected = (state == DETECT);

endmodule