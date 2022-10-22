`include "def_cpu.svh"

module pipe_if(
    input  logic                clk,
    input  logic                rst,
    input  logic                flush_id,
    input  logic                inst_valid1,
    input  logic                inst_valid2,
    input  inst_t               inst_data1,
    input  inst_t               inst_data2,
    input  logic [1:0]          issue_en,
    input  addr_t               next_pc,
    
    output addr_t               if_pc,
    output pipe_entry_t [1:0]   id_pipe,
    output fifo_ctrl_t          fifo_ctrl
);

pipe_entry_t read_entry1, read_entry2;

assign id_pipe = {read_entry1, read_entry2};

flip_flop #(
    .WIDTH         ( $bit(next_pc)    ))
pc_flip_flop(
    //ports
    .clk              ( clk              ),
    .rst              ( 0                ),
    .flush            ( 0                ),
    .stall            ( 0                ),
    .data_in          ( next_pc          ),
    .data_out         ( if_pc            )
);


logic fifo_rst;
assign fifo_rst = rst | flush_id;

inst_fifo #(
    .CNT                ( `FIFO_CNT        ))
u_inst_fifo(
    //ports
    .clk                ( clk               ),
    .rst                ( rst               ),
    .fifo_rst           ( fifo_rst          ),
    .fifo_ctrl          ( fifo_ctrl         ),
    .read_en1           ( issue_en[0]       ),
    .read_en2           ( issue_en[1]       ),
    .read_entry1        ( id_pipe1          ),
    .read_entry2        ( id_pipe2          ),
    .write_en1          ( inst_valid1       ),
    .write_en2          ( inst_valid2       ),
    .write_entry1       ( '{pc:if_pc      , instr:inst_data1, valid:inst_valid1}),
    .write_entry2       ( '{pc:if_pc+64'd4, instr:inst_data2, valid:inst_valid2})
);

endmodule