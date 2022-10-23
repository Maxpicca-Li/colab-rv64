`include "def_cpu.svh"

`define QUO_IDX `XLEN-1:0       // quotient is lo
`define REM_IDX 2*`XLEN:`XLEN+1 // remainder is hi

module div(
    input  wire     clk,
    input  wire     rst,
    input  wire     interrupt,
    input  wire     start,
    input  wire     sign1,
    input  wire     sign2,
    input  wire     get_hi,
    input  data_t   a,
    input  data_t   b,

    output logic    ready,
    output data_t   result_o
);

enum { IDLE, DIV_BY_ZERO, DIV_OVERFLOW, DIV_SRA, DIV_ON, SAVE_RESULT } state;

wire   a_sign = sign1 && a[`XLEN-1]; // 1: negative; 0: positive
wire   b_sign = sign2 && b[`XLEN-1];
data_t a_abs = (sign1 && a_sign) ? -a : a;
data_t b_abs = (sign1 && b_sign) ? -b : b;
wire   quo_sign = a_sign ^ b_sign;
wire   rem_sign = a_sign;

logic [6:0] cnt;
logic [`XLEN-1:0] divisor; // b_abs
logic [`XLEN:0] subtract;  // pure_dividend - divisor
logic [2*`XLEN:0] dividend;// {divisor,sign,pure_dividend}
data_t quo_res, rem_res;

assign subtract = {1'b0,dividend[2*`XLEN-1:`XLEN]} - {1'b0,divisor};
assign result_o = get_hi ? rem_res : quo_res;

data_t sra_quo = a >>> b; // arithmetic shift
data_t sra_rem_tmp = a & (b-1);
data_t sra_rem = rem_sign ^ sra_rem_tmp[`XLEN-1] ? -sra_rem_tmp : sra_rem_tmp;

always_ff @ (posedge clk) begin
    if (rst) begin
        state <= IDLE;
        ready <= 0;
        {rem_res, quo_res} <= '0;
        cnt <= '0;
    end else begin
        case (state)
            IDLE: begin
                if(start && !interrupt) begin
                    if(b == 0) begin
                        state <= DIV_BY_ZERO;
                    end else if(sign1 && sign2 && (&a==1) && b==-1) begin
                        state <= DIV_OVERFLOW;
                    end else if(!b_sign && ((b & (b - 1)) == 0)) begin // precondition: b is positive number
                        state <= DIV_SRA;
                    end else begin
                        state <= DIV_ON;
                        cnt <= '0;
                        dividend[`XLEN:0] <= {a_abs, 1'b0};
                        divisor <= b_abs;
                    end
                end else begin
                    ready <= 0;
                    {rem_res, quo_res} <= '0;
                end
            end
            DIV_BY_ZERO: begin
                dividend <= {a,1'b0,{`XLEN{1'b1}}};
                state <= SAVE_RESULT;
            end
            DIV_OVERFLOW: begin
                dividend <= {{`XLEN{1'b0}},1'b0,a};
                state <= SAVE_RESULT;
            end
            DIV_SRA: begin
                dividend <= {sra_rem,1'b0,sra_quo};
                state <= SAVE_RESULT;
            end
            DIV_ON: begin
                if(!interrupt) begin
                    if(cnt != 7'b1000000) begin
                        if(subtract[`XLEN] == 1'b1) begin               // dividend < divisor
                            dividend <= {dividend[2*`XLEN-1:0] , 1'b0}; // quo 0
                        end else begin
                            dividend <= {subtract[`XLEN-1:0] , dividend[`XLEN-1:0] , 1'b1}; // quo 1
                        end
                        cnt <= cnt + 1;
                    end else begin
                        state <= SAVE_RESULT;
                        cnt <= 6'b000000;
                        if(quo_sign) 
                            dividend[`QUO_IDX] <= (~dividend[`QUO_IDX] + 1);  
                        if(rem_sign ^ dividend[2*`XLEN]) 
                            dividend[`REM_IDX] <= (~dividend[`REM_IDX] + 1);
                    end
                end else begin
                    state <= IDLE;
                end	
            end
            SAVE_RESULT: begin
                rem_res <= dividend[`REM_IDX];
                quo_res <= dividend[`QUO_IDX];
                ready <= 1;
                if(start == 0) begin
                    state <= IDLE;
                    ready <= 0;
                    {rem_res, quo_res} <= '0;
                end
            end
        endcase
    end
end

endmodule