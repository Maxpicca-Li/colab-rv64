`include "def_cpu.svh"
`include "def_inst.svh"
module ctrl_pipe(
    input  logic rst,
    input  logic                id_is_transfer,
    input  decode_sign_t [1:0]  id_decode_sign,
    input  decode_sign_t [1:0]  ex_decode_sign,
    
    output stall_t              stall,
    output flush_t              flush
);

    // NOTE: need careful consideration
    logic stall_from_id, stall_from_ex, stall_from_mm;
    logic flush_from_id, flush_from_ex, flush_from_mm;
    
    always_comb begin
        stall_from_id = 0;
        stall_from_ex = 0;
        stall_from_mm = 0;
        for(integer i=0;i<`ISSUE_NUM;++i) begin
            stall_from_id |= ex_decode_sign[i].mem_read && (
                            (id_decode_sign[0].rs1_en && id_pipe[0].instr[`RS1_IDX] == ex_put[i].rd) ||
                            (id_decode_sign[0].rs2_en && id_pipe[0].instr[`RS2_IDX] == ex_put[i].rd) );
        end
    end

    always_comb begin
        flush_from_id = id_is_transfer;
        flush_from_ex = 0;
        flush_from_mm = 0;
    end
    
    always_comb begin        
        if(rst) stall = 5'b11111;
        else if(stall_from_mm) stall = 5'b11111;
        else if(stall_from_ex) stall = 5'b11110;
        else if(stall_from_id) stall = 5'b11000;
        else stall = '0;
    end

    always_comb begin        
        if(rst) flush = 5'b11111;
        else if(flush_from_mm) flush = 5'b11110;
        else if(flush_from_ex) flush = 5'b11100;
        else if(flush_from_id) flush = 5'b11000;
        else flush = '0;
    end

endmodule