`include "def_cpu.svh"
`include "def_inst.svh"

module pipe_ex(
    input  pipe_entry_t [1:0]   ex_pipe,
    input  decode_sign_t [1:0]  ex_decode_sign,
    input  id2ex_t [1:0]        ex_get,
    
    output mempack_t            ex_mempack,
    output regpack_t [1:0]      ex_put
);

for(genvar i=0;i<`ISSUE_NUM;++i) begin
    always_comb begin
        ex_put[i].rd_en = ex_decode_sign[i].rd_en;
        ex_put[i].rd    = ex_pipe[i].instr[`RD_IDX];
    end
end


// ALU
data_t[1:0] alu_a, alu_b;
for(genvar i=0;i<`ISSUE_NUM;++i) begin
    mux #(
        .WIDTH         ($bits(alu_a[i]) ),
        .CNT           (2             ) )
    u_mux_a(
        .signs('{ex_decode_sign[i].rs1_en, ex_decode_sign[i].alu_pc}),
        .datas('{ex_get[i].rs_data1, ex_pipe[i].pc}),
        .default_data(0),
        .sel_data(alu_a[i])
    );

    mux #(
        .WIDTH         ($bits(alu_b[i]) ),
        .CNT           (2             ) )
    u_mux_b(
        .signs('{ex_decode_sign[i].rs2_en, ex_decode_sign[i].alu_shamt, ex_decode_sign[i].alu_imm}),
        .datas('{ex_get[i].rs_data2, ex_get[i].shamt, ex_get[i].imm}),
        .default_data(0),
        .sel_data(alu_b[i])
    );

    alu u_alu(
        .a_i(alu_a[i]),
        .b_i(alu_b[i]),
        .word32(ex_decode_sign[i].alu_32),
        .aluop(ex_decode_sign[i].alu_op),
        .res_o(ex_put[i].res)
    );
end

// MEM
always_comb begin
    ex_mempack = '0;
    for(integer i=0;i<`ISSUE_NUM;++i) begin
        if(ex_decode_sign[i].read || ex_decode_sign[i].write) begin
            ex_mempack.ena = 1;
            ex_mempack.write = ex_decode_sign[i].write;
            ex_mempack.funct3 = ex_pipe[i].instr[`FUNCT3_IDX];
            ex_mempack.addr = ex_get[i].rs_data1 + ex_get[i].imm; 
            ex_mempack.wdata= ex_get[i].rs_data2;
            break;
        end
    end
end
endmodule