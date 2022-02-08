module Histogram #(
    parameter PIXEL_WIDTH = 8,
    parameter IMAGE_WIDTH = 640,
    parameter IMAGE_HEIGHT = 480,
    parameter COLOR_RANGE = 256
)(clk,arstn,pixel_in,pixel_valid,data_out,dout_valid,dout_addr,dout_rreq,clear);

function integer clogb2(input integer bit_depth);
    begin
        for(clogb2 = 0;bit_depth >0; clogb2 = clogb2 + 1)
            bit_depth = bit_depth >> 1;
    end
endfunction

localparam TOTAL_PIXEL = IMAGE_WIDTH*IMAGE_HEIGHT;
localparam DATA_WIDTH = clogb2(TOTAL_PIXEL - 1);
localparam ADDRESS_WIDTH = clogb2(COLOR_RANGE - 1);

input clk;
input arstn;
input [PIXEL_WIDTH-1:0]pixel_in;
input pixel_valid;
output [DATA_WIDTH-1:0]data_out;
output dout_valid;
input [ADDRESS_WIDTH-1:0]dout_addr;
input dout_rreq;
input clear;
reg [PIXEL_WIDTH-1:0]pixel_in_delay;
reg pixel_valid_delay;
wire [DATA_WIDTH-1:0]inc_data;
wire [DATA_WIDTH-1:0]data_out_A;
wire dvalid_A;
wire mode;
assign inc_data = data_out_A + 1'b1;

always@(posedge clk or negedge arstn)
    begin
        if(~arstn)
            pixel_in_delay <= 0;
        else
            pixel_in_delay <= pixel_in;
    end

always@(posedge clk or negedge arstn)
    begin
        if(~arstn)
            pixel_valid_delay <= 0;
        else
            pixel_valid_delay <= pixel_valid;
    end 

//Incer #(
//    .DATA_WIDTH(DATA_WIDTH)
//)Inst_Incer(
//    .clk(clk),
//    .arstn(arstn),
//    .din(data_out_A),
//    .dout(inc_data),
//    .mode(mode)
//);

Histogram_Ram #(
    .PIXEL_WIDTH(PIXEL_WIDTH),
    .IMAGE_WIDTH(IMAGE_WIDTH),
    .IMAGE_HEIGHT(IMAGE_HEIGHT),
    .COLOR_RANGE(COLOR_RANGE)
) Inst_ram(
    .clk(clk),
    .arstn(arstn),
    .read_addr_A(pixel_in),
    .read_data_A(data_out_A),
    .rvalid_A(pixel_valid),
    .dvalid_A(dvalid_A),
    .write_addr_A(pixel_in_delay),
    .write_data_A(inc_data),
    .wvalid_A(pixel_valid_delay),
    .read_addr_B(dout_addr),
    .read_data_B(data_out),
    .rvalid_B(dout_rreq),
    .dvalid_B(dout_valid),
    .clear(clear)
);
endmodule








