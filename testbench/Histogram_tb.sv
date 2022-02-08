`timescale 1ns / 1ps

module Histogram_tb;
parameter PIXEL_WIDTH = 8;
parameter IMAGE_WIDTH = 120;
parameter IMAGE_HEIGHT = 10;
parameter COLOR_RANGE = 256;

function integer clogb2(input integer bit_depth);
    begin
        for(clogb2 = 0;bit_depth >0; clogb2 = clogb2 + 1)
            bit_depth = bit_depth >> 1;
    end
endfunction

localparam TOTAL_PIXEL = IMAGE_WIDTH*IMAGE_HEIGHT;
localparam DATA_WIDTH = clogb2(TOTAL_PIXEL - 1);
localparam ADDRESS_WIDTH = clogb2(COLOR_RANGE - 1);

bit clk;
bit arstn;
bit [7:0]pixel_in;
bit pixel_valid;
wire [DATA_WIDTH-1:0]data_out;
wire dout_valid;
bit [ADDRESS_WIDTH-1:0]dout_addr;
bit dout_rreq;
bit clear;
int image[IMAGE_HEIGHT][IMAGE_WIDTH];
int histogram[COLOR_RANGE];
int i,j;
int temp1;
int temp2;
int temp3;
always #5 clk = ~clk;

initial
    begin
        clear = 1'b0;
        dout_rreq = 1'b0;
        pixel_valid = 1'b0;
        arstn = 1'b1;
        for(i=0;i<COLOR_RANGE;i=i+1)
            begin
                histogram[i]=0;
            end
        for(i=0;i<IMAGE_HEIGHT;i=i+1)
            begin
                for(j=0;j<IMAGE_WIDTH;j=j+1)
                    begin
                        //temp1 = $random()%256;
                        image[i][j] = j;
                        histogram[image[i][j]]++;
                    end
            end
        
        #20
            arstn = 1'b0;
        #20
            arstn = 1'b1;
        
        for(i=0;i<IMAGE_HEIGHT;i=i+1)
            begin
                for(j=0;j<IMAGE_WIDTH;j=j+1)
                    begin
                        @(posedge clk);
                        #2
                            pixel_in = image[i][j];
                            pixel_valid = 1'b1;
                    end
            end
        @(posedge clk);
        @(posedge clk);
        pixel_valid = 1'b0;
        
        for(i=0;i<COLOR_RANGE;i=i+1)
            begin
                @(posedge clk);
                #2
                    dout_addr = i;
                    dout_rreq = 1'b1;
                @(posedge clk);
                @(posedge clk);
                $display("i is%d,soft_hist is%d, hard_hist is%d",i,histogram[i],data_out);
            end
        $display("histogram test finish");
        #200 $finish();
    end

Histogram #(
    .PIXEL_WIDTH(PIXEL_WIDTH),
    .IMAGE_WIDTH(IMAGE_WIDTH),
    .IMAGE_HEIGHT(IMAGE_HEIGHT),
    .COLOR_RANGE(COLOR_RANGE)
)Dut(clk,arstn,pixel_in,pixel_valid,data_out,dout_valid,dout_addr,dout_rreq,clear);
endmodule
