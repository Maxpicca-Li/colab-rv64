`include "def_cpu.svh"
`include "def_inst.svh"

module pipe_wb(
    input  stall_t              stall,
    input  regpack_t [1:0]      wb_get,
    output regpack_t [1:0]      wb_put
);

for(genvar i=0;i<`ISSUE_NUM;++i) begin
    always_comb begin
        wb_put[i].rd_en = wb_get[i].rd_en && !stall.WB;
        wb_put[i].rd = wb_get[i].rd;
        wb_put[i].res = wb_get[i].res;
    end
end

endmodule