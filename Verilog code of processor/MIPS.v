module MIPS(
    input clk1,
    input clk2
);
parameter 
ADD = 6'b000000,
SUB = 6'b000001,
AND = 6'b000010,
OR = 6'b000011,
SLT = 6'b000100,
MUL = 6'b000101,
HLT = 6'b111111,

LW = 6'b001000,
SW = 6'b001001,
ADDI = 6'b001010,
SUBI = 6'b001011,
SLTI = 6'b001100,
BNEQZ = 6'b001101,
BEQZ = 6'b001110;

parameter
    RR_ALU = 3'B000,
    RM_ALU = 3'B001,
    LOAD = 3'B010,
    STORE = 3'B011,
    BRANCH = 3'B100,
    HALT = 3'B101;

reg TAKEN_BRANCH, HALTED;

reg [31:0] reg_bank [0:31];
reg [31:0] mem [0:1023];

reg EX_MEM_COND;
reg [2:0] ID_EX_TYPE, EX_MEM_TYPE, MEM_WB_TYPE;
reg [31:0] PC, IF_ID_NPC, IF_ID_IR;
reg [31:0] ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_IMM, ID_EX_IR;
reg [31:0] EX_MEM_ALUOUT, EX_MEM_B, EX_MEM_IR;
reg [31:0] MEM_WB_LMD, MEM_WB_ALUOUT, MEM_WB_IR;

// ** Instruction Fetch unit ** // 
always @(posedge clk1) begin
    if(HALTED == 0)
    begin
    if(((EX_MEM_IR[31:26] == BEQZ) && (EX_MEM_COND == 1)) ||
        ((EX_MEM_IR[31:26] == BNEQZ) && (EX_MEM_COND == 0)))
    begin
        IF_ID_IR <= #2 mem[EX_MEM_ALUOUT];
        TAKEN_BRANCH <= #2 1;
        IF_ID_NPC <= #2 EX_MEM_ALUOUT + 1;
        PC <= #2 EX_MEM_ALUOUT + 1;
    end
    else
    begin
        IF_ID_IR <= #2 mem[PC];
        IF_ID_NPC <= #2 PC +1;
        PC <= #2 PC +1;
    end
    end
end

// ** Instruction Decode unit ** //
always @(posedge clk2) begin
    if(HALTED == 0)
    begin
    ID_EX_NPC <= #2 IF_ID_NPC;
    ID_EX_A <= #2 reg_bank[IF_ID_IR[25:21]];
    ID_EX_B <= #2 reg_bank[IF_ID_IR[20:16]];
    ID_EX_IMM <= #2 {{16{IF_ID_IR[15]}}, {IF_ID_IR[15:0]}};
    ID_EX_IR <= #2 IF_ID_IR;
    case (IF_ID_IR[31:26])
        ADD, SUB, AND, OR, SLT, MUL: ID_EX_TYPE <= #2 RR_ALU;
        ADDI, SUBI, SLTI: ID_EX_TYPE <= #2 RM_ALU;
        LW: ID_EX_TYPE <= #2 LOAD;
        SW: ID_EX_TYPE <= #2 STORE;
        BNEQZ, BEQZ: ID_EX_TYPE <= #2 BRANCH;
        HLT: ID_EX_TYPE <= #2 HALT;
        default: ID_EX_TYPE <= HALT;
    endcase
    end
end

// ** Execute unit ** //
always @(posedge clk1) begin
    if(HALTED == 0)
    begin
    EX_MEM_TYPE <= #2 ID_EX_TYPE;
    EX_MEM_IR <= #2 ID_EX_IR;
    TAKEN_BRANCH <= #2 0;
    case (ID_EX_TYPE)
        RR_ALU : begin
            case (ID_EX_IR[31:26])
                ADD : EX_MEM_ALUOUT <= #2 ID_EX_A + ID_EX_B;
                SUB : EX_MEM_ALUOUT <= #2 ID_EX_A - ID_EX_B;
                MUL : EX_MEM_ALUOUT <= #2 ID_EX_A * ID_EX_B;
                AND : EX_MEM_ALUOUT <= #2 ID_EX_A & ID_EX_B;
                OR  : EX_MEM_ALUOUT <= #2 ID_EX_A | ID_EX_B;
                SLT : EX_MEM_ALUOUT <= #2 ID_EX_A < ID_EX_B;
                default: EX_MEM_ALUOUT <= #2 32'HX;
            endcase
        end
        RM_ALU: begin
            case (ID_EX_IR[31:26])
                ADDI: EX_MEM_ALUOUT <= #2 ID_EX_A + ID_EX_IMM;
                SUBI: EX_MEM_ALUOUT <= #2 ID_EX_A - ID_EX_IMM;
                SLTI: EX_MEM_ALUOUT <= #2 ID_EX_A < ID_EX_IMM;
                default: EX_MEM_ALUOUT <= #2 32'hx;
            endcase
        end
        LOAD, STORE :begin
            EX_MEM_ALUOUT <= #2 ID_EX_A +ID_EX_IMM;
            EX_MEM_B <= #2 ID_EX_B;
        end
        BRANCH: begin
            EX_MEM_ALUOUT <= #2 ID_EX_NPC + ID_EX_IMM;
            EX_MEM_COND <= #2 (ID_EX_A == 0);
        end
    endcase
    end
end

// ** Memory unit ** //
always @(posedge clk2) begin
    if (HALTED == 0)
    begin
    MEM_WB_TYPE <= #2 EX_MEM_TYPE;
    MEM_WB_IR <= #2 EX_MEM_IR;

    case (EX_MEM_TYPE)
        RR_ALU, RM_ALU: MEM_WB_ALUOUT <= #2 EX_MEM_ALUOUT;
        LOAD: MEM_WB_LMD <= #2 mem[EX_MEM_ALUOUT];
        STORE:if (TAKEN_BRANCH == 0) mem[EX_MEM_ALUOUT] <= #2 EX_MEM_B;
    endcase
    end
end

// ** Register Writeback ** //
always @(posedge clk1) begin
    if(TAKEN_BRANCH == 0) begin
        case (MEM_WB_TYPE)
            RR_ALU: reg_bank[MEM_WB_IR[15:11]] <= #2 MEM_WB_ALUOUT;
            RM_ALU: reg_bank[MEM_WB_IR[20:16]] <= #2 MEM_WB_ALUOUT;
            LOAD:   reg_bank[MEM_WB_IR[20:16]] <= #2 MEM_WB_LMD;
            HALT:   HALTED <= #2 1'B1;
        endcase
    end
end
endmodule