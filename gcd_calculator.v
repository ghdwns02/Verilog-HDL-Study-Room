/*
 * 문제: 최대공약수(GCD) 계산기 설계
 * 난이도: 어려움
 *
 * 문제 설명
 * 두 개의 8비트 양의 정수를 입력받아, 두 수의 **최대공약수(Greatest Common Divisor, GCD)**를 계산하는 하드웨어 모듈을 설계하세요. 계산에는 **유클리드 호제법(Euclidean Algorithm)**을 사용해야 합니다.
 *
 * 이 문제는 순차적인 계산 과정을 상태 머신(State Machine)으로 어떻게 구현하는지에 대한 이해를 요구합니다.
 */

module gcd_calculator(
    input clk,
    input rst_n,
    input start,
    input [7:0] a_in,
    input [7:0] b_in,
    output done,
    output reg [7:0] gcd_out
);

reg [1:0] state, next_state;
reg [7:0] a_reg, b_reg;

parameter IDLE = 2'b00;
parameter CALCULATE = 2'b01;
parameter DONE = 2'b10;

always @ (posedge clk or posedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

always @ (*) begin
    case (state) 
        IDLE : next_state = (start) ? CALCULATE : IDLE;
        CALCULATE : next_state = (!b_reg) ? DONE : CALCULATE;
        DONE : next_state = IDLE;
        default : next_state = IDLE;
    endcase
end

always @ (posedge clk or posedge rst_n) begin
    if (!rst_n) begin
        a_reg <= 8'd0;
        b_reg <= 8'd0;
        gcd_out <= 8'd0;
    end else begin
        if (state == IDLE) begin
            if (start) begin
                a_reg <= (a_in > b_in) ? a_in : b_in;
                b_reg <= (a_in > b_in) ? b_in : a_in;
            end else begin
                a_reg <= a_reg;
                b_reg <= b_reg;
            end
        end
        else if (CALCULATE) begin
            if (b_reg) begin
                a_reg <= b_reg;
                b_reg <= a_reg % b_reg;
            end
        end
        else if (DONE) begin
            gcd_out <= a_reg;
        end
    end
end

assign done = (state == DONE) ? 1'b1 : 1'b0;

endmodule