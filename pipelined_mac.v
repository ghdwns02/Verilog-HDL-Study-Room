module pipelined_mac
#(parameter WIDTH = 8)
(
    input clk,
    input rst,
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    output reg [WIDTH*2:0] result
);

reg [WIDTH*2-1:0] mul_result_stage1; 

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        mul_result_stage1 <= 0;
    end else begin
        mul_result_stage1 <= A * B;
    end
end

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        result <= 0;
    end else begin
        result <= result + mul_result_stage1;
    end
end

endmodule