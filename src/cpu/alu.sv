`include "def_cpu.svh"

module alu(
    input  data_t   a_i,
    input  data_t   b_i,
    input  logic    word32,
    input  aluop_t  aluop,
    output data_t   res_o
);

data_t a,b,res;
assign a = word32 ? {{32{a_i[31]}},a_i[31:0]} : a;
assign b = word32 ? {{32{b_i[31]}},b_i[31:0]} : b;
assign res_o = res;

always_comb begin
    unique casez(aluop)
        ALU_LUI: res = b; // imm
        ALU_JAL: res = a + 4; // pc + 4
        ALU_ADD: res = a + b;
        ALU_SUB: res = $signed(a) - $signed(b);
        ALU_SRL: res = a >> b[5:0];
        ALU_SRA: res = $signed(a) >>> b[5:0];
        ALU_SLT: res = {63'd0, $signed(a) < $signed(b)};
        ALU_SLTU: res = {63'd0, a < b};
        ALU_XOR: res = a ^ b;
        ALU_OR: res = a | b;
        ALU_AND: res = a & b;
        ALU_SLL: res = a << b[5:0];
        default: res = 0;
    endcase
end

endmodule