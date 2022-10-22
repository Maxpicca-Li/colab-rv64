module regfile #(
    parameter int REG_NUM = 32,
    parameter int DATA_WIDTH = 32,
    parameter int READ_PORTS = 2,
    parameter int WRITE_PORTS = 1,
    parameter int ZERO_KEEP = 1
)(
    input  clk,
    input  rst,
    input  logic [READ_PORTS-1:0][$clog2(REG_NUM)-1:0]  raddr,
    output logic [READ_PORTS-1:0][DATA_WIDTH-1:0]       rdata,
    input  logic [WRITE_PORTS-1:0]                      wen,
    input  logic [WRITE_PORTS-1:0][$clog2(REG_NUM)-1:0] waddr,
    input  logic [WRITE_PORTS-1:0][DATA_WIDTH-1:0]      wdata
);

    logic [REG_NUM-1:0][DATA_WIDTH-1:0] rf, rf_new;

    // read
    for(genvar i=0; i<READ_PORTS; ++i) begin
        assign rdata[i] = rf[raddr[i]];
    end

    // write
    always_comb begin
        rf_new = rf;
        for(integer i=0; i<WRITE_PORTS; ++i) begin
            if(wen[i] && waddr[i]!=0) begin
                rf_new[waddr[i]] = wdata[i];
            end
        end
    end
    always_ff @(posedge clk) begin
        if(rst) rf <= '0;
        else rf <= rf_new;
    end

    /*
    // write method2
    always_ff @(posedge clk) begin
        if(rst) rf <= '0;
        else begin
            // NOTE: is multive drives? or you can refer to nontrival-mips 
            for(integer i=0; i<WRITE_PORTS; ++i) begin
                if(wen[i] && waddr[i]!=0) begin
                    rf[waddr[i]] <= wdata[i];
                end
            end
        end
    end
    */

endmodule