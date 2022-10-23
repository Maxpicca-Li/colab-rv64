`include "def_config.svh"
`include "def_cpu.svh"
`include "def_inst.svh"

module ctrl_transfer(
    input  decode_sign_t [1:0]  decode_sign,
    input  fifo_ctrl_t          fifo_ctrl,
    input  logic [1:0]          issue_en,
    input  pipe_entry_t [1:0]   id_pipe,
    input  id2ex_t [1:0]        id_put,
    
    output logic                id_is_transfer,
    output addr_t               next_pc
);
    addr_t id_transfer_pc;

    always_comb begin
        id_is_transfer = 0;
        id_transfer_pc = 0;
        for(integer i=0;i<`ISSUE_NUM;++i) begin
            if(issue_en[i] & decode_sign[i].b) begin
                // condition
                unique casez (id_pipe[i].instr[`FUNCT3_IDX])
                    `FUNCT3_BEQ: id_is_transfer = $signed(id_put[i].rs_data1) == $signed(id_put[i].rs_data2);
                    `FUNCT3_BNE: id_is_transfer = $signed(id_put[i].rs_data1) != $signed(id_put[i].rs_data2);
                    `FUNCT3_BLT: id_is_transfer = $signed(id_put[i].rs_data1) <  $signed(id_put[i].rs_data2);
                    `FUNCT3_BGE: id_is_transfer = $signed(id_put[i].rs_data1) >= $signed(id_put[i].rs_data2);
                    `FUNCT3_BLTU: id_is_transfer = id_put[i].rs_data1 < id_put[i].rs_data2;
                    `FUNCT3_BGEU: id_is_transfer = id_put[i].rs_data1 >= id_put[i].rs_data2;
                endcase
                id_transfer_pc = id_pipe[i].pc + id_put[i].imm;
                break;
            end
            if(issue_en[i] & decode_sign[i].j) begin
                id_is_transfer = 1;
                id_transfer_pc = id_pipe[i].pc + id_put[i].imm;
                break;
            end
            if(issue_en[i] & decode_sign[i].jr) begin
                id_is_transfer = 1;
                id_transfer_pc = (id_put[i].rs_data1 + id_put[i].imm) & (~(64'd1)); // Bitwise negation
                break;
            end
        end

    end

    mux #(
        .WIDTH         ( $bit(next_pc)),
        .CNT           ( 5          ))
    u_mux(
        //ports
        .signs          ( '{rst    , id_is_transfer, fifo_ctrl.full, inst_valid1 & inst_valid2, inst_valid1       }),
        .datas          ( '{`RST_PC, id_transfer_pc, if_pc         , if_pc      + 8           , if_pc + 4         }),
        .def_data       ( if_pc             ),
        .sel_data       ( next_pc           )
    );
endmodule