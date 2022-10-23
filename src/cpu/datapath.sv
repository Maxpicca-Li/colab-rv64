`include "def_cpu.svh"
`include "def_inst.svh"

module datapath (
    input               clk,
    input               rst,
    input  cpu_int_t    cpu_int, 
    cpu_ibus_if.master  ibus, 
    cpu_dbus_if.master  dbus
);

stall_t             stall;
flush_t             flush;
addr_t              if_pc, next_pc;
fifo_ctrl_t         fifo_ctrl;
mempack_t           ex_mempack, mm_mempack;

logic               id_is_transfer;
logic               ex_alu_stall;
logic[1:0]          issue_en;
pipe_entry_t [1:0]  id_pipe, ex_pipe, mm_pipe, wb_pipe;
decode_sign_t [1:0] id_decode_sign, ex_decode_sign, mm_decode_sign, wb_decode_sign;
id2ex_t [1:0]       id_put, ex_get;
regpack_t [1:0]     ex_gut, mm_get;
regpack_t [1:0]     mm_put, wb_get;
regpack_t [1:0]     wb_put;

// TODO: except
assign ibus.addr = if_pc;

ctrl_pipe u_ctrl_pipe(
    .*
);

ctrl_transfer u_ctrl_transfer(
    .decode_sign(id_decode_sign),
    .fifo_ctrl(fifo_ctrl),
    .issue_en(issue_en),
    .id_pipe(id_pipe),
    .id_put(id_put),
    
    .id_is_transfer(id_is_transfer),
    .next_pc(next_pc)
);

pipe_if u_pipe_if(
    .clk(clk),
    .rst(rst),
    .flush_id(flush.ID),
    .inst_valid1(ibus.valid1),
    .inst_valid2(ibus.valid1),
    .inst_data1(ibus.data1),
    .inst_data2(ibus.data2),
    .issue_en(issue_en),
    .next_pc(next_pc),

    .if_pc(if_pc),
    .id_pipe(id_pipe),
    .fifo_ctrl(fifo_ctrl)
);

// NOTE:no flip_flop beacause of timing sequence of fifo

pipe_id u_pipe_id(
    .valid_id(!rst),
    .stall_id(stall.ID),
    .fifo_ctrl(fifo_ctrl),
    .id_pipe(id_pipe),
    .ex_mem_read('{ex_decode_sign[0].mem_read, ex_decode_sign[1].mem_read}),
    .ex_put(ex_put),
    .mm_put(mm_put),
    .wb_put(wb_put),
    
    .decode_sign(id_decode_sign),
    .id_put(id_put),
    .issue_en(issue_en)
);

for (genvar i=0;i<`ISSUE_NUM;++i) begin
    flip_flop #(.WIDTH($bits({id_pipe[i],id_decode_sign[i],id_put[i]}))) id2ex_ff(
        .clk        (clk),
        .rst        (rst),
        .flush      (flush.EX | !issue_en[i]),
        .stall      (stall.EX),
        .data_in    ({id_pipe[i],id_decode_sign[i],id_put[i]}),
        .data_out   ({ex_pipe[i],ex_decode_sign[i],ex_get[i]})
    );
end

pipe_ex u_pipe_ex(
    .clk(clk),
    .rst(rst),
    .ex_pipe(ex_pipe),
    .ex_decode_sign(ex_decode_sign),
    .ex_get(ex_get),
    
    .alu_stall(ex_alu_stall),
    .ex_mempack(ex_mempack),
    .ex_gut(ex_gut)
);

flip_flop #(.WIDTH($bits({ex_pipe,ex_decode_sign,ex_gut,ex_mempack}))) ex2mm_ff(
    .clk        (clk),
    .rst        (rst),
    .flush      (flush.MM),
    .stall      (stall.MM),
    .data_in    ({ex_pipe,ex_decode_sign,ex_gut,ex_mempack}),
    .data_out   ({mm_pipe,mm_decode_sign,mm_get,mm_mempack})
);

pipe_mm u_pipe_mm(
    .mm_mempack(mm_mempack),
    .mm_get(mm_get),
    .mm_decode_sign(mm_decode_sign),
    
    .mm_put(mm_put),
    .dbus(dbus)
);

flip_flop #(.WIDTH($bits({mm_pipe,mm_decode_sign,mm_put}))) mm2wb_ff(
    .clk        (clk),
    .rst        (rst),
    .flush      (flush.MM),
    .stall      (stall.MM),
    .data_in    ({mm_pipe,mm_decode_sign,mm_put}),
    .data_out   ({wb_pipe,wb_decode_sign,wb_get })
);

pipe_wb u_pipe_wb(
    .stall(stall),
    .wb_get(wb_get),
    .wb_put(wb_put)
);

endmodule