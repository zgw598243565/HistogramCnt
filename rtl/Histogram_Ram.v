module Histogram_Ram #(
    parameter PIXEL_WIDTH = 8,
    parameter IMAGE_WIDTH = 640,
    parameter IMAGE_HEIGHT = 480,
    parameter COLOR_RANGE = 256   
)(clk,arstn,read_addr_A,read_data_A,rvalid_A,dvalid_A,write_addr_A,write_data_A,wvalid_A,
  read_addr_B,read_data_B,rvalid_B,dvalid_B,clear);

function integer clogb2(input integer bit_depth);
    begin
        for(clogb2 = 0;bit_depth > 0;clogb2 = clogb2 + 1)
            bit_depth = bit_depth >> 1;
    end
endfunction

localparam TOTAL_PIXEL = IMAGE_WIDTH*IMAGE_HEIGHT;
localparam DATA_WIDTH = clogb2(TOTAL_PIXEL - 1);
localparam ADDRESS_WIDTH = clogb2(COLOR_RANGE - 1);

input clk;
input arstn;
input [ADDRESS_WIDTH-1:0]read_addr_A;
output [DATA_WIDTH-1:0]read_data_A;
input rvalid_A;
input [ADDRESS_WIDTH-1:0]write_addr_A;
input [DATA_WIDTH-1:0]write_data_A;
input wvalid_A;
input [ADDRESS_WIDTH-1:0]read_addr_B;
output [DATA_WIDTH-1:0]read_data_B;
input rvalid_B;
input clear;
output dvalid_A;
output dvalid_B;
reg [DATA_WIDTH-1:0]rdata_A;
reg [DATA_WIDTH-1:0]rdata_B;
reg dvalid_A_reg;
reg dvalid_B_reg;
reg [DATA_WIDTH-1:0]mem[COLOR_RANGE-1:0];
integer i;

assign read_data_A = rdata_A;
assign read_data_B = rdata_B;
assign dvalid_A = dvalid_A_reg;
assign dvalid_B = dvalid_B_reg;

/* async reset mem */
always@(negedge arstn)
    begin
        if(~arstn)
            begin
                for(i=0;i<COLOR_RANGE;i=i+1)
                    begin
                        mem[i]<=0;
                    end
            end
    end

/* port A :write DATA */
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
                rdata_A<=0;
                dvalid_A_reg<=0;
            end
        else
            begin
                if(rvalid_A)
                    begin
                        rdata_A<=mem[read_addr_A];
                        dvalid_A_reg<=1'b1;
                    end
                else
                    begin
                        dvalid_A_reg <= 1'b0; /* miss */
                    end 
            end
    end
    
/* Port B: read DATA */
always@(posedge clk or negedge arstn)
    begin
        if(~arstn)
            begin
                rdata_B <= 0;
                dvalid_B_reg <= 1'b0;
            end
        else
            begin
                if(rvalid_B)
                    begin
                        rdata_B <= mem[read_addr_B];
                        dvalid_B_reg <= 1'b1;
                        if(clear)
                            mem[read_addr_B]<=0;
                    end
                else
                    begin
                        dvalid_B_reg <= 1'b0;
                    end
            end
    end
endmodule













