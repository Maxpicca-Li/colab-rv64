`include "def_cpu.svh"

module alu(
    input           clk,
    input           rst,
    input           except,
    input  data_t   a_i,
    input  data_t   b_i,
    input  logic    word32,
    input  logic    get_hi,
    input  logic    sign1,
    input  logic    sign2,
    input  aluop_t  aluop,
    output logic    alu_stall,
    output data_t   res_o
);

logic mul_ready, mul_start;
logic div_ready, div_start;

data_t a,b,res;
assign a = word32 ? {32'd0,a_i[31:0]} : a; // only lower 32 bits
assign b = word32 ? {32'd0,b_i[31:0]} : b;
assign res_o = word32 ? {{32{res[31]}},res[31:0]} : res; // sign-extension of lower 32 bits
assign alu_stall = (aluop==ALU_MUL && !mul_ready) | (aluop==ALU_DIV && !div_ready);

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
        ALU_MUL: begin
            if(!mul_ready) mul_start = 1;
            else mul_start = 0;
        end
        ALU_DIV: begin
            if(!div_ready) div_start = 1;
            else div_start = 0;
        end
        default: res = 0;
    endcase
end

// TODO: fuse mul/div
mul u_mul(
    .clk(clk),
    .rst(rst),
    .a(a),
    .b(b),
    .sign1(sign1),
    .sign2(sign2),
    .get_hi(get_hi),
    .start(mul_start),
    
    .ready(mul_ready),
    .result_o(res)
);

div u_div(
    .clk(clk),
    .rst(rst),
    .interrupt(except),
    .start(div_start),
    .sign1(sign1),
    .sign2(sign2),
    .get_hi(get_hi),
    .a(a),
    .b(b),

    .ready(div_ready),
    .result_o(res)
);

endmodule