`include "def_cpu.svh"

module inst_fifo #(
    parameter int unsigned CNT = 16
)(
    input                       clk,
    input                       rst,
    input                       fifo_rst ,
    output fifo_ctrl_t          fifo_ctrl,

    input                       read_en1,
    input                       read_en2,
    output pipe_entry_t         read_entry1,
    output pipe_entry_t         read_entry2,

    input                       write_en1,
    input                       write_en2,
    input pipe_entry_t          write_entry1,
    input pipe_entry_t          write_entry2
);

    localparam BIT_CNT = $clog2(CNT);
    typedef logic[BIT_CNT-1:0] idx_t;
    
    // FIFO Structure
    pipe_entry_t entries[CNT-1:0] = '{default:'0};
    idx_t write_pointer;
    idx_t read_pointer;
    idx_t data_count;

    // FIFO State
    // NOTE: need to ensure that there is at least one inst in the FIFO
    // NOTE: use 1'd1 to prevent overflow
    assign fifo_ctrl.full         = &data_count[BIT_CNT-1:1] || (write_pointer+1'd1==read_pointer);
    assign fifo_ctrl.empty        = (data_count[0] == 1'b0); //0000
    assign fifo_ctrl.almost_empty = (data_count[1] == 1'b1); //0001

    // Read
    always_comb begin
        if(fifo_ctrl.empty) begin
            read_entry1 = '{default: '0};
            read_entry2 = '{default: '0};
        end
        else if(fifo_ctrl.almost_empty) begin
            read_entry1 = entries[read_pointer];
            read_entry2 = '{default: '0};
        end 
        else begin
            read_entry1 = entries[read_pointer];
            read_entry2 = entries[read_pointer + 1'd1];
        end
    end

    // Write
    always_ff @(posedge clk) begin : write_data 
        if(write_en1) begin
            entries[write_pointer] <= write_entry1;
        end
        if(write_en2) begin
            entries[write_pointer + 1'd1] <= write_entry2;
        end
    end
    
    // pointer and counter
    always_ff @(posedge clk) begin
        if(fifo_rst) begin
            write_pointer <= 1'd0;
            read_pointer <= 1'd0;
            data_count <= 1'd0;
        end else begin
            // NOTE: The order between read_en1 and read_en2 is not considered here
            write_pointer <= write_pointer + write_en1 + write_en2;
            if(fifo_ctrl.empty) begin
                read_pointer <= read_pointer;
                data_count  <= data_count + write_en1 + write_en2;
            end else begin
                read_pointer <= read_pointer + read_en1 + read_en2;
                data_count <= data_count + write_en1 + write_en2 - read_en1 - read_en2;
            end
        end
    end

    // Record
    reg [64:0] cnt2;
    reg [64:0] cnt1;
    wire [64:0] total_cnt = cnt1 + cnt2;
    always_ff @(posedge clk) begin
        if(rst) begin
            cnt1 <= 0;
            cnt2 <= 0;
        end
        else begin
            if(read_en1 && !fifo_ctrl.empty) cnt1 <= cnt1 + 1'd1;
            if(read_en2 && !fifo_ctrl.empty) cnt2 <= cnt2 + 1'd1;
        end
    end
    
endmodule