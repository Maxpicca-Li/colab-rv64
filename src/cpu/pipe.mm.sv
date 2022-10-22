`include "def_cpu.svh"
`include "def_inst.svh"

module pipe_mm(
    input  mempack_t            mm_mempack,
    input  regpack_t [1:0]      mm_get,
    input  decode_sign_t [1:0]  mm_decode_sign,
    
    output regpack_t [1:0]      mm_put,
    cpu_dbus_if.master          dbus
);

bytecnt_t rlen;
uint8_t wea;
data_t rdata, wdata;
assign dbus.ena = mm_mempack.ena;
assign dbus.rlen = rlen;
assign dbus.wea = wea;
assign dbus.addr = mm_mempack.addr; 

for(genvar i=0;i<`ISSUE_NUM;++i) begin
    always_comb begin
        mm_put[i].rd_en = mm_get[i].rd_en;
        mm_put[i].rd = mm_get[i].rd;
        mm_put[i].res = mm_decode_sign[i].mm_read ? rdata : mm_get[i].res;
    end
end

always_comb begin
    wea = 0;
    wdata = 0;
    if(mm_mempack.write) begin
        unique casez(mm_mempack.funct3)
            `FUNCT3_SB: begin
                wea = (8'b1 << mm_mempack.addr[2:0]);
                wdata = {8{mm_mempack.wdata[7:0]}};
            end
            `FUNCT3_SH: begin
                wea = (8'b11 << mm_mempack.addr[2:0]);
                wdata = {4{mm_mempack.wdata[15:0]}};
            end
            `FUNCT3_SW: begin
                wea = (8'b1111 << mm_mempack.addr[2:0]);
                wdata = {2{mm_mempack.wdata[31:0]}};
            end
            `FUNCT3_SD: begin
                wea = '1;
                wdata = mm_mempack.wdata;
            end
            default: begin
                wea = 0;
                wdata = 0;
            end
        endcase
    end else begin
        unique casez(mm_mempack.funct3) 
            `FUNCT3_LB: begin
                rlen = 1;
                rdata = {{56{dbus.rdata[7]}}, dbus.rdata[7:0]};
            end
            `FUNCT3_LBU:begin
                rlen = 1;
                rdata = {56'd0, dbus.rdata[7:0]};
            end
            `FUNCT3_LH: begin
                rlen = 2;
                rdata = {{48{dbus.rdata[15]}}, dbus.rdata[15:0]};
            end
            `FUNCT3_LHU:begin
                rlen = 2;
                rdata = {48'd0, dbus.rdata[15:0]};
            end
            `FUNCT3_LW: begin
                rlen = 4;
                rdata = {{32{dbus.rdata[31]}}, dbus.rdata[31:0]};
            end
            `FUNCT3_LWU:begin
                rlen = 4;
                rdata = {32'd0, dbus.rdata[31:0]};
            end
            `FUNCT3_LD: begin
                rlen = 8;
                rdata = dbus.rdata;
            end
        endcase
    end
end

endmodule