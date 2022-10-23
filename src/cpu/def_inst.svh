`ifndef DEF_INST
`define DEF_INST

`define OP_IDX          6 :0
`define RD_IDX          11 :7
`define FUNCT3_IDX      14:12
`define RS1_IDX         19:15
`define RS2_IDX         24:20
`define FUNCT7_IDX      31:25
`define FUNCT6_IDX      31:26  // RV64 shift
`define SHAMT5_IDX      24:20
`define SHAMT6_IDX      25:20
`define FUNCT5_IDX      31:27  // A Standard Extension
`define CSR_IDX         31:20  // Zicsr Standard Extension

// RV64I {
`define OPCODE_LUI      7'b0110111
`define OPCODE_AUIPC    7'b0010111
`define OPCODE_JAL      7'b1101111
`define OPCODE_JALR     7'b1100111
`define OPCODE_BRANCH   7'b1100011 // All branch
    // Branch Funct3 {
    `define FUNCT3_BEQ      3'b000
    `define FUNCT3_BNE      3'b001
    `define FUNCT3_BLT      3'b100
    `define FUNCT3_BGE      3'b101
    `define FUNCT3_BLTU     3'b110
    `define FUNCT3_BGEU     3'b111
    // Branch Funct3 }
`define OPCODE_LOAD     7'b0000011
    // Load Funct3 {
    `define FUNCT3_LB   3'b000
    `define FUNCT3_LBU  3'b100
    `define FUNCT3_LH   3'b001
    `define FUNCT3_LHU  3'b101
    `define FUNCT3_LW   3'b010
    `define FUNCT3_LWU  3'b110 // RV64I
    `define FUNCT3_LD   3'b011 // RV64I
    // Load Funct3 }
`define OPCODE_STORE    7'b0100011
    // Store Funct3 {
    `define FUNCT3_SB   3'b000
    `define FUNCT3_SH   3'b001
    `define FUNCT3_SW   3'b010
    `define FUNCT3_SD   3'b011 // RV64I
    // Store Funct3 }
`define OPCODE_OPIMM    7'b0010011 // Interger Computational-Immdiate
`define OPCODE_OP       7'b0110011 // Interger Computational-Regist
`define OPCODE_OPIMM32  7'b0011011 // RV64I: ADDIW,SLLIW,SRLIW,SRAIW
`define OPCODE_OP32     7'b0111011 // RV64I: ADDW,SUBW,SLLW,SRLW,SRAW
    `define FUNCT7_MULDIV   7'b0000001
        `define FUNCT3_MUL      3'b000
        `define FUNCT3_MULH     3'b001
        `define FUNCT3_MULHSU   3'b010
        `define FUNCT3_MULHU    3'b011
        `define FUNCT3_DIV      3'b100
        `define FUNCT3_DIVU     3'b101
        `define FUNCT3_REM      3'b110
        `define FUNCT3_REMU     3'b111
    // ALU_Funct3 {
    `define FUNCT3_ADD_SUB  3'b000
    `define FUNCT3_SLL      3'b001
    `define FUNCT3_SLT      3'b010
    `define FUNCT3_SLTU     3'b011
    `define FUNCT3_XOR      3'b100
    `define FUNCT3_SRL_SRA  3'b101
    `define FUNCT3_OR       3'b110
    `define FUNCT3_AND      3'b111
    // ALU_funct3 }
        `define FUNCT7_NORMAL   7'd0
        `define FUNCT7_SUB      7'b0100000
        `define FUNCT7_SRA      7'b0100000
        `define FUNCT6_NORMAL   6'd0
        `define FUNCT6_SRA      6'b010000
`define OPCODE_FENCE        7'b0001111
`define OPCODE_SYSTEM       7'b1110011
// RV64I }

`endif