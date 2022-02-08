module Accumulator_Ram #(
    parameter DATA_WIDTH = 14,
    parameter DATA_DEPTH = 256 
)(clk,arstn,write_addr_A,write_data_A,wvalid_A,
   read_addr_A,read_data_A,rvalid_A,dvalid_A,clear);

function integer clogb2(input integer bit_depth);
    begin
        for(clogb2 = 0;bit_depth > 0;clogb2 = clogb2 + 1)
            bit_depth = bit_depth >> 1;
    end
endfunction

localparam ADDRESS_WIDTH = clogb2(DATA_DEPTH - 1);

input clk;
input arstn;
input [ADDRESS_WIDTH-1:0]write_addr_A;
input [DATA_WIDTH-1:0]write_data_A;
input wvalid_A;
input [ADDRESS_WIDTH-1:0]read_addr_A;
output [DATA_WIDTH-1:0]read_data_A;
input rvalid_A;
output dvalid_A;
input clear;

reg [DATA_WIDTH-1:0]rdata_A;
reg dvalid_A_reg;
reg [DATA_WIDTH-1:0]mem[DATA_DEPTH-1:0];
integer i;

assign read_data_A = rdata_A;
assign dvalid_A = dvalid_A_reg;

/* async reset mem */
always@(negedge arstn)
    begin
        if(~arstn)
            begin
                for(i=0;i<DATA_DEPTH;i=i+1)
                    begin
                        mem[i]<=0;
                    end 
            end
    end

/* port A: write DATA */
always@(posedge clk)
    begin
        if(wvalid_A & arstn)
            mem[write_addr_A]<=write_data_A;
    end

/* port A: read DATA */
always@(posedge clk or negedge arstn)
    begin
        if(~arstn)
            begin
                rdata_A <= 0;
                dvalid_A_reg <= 1'b0;
            end
        else
            begin
                if(rvalid_A)
                    begin
                        rdata_A <= mem[read_addr_A];
                        dvalid_A_reg <= 1'b1;
                        if(clear)
                            mem[read_addr_A]<=0;
                    end
                 else
                    begin
                        dvalid_A_reg <= 1'b0;
                    end
            end
    end
endmodule















