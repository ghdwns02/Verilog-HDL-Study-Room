/*
 * RISC-V (RV32I) 명령어 디코더
 */
module instruction_decoder(
    input [31:0] instr,

    // 제어 신호 출력
    output reg [3:0] alu_op,
    output reg       alu_src_a,
    output reg       alu_src_b,
    output reg       mem_write_en,
    output reg       mem_to_reg,
    output reg       reg_write_en,
    output reg       branch_en,
    output reg       jump_en
);

    // =================================================================
    // 1. 필드 분리 및 파라미터 정의
    // =================================================================

    // 명령어 필드 분리
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

    // 가독성을 위한 Opcode 파라미터 정의
    localparam OP_R_TYPE = 7'b0110011; // ADD, SUB, AND
    localparam OP_I_TYPE = 7'b0010011; // ADDI
    localparam OP_LOAD   = 7'b0000011; // LW
    localparam OP_STORE  = 7'b0100011; // SW
    localparam OP_BRANCH = 7'b1100011; // BEQ

    // ALU 연산 코드 정의
    localparam ALU_ADD = 4'b0000;
    localparam ALU_SUB = 4'b0001;
    localparam ALU_AND = 4'b0010;

    // =================================================================
    // 2. 주 제어 유닛 (Main Control Unit)
    // - Opcode를 기반으로 주요 제어 신호를 생성
    // =================================================================
    always @(*) begin
        // 기본값 설정 (Latch 방지)
        alu_src_a    = 1'b0; // 0: rs1, 1: PC
        alu_src_b    = 1'b0; // 0: rs2, 1: Immediate
        mem_write_en = 1'b0;
        mem_to_reg   = 1'b0; // 0: ALU result, 1: Memory data
        reg_write_en = 1'b0;
        branch_en    = 1'b0;
        jump_en      = 1'b0;

        case (opcode)
            OP_R_TYPE: begin
                // 예: ADD, SUB, AND
                alu_src_b    = 1'b0; // ALU 입력 B는 rs2 값
                reg_write_en = 1'b1; // 연산 결과를 레지스터에 쓴다
            end
            OP_I_TYPE: begin
                // 예: ADDI
                alu_src_b    = 1'b1; // ALU 입력 B는 즉시값
                reg_write_en = 1'b1; // 연산 결과를 레지스터에 쓴다
            end
            OP_LOAD: begin
                // 예: LW
                alu_src_b    = 1'b1; // 주소 계산을 위해 ALU 입력 B는 즉시값
                mem_to_reg   = 1'b1; // 메모리에서 읽은 값을 레지스터에 쓴다
                reg_write_en = 1'b1; // 레지스터 쓰기 활성화
            end
            OP_STORE: begin
                // 예: SW
                alu_src_b    = 1'b1; // 주소 계산을 위해 ALU 입력 B는 즉시값
                mem_write_en = 1'b1; // 메모리 쓰기 활성화
            end
            OP_BRANCH: begin
                // 예: BEQ
                alu_src_b    = 1'b0; // 비교를 위해 ALU 입력 B는 rs2 값
                branch_en    = 1'b1; // 분기 명령어임을 알림
            end
            // JAL, JALR 등 다른 명령어 추가 가능
            default: begin
                // 정의되지 않은 명령어에 대한 기본값 유지
            end
        endcase
    end

    // =================================================================
    // 3. ALU 제어 유닛 (ALU Control Unit)
    // - Opcode, funct3, funct7을 조합하여 ALU 연산을 결정
    // =================================================================
    always @(*) begin
        case (opcode)
            OP_R_TYPE: begin
                // R-Type은 funct3, funct7으로 세부 연산 구분
                if (funct3 == 3'b000) begin
                    if (funct7 == 7'b0000000)
                        alu_op = ALU_ADD; // ADD
                    else if (funct7 == 7'b0100000)
                        alu_op = ALU_SUB; // SUB
                    else
                        alu_op = 4'bxxxx; // 정의되지 않은 연산
                end else if (funct3 == 3'b111) begin
                    alu_op = ALU_AND; // AND
                end else
                    alu_op = 4'bxxxx;
            end
            OP_I_TYPE: begin
                // ADDI는 덧셈 연산
                alu_op = ALU_ADD;
            end
            OP_LOAD: begin
                // LW는 주소 계산을 위해 덧셈(rs1 + offset) 필요
                alu_op = ALU_ADD;
            end
            OP_STORE: begin
                // SW도 주소 계산을 위해 덧셈(rs1 + offset) 필요
                alu_op = ALU_ADD;
            end
            OP_BRANCH: begin
                // BEQ는 두 레지스터 값을 빼서 0인지 확인 (결과가 0이면 Zero 플래그 활성화)
                alu_op = ALU_SUB;
            end
            default: begin
                alu_op = 4'bxxxx; // 정의되지 않은 명령어
            end
        endcase
    end

endmodule
