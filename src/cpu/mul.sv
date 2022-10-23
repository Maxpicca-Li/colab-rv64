`include "def_cpu.svh"

module mul(
    input  logic    clk,
    input  logic    rst,
    input  data_t   a,
    input  data_t   b,
    input  logic    sign1, // for the operator
    input  logic    sign2,
    input  logic    get_hi,    // for the result
    input  logic    start,
    
    output logic    ready,
    output data_t   result_o
);

hilo_t result, mid_result;

localparam PART_NUM = `XLEN >> 4; // `XLEN / 16
localparam MULT_NUM = PART_NUM * PART_NUM;
logic[31:0] res_muls[MULT_NUM-1:0];

wire a_sign = sign1 && a[`XLEN-1]; // 1: negative; 0: positive
wire b_sign = sign2 && b[`XLEN-1];
wire out_sign = a_sign ^ b_sign;
data_t cal_a = a_sign ? -a : a;
data_t cal_b = b_sign ? -b : b;

always_ff @(posedge clk) begin
    if (rst) begin
        ready <= 0;
        res_muls <= '{default:'0};
    end
    else begin
        if (!ready) begin
            if (start) begin
                ready <= 1'b1;
                for(integer i=0;i<PART_NUM;++i) begin
                    for(integer j=0;j<PART_NUM;++j) begin
                        res_muls[i+j] <= cal_a[16*i+:8] * cal_b[16*j+:8];
                    end
                end
            end
        end else begin
            ready <= 1'b0;
            res_muls <= '{default:'0};
        end
    end
end

always_comb begin
    mid_result = 0;
    for(integer i=0;i<PART_NUM;++i) begin
        for(integer j=0;j<PART_NUM;++j) begin
            mid_result += res_muls[i+j] << ((i+j)*16);
        end
    end
    result = out_sign ? -mid_result : mid_result;
    result_o = get_hi ? result[`XLEN +: `XLEN] : result[0 +: `XLEN];
end

endmodule