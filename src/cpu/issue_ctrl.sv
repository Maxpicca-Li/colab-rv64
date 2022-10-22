`include "def_cpu.svh"
`include "def_inst.svh"

module issue_ctrl (
    input  logic                valid_id, 
    input  logic                stall_id,
    input  fifo_ctrl_t          fifo_ctrl,
    input  pipe_entry_t [1:0]   id_pipe,
    input  regaddr_t [1:0]      ex_put_rd,
    input  logic [1:0]          ex_mem_read,
    input  decode_sign_t[1:0]   id_decode_sign,

    output logic[1:0]    issue_en
);

    logic war_reg, war_load, conflict_mem, conflict_ctrl, invalid_fifo;

    assign war_reg =  id_decode_sign[0].rd_en & (
                     (id_decode_sign[1].rs1_en & id_pipe[1].instr[`RS1_IDX] == id_pipe[0].instr[`RD_IDX]) |
                     (id_decode_sign[1].rs2_en & id_pipe[1].instr[`RS2_IDX] == id_pipe[0].instr[`RD_IDX]) );
    assign invalid_fifo = !fifo_ctrl.empty & !fifo_ctrl.almost_empty;
    assign conflict_ctrl = !(id_decode_sign[0].branch | id_decode_sign[0].jump | id_decode_sign[0].jalr);
    
    always_comb begin
        war_load = 0;
        conflict_mem = 1;
        for(integer i=0;i<`ISSUE_NUM;++i) begin
            war_load |= ex_mem_read[i] && (
                        (id_decode_sign[1].rs1_en && id_pipe[1].instr[`RS1_IDX] == ex_put_rd[i]) ||
                        (id_decode_sign[1].rs2_en && id_pipe[1].instr[`RS2_IDX] == ex_put_rd[i]) );
            conflict_mem &=  id_decode_sign[i].mem_read | id_decode_sign[i].mem_write;
        end
    end
    
    always_comb begin
        if(valid_id) begin
            issue_en[0] = !stall_id;
            issue_en[1] = !(stall_id | war_reg | war_load | invalid_fifo | conflict_mem | conflict_ctrl);
        end
    end

endmodule