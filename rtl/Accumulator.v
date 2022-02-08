module Accumulator #(
    parameter DATA_WIDTH = 14
)
(clk,arstn,data_in,data_valid,data_out,clear);
input clk;
input arstn;
input [DATA_WIDTH-1:0]data_in;
input data_valid;
input clear;
output [DATA_WIDTH-1:0]data_out;

reg [DATA_WIDTH-1:0]acc_reg;
assign data_out = acc_reg;

always@(posedge clk or negedge arstn)
    begin
        if(~arstn)
            acc_reg <= 0;
        else
            begin
                if(clear)
                    acc_reg <= 0;
                else
                    begin
                        if(data_valid)
                            acc_reg <= acc_reg + data_in;
                        else
                            acc_reg <= acc_reg;
                    end
            end
    end


endmodule
