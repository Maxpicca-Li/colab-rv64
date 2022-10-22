`include "def_cpu.svh"

module forward_mux(
    input  logic        wen1,
    input  regaddr_t    waddr1,
    input  data_t       wdata1,
    input  logic        wen2,
    input  regaddr_t    waddr2,
    input  data_t       wdata2,
    input  logic        wen3,
    input  regaddr_t    waddr3,
    input  data_t       wdata3,
    input  logic        wen4,
    input  regaddr_t    waddr4,
    input  data_t       wdata4,
    input  logic        wen5,
    input  regaddr_t    waddr5,
    input  data_t       wdata5,
    input  logic        wen6,
    input  regaddr_t    waddr6,
    input  data_t       wdata6,
    
    input  regaddr_t    reg_raddr1,
    input  data_t       reg_rdata1,
    input  regaddr_t    reg_raddr2,
    input  data_t       reg_rdata2,
    output data_t       rs_data1,
    output data_t       rs_data2
);
    localparam NUM = 6;
    logic [NUM-1:0] wens = '{wen1, wen2, wen3, wen4, wen5, wen6};
    regaddr_t [NUM-1:0] waddrs = '{waddr1, waddr2, waddr3, waddr4, waddr5, waddr6};
    data_t [NUM-1:0] wdatas = '{wdata1, wdata2, wdata3, wdata4, wdata5, wdata6};

    always_comb begin
        rs_data1 = reg_rdata1;
        for(integer i=0;i<NUM;++i) begin
            if(wens[i] && ~(|(waddrs[i] ^ reg_raddr1))) begin
                rs_data1 = wdatas[i];
                break;
            end
        end
    end

    always_comb begin
        rs_data2 = reg_rdata2;
        for(integer i=0;i<NUM;++i) begin
            if(wens[i] && ~(|(waddrs[i] ^ reg_raddr2))) begin
                rs_data2 = wdatas[i];
                break;
            end
        end
    end

endmodule