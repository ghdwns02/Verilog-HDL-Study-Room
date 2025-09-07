module pulse_counter(
    input clk,
    input rst_n,
    input pulse_in, // 비동기 펄스 입력
    output reg [7:0] count
);

    // 1. 토글 로직: pulse_in을 생성하는 클럭으로 동작해야 하지만,
    // 해당 클럭이 없으므로 여기서는 펄스 자체로 토글을 표현합니다.
    // 실제 설계에서는 pulse_in과 같은 클럭 도메인의 FF를 사용합니다.
    reg pulse_toggle;
    always @(posedge pulse_in or negedge rst_n) begin
        if (!rst_n)
            pulse_toggle <= 1'b0;
        else
            pulse_toggle <= ~pulse_toggle;
    end

    // 2. 2-Flop Synchronizer: 토글 신호를 clk 도메인으로 안전하게 전달
    reg pulse_toggle_sync1, pulse_toggle_sync2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pulse_toggle_sync1 <= 1'b0;
            pulse_toggle_sync2 <= 1'b0;
        end else begin
            pulse_toggle_sync1 <= pulse_toggle;
            pulse_toggle_sync2 <= pulse_toggle_sync1;
        end
    end

    // 3. 엣지 검출기: 동기화된 토글 신호의 변화(엣지)를 감지
    // 이 엣지가 바로 clk 도메인에 동기화된 1-클럭 펄스가 됩니다.
    wire sync_pulse_detected;
    assign sync_pulse_detected = (pulse_toggle_sync1 != pulse_toggle_sync2);

    // 4. 카운터 로직
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 8'd0;
        end else begin
            // 동기화된 펄스가 감지될 때만 카운터 증가
            if (sync_pulse_detected) begin
                count <= count + 1; // Non-blocking 할당 사용
            end
        end
    end

endmodule