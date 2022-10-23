`ifndef DEF_COMMON
`define DEF_COMMON
`include "def_config.svh"

// typedef logic [$bits(`XLEN/8)-1:0] bytecnt_t;
typedef logic [2:0]     bytecnt_t;
typedef logic [7:0]     uint8_t;
typedef logic [15:0]    uint16_t;
typedef logic [31:0]    uint32_t;
typedef logic [63:0]    uint64_t;
typedef logic [127:0]   uint128_t;
typedef uint32_t        inst_t;
typedef uint64_t        addr_t;
typedef uint64_t        data_t;
typedef uint128_t       hilo_t;

interface cpu_ibus_if();
    logic        ena;
    logic        valid1;
    logic        valid2;
    addr_t       addr;
    inst_t       rdata1;
    inst_t       rdata2;

    modport master(
        output ena,
        input valid1, valid2,
        output addr,
        input rdata1,rdata2
    );

    modport slave(
        input ena,
        output valid1, valid2,
        input addr,
        output rdata1,rdata2
    );

endinterface

interface cpu_dbus_if();
    logic       ena;
    bytecnt_t   rlen;
    uint8_t     wea;
    addr_t      addr;
    data_t      wdata;
    data_t      rdata;

    modport master(
        output ena, wea, rlen,
        output addr,
        output wdata,
        input  rdata
    );

    modport slave(
        input ena, wea, rlen,
        input addr,
        input wdata,
        output  rdata
    );
    
endinterface

`endif
