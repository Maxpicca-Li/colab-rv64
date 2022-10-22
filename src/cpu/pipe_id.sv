`include "def_cpu.svh"
`include "def_inst.svh"

module pipe_id(
    input  logic                valid_id,
    input  logic                stall_id,
    input  fifo_ctrl_t          fifo_ctrl,
    input  pipe_entry_t [1:0]   id_pipe,
    input  logic [1:0]          ex_mem_read,
    input  regpack_t [1:0]      ex_put,
    input  regpack_t [1:0]      mm_put,
    input  regpack_t [1:0]      wb_put,
    
    output decode_sign_t [1:0]  decode_sign,
    output id2ex_t [1:0]        id_put,
    output logic [1:0]          issue_en
);

for(genvar i=0;i<`ISSUE_NUM;++i) begin
    decoder u_decoder(
        .instr(id_pipe[i].instr),
        .imm(id_put[i].imm),
        .shamt(id_put[i].shamt),
        .decode_sign(decode_sign[i])
    );
end

issue_ctrl u_issue_ctrl (
    .valid_id(valid_id), 
    .stall_id(stall_id),
    .fifo_ctrl(fifo_ctrl),
    .id_pipe(id_pipe),
    .ex_put_rd('{ex_put[0].rd, ex_put[1].rd}),
    .ex_mem_read(ex_mem_read),
    .id_decode_sign(decode_sign),

    .issue_en(issue_en)
);

// regfile
regaddr_t [3:0] reg_raddr;
data_t [3:0]    reg_rdata;
logic [1:0]     reg_wen;
regaddr_t [1:0] reg_waddr;
data_t  [1:0]   reg_wdata;

for(genvar i=0;i<`ISSUE_NUM;++i) begin
    always_comb begin
        reg_wen[i] = wb_put[i].rd_en;
        reg_waddr[i] = wb_put[i].rd;
        reg_wdata[i] = wb_put[i].res;
    end
end

regfile #(  
    .REG_NUM        (32),
    .DATA_WIDTH     (64),
    .READ_PORTS     (4),
    .WRITE_PORTS    (2),
    .ZERO_KEEP      (1)
) u_regfile (
    .clk(clk),
    .rst(rst),
    .raddr(reg_raddr),
    .rdata(reg_rdata),
    .wen(reg_wen),
    .waddr(reg_waddr),
    .wdata(reg_wdata)
);

// forward
for (genvar i=0;i<`ISSUE_NUM;++i) begin
    assign reg_raddr[2*i  ] = id_pipe[i].instr[`RS1_IDX];
    assign reg_raddr[2*i+1] = id_pipe[i].instr[`RS2_IDX];
    forward_mux u_forward_mux(
        .wen1(ex_put[1].rd_en),
        .waddr1(ex_put[1].rd),
        .wdata1(ex_put[1].res),
        .wen2(ex_put[0].rd_en),
        .waddr2(ex_put[0].rd),
        .wdata2(ex_put[0].res),
        .wen3(mm_put[1].rd_en),
        .waddr3(mm_put[1].rd),
        .wdata3(mm_put[1].res),
        .wen4(mm_put[0].rd_en),
        .waddr4(mm_put[0].rd),
        .wdata4(mm_put[0].res),
        .wen5(wb_put[1].rd_en),
        .waddr5(wb_put[1].rd),
        .wdata5(wb_put[1].res),
        .wen6(wb_put[0].rd_en),
        .waddr6(wb_put[0].rd),
        .wdata6(wb_put[0].res),
        
        .reg_raddr1(id_pipe[i].instr[`RS1_IDX]),
        .reg_rdata1(reg_rdata[2*i  ]),
        .reg_raddr2(id_pipe[i].instr[`RS1_IDX]),
        .reg_rdata2(reg_rdata[2*i+1]),
        .rs_data1(id_put[i].rs_data1),
        .rs_data2(id_put[i].rs_data2)
    );
end

endmodule