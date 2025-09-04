//3-Tap FIR filter
module pipelined_fir
#(parameter WIDTH = 8)
(
    input clk,
    input rst,
    input [WIDTH-1:0] din,
    output reg[WIDTH*2+1:0] dout
);

parameter C0 = 2'd2;
parameter C1 = 2'd3;
parameter C2 = 2'd1;

reg [WIDTH-1:0] Xn, Xn_1, Xn_2;

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        Xn <= 0;
        Xn_1 <= 0;
        Xn_2 <= 0;
    end else begin
        Xn <= din;
        Xn_1 <= Xn;
        Xn_2 <= Xn_1;
    end
end

reg [WIDTH*2-1:0]mul0_reg, mul1_reg, mul2_reg;

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        mul0_reg <= 0;
        mul1_reg <= 0;
        mul2_reg <= 0;
    end else begin
        mul0_reg <= C0 * Xn;
        mul1_reg <= C1 * Xn_1;
        mul2_reg <= C2 * Xn_2;
    end
end

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        dout <= 0;
    end else begin
        dout <= mul0_reg + mul1_reg + mul2_reg;
    end
end

endmodule