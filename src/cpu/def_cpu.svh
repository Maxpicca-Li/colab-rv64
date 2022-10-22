`ifndef DEF_CPU
`define DEF_CPU

`include "def_common.svh"
`include "def_config.svh"

`define ISSUE_NUM 2

typedef logic[4:0] cpu_int_t; // interrupt
typedef logic[6:0] op_t;
typedef logic[4:0] regaddr_t;
typedef logic[2:0] funct3_t;
typedef logic[6:0] funct7_t;
typedef logic[5:0] funct6_t;
typedef logic[4:0] funct5_t;
typedef logic[5:0] shamt6_t;

typedef enum logic[6:0] { 
    ALU_NOP = 0,
    /* algorithm */
    ALU_ADD, ALU_SUB, ALU_SLT, ALU_SLTU, 
    /* logic */
    ALU_XOR, ALU_OR, ALU_AND, 
    /* shift */
    ALU_SRL, ALU_SRA, ALU_SLL,
    /* other */
    ALU_LUI, ALU_JAL
} aluop_t;

//                 {m_rd m_wr alu_ctrl a32  apc  asht,aimm rs1  rs2   rd   br  jump jalr rev }
`define DECODE_NOP {1'd0,1'd0, ALU_NOP,1'd0,1'd0,1'd0,1'd0,1'd0,1'd0,1'd0,1'd0,1'd0,1'd0,1'd0}
`define DECODE_RI  {1'd0,1'd0, ALU_NOP,1'd0,1'd0,1'd0,1'd0,1'd0,1'd0,1'd0,1'd0,1'd0,1'd0,1'd1}
typedef struct packed {
    logic       mem_read;   // for memory enable and forward logic
    logic       mem_write;  // for result mux at wb stage
    aluop_t     alu_op;
    logic       alu_32;     // alu sign ext 32
    logic       alu_pc;     // alu port a. 1: pc  0: rs1
    logic       alu_shamt;
    logic       alu_imm;    // alu port b. 1: imm 0: rs2
    logic       rs1_en;     // enable rs1 for forwading control
    logic       rs2_en;     // enable rs2 for forwading control
    logic       rd_en;      // enable rd  for forwad ing control and enable reg write
    logic       b;          // for next pc mux
    logic       j;          // for next pc mux and result mux at mem stage
    logic       jr;         // select jump adder source from pc or rs1
    logic       reversed;   // reversed instxr
} decode_sign_t;

typedef struct packed {
    logic full;
    logic empty;
    logic almost_empty;  
} fifo_ctrl_t;

typedef struct packed {
    logic [63:0]pc;
    logic [31:0]instr;
    logic       valid;
} pipe_entry_t;

typedef struct packed {
    logic IF;
    logic ID;
    logic EX;
    logic MM;
    logic WB;
} stall_t;

typedef struct packed {
    logic IF;
    logic ID;
    logic EX;
    logic MM;
    logic WB;
} flush_t;

typedef struct packed {    
    logic       ena;
    logic       write;
    funct3_t    funct3;
    addr_t      addr;
    data_t      wdata;
} mempack_t;

typedef struct packed {
    logic     rd_en;
    regaddr_t rd;
    data_t    res;
} regpack_t;

typedef struct packed {
    data_t imm;
    data_t rs_data1;
    data_t rs_data2;
    data_t shamt;
} id2ex_t;

`endif