module mux #(
    parameter WIDTH = 32, CNT = 1
) (
    input  logic              signs[CNT-1:0],
    input  logic [WIDTH-1:0]  datas[CNT-1:0],
    input  logic [WIDTH-1:0]  default_data,
    output logic [WIDTH-1:0]  sel_data
);

    always_comb begin
        sel_data = default_data;
        for(integer i=0;i<CNT;i++) begin
            if(signs[i]==1'b1) begin
                sel_data = datas[i];
                break;
            end
        end
    end

endmodule