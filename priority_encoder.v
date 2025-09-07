module priority_encoder #(parameter WIDTH = 8)
(
    input [WIDTH-1:0] Data_in,
    output reg valid,
    output reg [$clog2(WIDTH)-1:0] Data_out
);


integer i;

always @ (*) begin
    valid = 0;
    Data_out = 0;

    for (i = WIDTH-1; i >= 0; i = i - 1) begin
        if (Data_in[i] == 1'b1) begin
            valid = 1'b1;
            Data_out = i;
        end
    end
end

endmodule