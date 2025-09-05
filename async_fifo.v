module async_fifo
#(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)
(
    // Write Domain
    input wclk,
    input wrst_n,
    input winc,
    input [DATA_WIDTH-1:0] wdata,
    output wfull,

    // Read Domain
    input rclk,
    input rrst_n,
    input rinc,
    output reg [DATA_WIDTH-1:0] rdata,
    output rempty
);

    localparam FIFO_DEPTH = 1 << ADDR_WIDTH;

    // 1. 메모리 선언
    reg [DATA_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

    // 2. 포인터 선언 (바이너리 & 그레이 코드)
    // MSB를 추가하여 Full/Empty 상태 구분 (총 ADDR_WIDTH+1 비트)
    reg  [ADDR_WIDTH:0] wptr_bin, rptr_bin; // 바이너리 포인터
    reg  [ADDR_WIDTH:0] wptr_gray, rptr_gray; // 그레이 코드 포인터
    wire [ADDR_WIDTH:0] wptr_next_bin, rptr_next_bin;
    wire [ADDR_WIDTH:0] wptr_next_gray, rptr_next_gray;

    // 포인터 동기화를 위한 레지스터
    reg [ADDR_WIDTH:0] rptr_gray_sync1, rptr_gray_sync2;
    reg [ADDR_WIDTH:0] wptr_gray_sync1, wptr_gray_sync2;


    // =================================================================
    // Write Domain Logic (wclk)
    // =================================================================
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wptr_bin  <= 0;
            wptr_gray <= 0;
        end else begin
            if (winc && !wfull) begin
                wptr_bin  <= wptr_next_bin;
                wptr_gray <= wptr_next_gray;
            end
        end
    end
    
    // 메모리 쓰기 로직
    always @(posedge wclk) begin
        if (winc && !wfull) begin
            mem[wptr_bin[ADDR_WIDTH-1:0]] <= wdata;
        end
    end

    // 다음 쓰기 포인터 계산
    assign wptr_next_bin = wptr_bin + 1;
    // 바이너리를 그레이 코드로 변환
    assign wptr_next_gray = (wptr_next_bin >> 1) ^ wptr_next_bin;

    // Full 조건 판단: 쓰기 포인터의 다음 값이 동기화된 읽기 포인터와 일치하는가?
    // 그레이 코드 Full 조건: MSB와 next MSB는 다르고 나머지 비트는 같아야 함
    assign wfull = (wptr_next_gray[ADDR_WIDTH:ADDR_WIDTH-1] == ~rptr_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1]) &&
                   (wptr_next_gray[ADDR_WIDTH-2:0] == rptr_gray_sync2[ADDR_WIDTH-2:0]);

    // rptr을 wclk 도메인으로 동기화 (2-Flop Synchronizer)
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            rptr_gray_sync1 <= 0;
            rptr_gray_sync2 <= 0;
        end else begin
            rptr_gray_sync1 <= rptr_gray;
            rptr_gray_sync2 <= rptr_gray_sync1;
        end
    end


    // =================================================================
    // Read Domain Logic (rclk)
    // =================================================================
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rptr_bin  <= 0;
            rptr_gray <= 0;
            rdata     <= 0;
        end else begin
            if (rinc && !rempty) begin
                rptr_bin  <= rptr_next_bin;
                rptr_gray <= rptr_next_gray;
            end
            // 데이터 읽기는 포인터가 업데이트 되기 전 값으로 수행
            rdata <= mem[rptr_bin[ADDR_WIDTH-1:0]]; 
        end
    end

    // 다음 읽기 포인터 계산
    assign rptr_next_bin = rptr_bin + 1;
    assign rptr_next_gray = (rptr_next_bin >> 1) ^ rptr_next_bin;

    // Empty 조건 판단: 현재 읽기 포인터가 동기화된 쓰기 포인터와 같은가?
    assign rempty = (rptr_gray == wptr_gray_sync2);

    // wptr을 rclk 도메인으로 동기화 (2-Flop Synchronizer)
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            wptr_gray_sync1 <= 0;
            wptr_gray_sync2 <= 0;
        end else begin
            wptr_gray_sync1 <= wptr_gray;
            wptr_gray_sync2 <= wptr_gray_sync1;
        end
    end

endmodule