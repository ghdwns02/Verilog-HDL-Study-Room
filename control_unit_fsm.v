module control_unit_fsm(
    input clk,
    input rst,
    output reg if_en,
    output reg id_en,
    output reg ex_en
);

reg [1:0] state, next_state;

parameter S_IDLE = 2'd0;
parameter S_IF = 2'd1;
parameter S_IF_ID = 2'd2;
parameter S_FULL = 2'd3;

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        state <= S_IDLE;
    end else begin
        state <= next_state;
    end
end

always @ (*) begin
    case (state)
        S_IDLE : next_state = S_IF;
        S_IF : next_state = S_IF_ID;
        S_IF_ID : next_state = S_FULL;
        S_FULL : next_state = S_FULL;
        default: next_state = S_IDLE;
    endcase
end

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        if_en <= 0;
        id_en <= 0;
        ex_en <= 0;
    end else begin
        if (state == S_IDLE) begin
            if_en <= 1;
            id_en <= 0;
            ex_en <= 0;
        end
        else if (state == S_IF) begin
            if_en <= 1;
            id_en <= 1;
            ex_en <= 0;
        end
        else if (state == S_IF_ID) begin
            if_en <= 1;
            id_en <= 1;
            ex_en <= 1;
        end
        else if (state == S_FULL) begin
            if_en <= 1;
            id_en <= 1;
            ex_en <= 1;
        end
        else begin
            if_en <= if_en;
            id_en <= id_en;
            ex_en <= ex_en;
        end
    end
end

endmodule