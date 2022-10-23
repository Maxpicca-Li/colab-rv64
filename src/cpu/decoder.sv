`include "def_inst.svh"
`include "def_cpu.svh"

module decoder(
    input  inst_t instr,
    output data_t imm, 
    output data_t shamt,
    output decode_sign_t decode_sign
);

regaddr_t   rs2       = instr[`RS2_IDX];
regaddr_t   rs1       = instr[`RS1_IDX];
regaddr_t   rd        = instr[`RD_IDX];
op_t        opcode    = instr[`OP_IDX];
funct3_t    funct3    = instr[`FUNCT3_IDX];
funct7_t    funct7    = instr[`FUNCT7_IDX];
funct6_t    funct6    = instr[`FUNCT6_IDX];

data_t imm_u = {{32{instr[31]}},instr[31:12],12'd0};
data_t imm_i = {{52{instr[31]}},instr[31:20]};
data_t imm_s = {{52{instr[31]}},instr[31:25],instr[11:7]};
data_t imm_b = {{51{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};
data_t imm_j = {{43{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21],1'b0};
data_t imm_sha5 = {59'd0,instr[24:20]};
data_t imm_sha6 = {58'd0,instr[25:20]};
data_t shamt6 = {32'd0, 26'd0, instr[`SHAMT6_IDX]};
data_t shamt5 = {32'd0, 27'd0, instr[`SHAMT5_IDX]};

always_comb begin
    decode_sign = `DECODE_NOP;
    imm = 0;
    shamt = 0;
    unique casez (opcode)
        `OPCODE_LUI: begin
            decode_sign.alu_op = ALU_LUI;
            decode_sign.alu_imm = 1;
            decode_sign.rd_en = |rd;
            imm = imm_u;
        end
        `OPCODE_AUIPC: begin
            decode_sign.alu_op = ALU_ADD;
            decode_sign.alu_pc = 1;
            decode_sign.alu_imm = 1;
            decode_sign.rd_en = |rd;
            imm = imm_u;
        end
        `OPCODE_JAL: begin
            decode_sign.alu_op = ALU_JAL;
            decode_sign.alu_pc = 1;
            decode_sign.rd_en = |rd;
            decode_sign.j = 1;
            imm = imm_j;
        end
        `OPCODE_JALR: begin
            decode_sign.alu_op = ALU_JAL;
            decode_sign.alu_pc = 1;
            decode_sign.rs1_en = 1;
            decode_sign.rd_en = |rd;
            decode_sign.jr = 1;
            imm = imm_i;
        end
        `OPCODE_BRANCH: begin
            decode_sign.rs1_en = 1;
            decode_sign.rs2_en = 1;
            decode_sign.b = 1;
            imm = imm_b;
        end
        `OPCODE_LOAD: begin
            imm = imm_i;
            unique casez(funct3)
                `FUNCT3_LB, `FUNCT3_LBU, `FUNCT3_LH, `FUNCT3_LHU, `FUNCT3_LW, `FUNCT3_LWU, `FUNCT3_LD: begin
                    decode_sign.mem_read = 1;
                    decode_sign.rs1_en = 1;
                    decode_sign.rd_en = |rd;
                end
                default: decode_sign.reversed = 1;
            endcase
        end
        `OPCODE_OPIMM: begin
            imm = imm_i;
            shamt = shamt6;
            unique casez(funct3)
                `FUNCT3_ADD_SUB: begin
                    decode_sign.alu_op = ALU_ADD;
                    decode_sign.alu_imm = 1;
                    decode_sign.rs1_en = 1;
                    decode_sign.rd_en = |rd;
                end
                `FUNCT3_SLT: begin
                    decode_sign.alu_op = ALU_SLT;
                    decode_sign.alu_imm = 1;
                    decode_sign.rs1_en = 1;
                    decode_sign.rd_en = |rd;
                end
                `FUNCT3_SLTU: begin
                    decode_sign.alu_op = ALU_SLTU;
                    decode_sign.alu_imm = 1;
                    decode_sign.rs1_en = 1;
                    decode_sign.rd_en = |rd;
                end
                `FUNCT3_XOR: begin
                    decode_sign.alu_op = ALU_XOR;
                    decode_sign.alu_imm = 1;
                    decode_sign.rs1_en = 1;
                    decode_sign.rd_en = |rd;
                end
                `FUNCT3_OR: begin
                    decode_sign.alu_op = ALU_OR;
                    decode_sign.alu_imm = 1;
                    decode_sign.rs1_en = 1;
                    decode_sign.rd_en = |rd;
                end
                `FUNCT3_AND: begin
                    decode_sign.alu_op = ALU_AND;
                    decode_sign.alu_imm = 1;
                    decode_sign.rs1_en = 1;
                    decode_sign.rd_en = |rd;
                end
                `FUNCT3_SLL: begin
                    decode_sign.alu_op = ALU_SLL;
                    decode_sign.alu_shamt = 1;
                    decode_sign.rs1_en = 1;
                    decode_sign.rd_en = |rd;
                end
                `FUNCT3_SRL_SRA: begin
                    decode_sign.alu_op = instr[30] ? ALU_SRA : ALU_SRL;
                    decode_sign.alu_shamt = 1;
                    decode_sign.rs1_en = 1;
                    decode_sign.rd_en = |rd;
                end
                default: decode_sign.reversed = 1;
            endcase
        end
        `OPCODE_OPIMM32: begin
            imm = imm_i;
            shamt = shamt5;
            decode_sign.alu_32 = 1;
            unique casez(funct3)
                `FUNCT3_ADD_SUB: begin
                    decode_sign.alu_op = ALU_ADD;
                    decode_sign.alu_imm = 1;
                    decode_sign.rs1_en = 1;
                    decode_sign.rd_en = |rd;
                end
                `FUNCT3_SLL: begin
                    decode_sign.alu_op = ALU_SLL;
                    decode_sign.alu_shamt = 1;
                    decode_sign.rs1_en = 1;
                    decode_sign.rd_en = |rd;
                end
                `FUNCT3_SRL_SRA: begin
                    decode_sign.alu_op = instr[30] ? ALU_SRA : ALU_SRL;
                    decode_sign.alu_shamt = 1;
                    decode_sign.rs1_en = 1;
                    decode_sign.rd_en = |rd;
                end
                default: decode_sign.reversed = 1;
            endcase
        end
        `OPCODE_OP: begin
            unique casez(funct3)
                `FUNCT3_ADD_SUB: begin
                    decode_sign.alu_op = instr[30] ? ALU_SUB : ALU_ADD;
                    decode_sign.rs1_en = 1;
                    decode_sign.rs2_en = 1;
                    decode_sign.rd_en = |rd;
                end
                `FUNCT3_SLT: begin
                    decode_sign.alu_op = ALU_SLT;
                    decode_sign.rs2_en = 1;
                    decode_sign.rs1_en = 1;
                    decode_sign.rd_en = |rd;
                end
                `FUNCT3_SLTU: begin
                    decode_sign.alu_op = ALU_SLTU;
                    decode_sign.rs2_en = 1;
                    decode_sign.rs1_en = 1;
                    decode_sign.rd_en = |rd;
                end
                `FUNCT3_XOR: begin
                    decode_sign.alu_op = ALU_XOR;
                    decode_sign.rs2_en = 1;
                    decode_sign.rs1_en = 1;
                    decode_sign.rd_en = |rd;
                end
                `FUNCT3_OR: begin
                    decode_sign.alu_op = ALU_OR;
                    decode_sign.rs2_en = 1;
                    decode_sign.rs1_en = 1;
                    decode_sign.rd_en = |rd;
                end
                `FUNCT3_AND: begin
                    decode_sign.alu_op = ALU_AND;
                    decode_sign.rs2_en = 1;
                    decode_sign.rs1_en = 1;
                    decode_sign.rd_en = |rd;
                end
                `FUNCT3_SLL: begin
                    decode_sign.alu_op = ALU_SLL;
                    decode_sign.rs2_en = 1;
                    decode_sign.rs1_en = 1;
                    decode_sign.rd_en = |rd;
                end
                `FUNCT3_SRL_SRA: begin
                    decode_sign.alu_op = instr[30] ? ALU_SRA : ALU_SRL;
                    decode_sign.rs2_en = 1;
                    decode_sign.rs1_en = 1;
                    decode_sign.rd_en = |rd;
                end
                default: decode_sign.reversed = 1;
            endcase
        end
        `OPCODE_OP32: begin
            decode_sign.alu_32 = 1;
            unique casez(funct3)
                `FUNCT3_ADD_SUB: begin
                    decode_sign.alu_op = instr[30] ? ALU_SUB : ALU_ADD;
                    decode_sign.rs1_en = 1;
                    decode_sign.rs2_en = 1;
                    decode_sign.rd_en = |rd;
                end
                `FUNCT3_SLL: begin
                    decode_sign.alu_op = ALU_SLL;
                    decode_sign.rs2_en = 1;
                    decode_sign.rs1_en = 1;
                    decode_sign.rd_en = |rd;
                end
                `FUNCT3_SRL_SRA: begin
                    decode_sign.alu_op = instr[30] ? ALU_SRA : ALU_SRL;
                    decode_sign.rs2_en = 1;
                    decode_sign.rs1_en = 1;
                    decode_sign.rd_en = |rd;
                end
                default: decode_sign.reversed = 1;
            endcase
        end
        `OPCODE_FENCE: begin
            decode_sign = `DECODE_NOP;
        end
        `OPCODE_SYSTEM: begin
            decode_sign.reversed = (instr != 32'b00000000000000000000000001110011 &&  // ECALL
                                    instr != 32'b00000000000100000000000001110011);   // EBREAK
        end
        default: decode_sign.reversed = 1;
    endcase
end

endmodule