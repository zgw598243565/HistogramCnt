module HistAccmulator #(
     parameter IMAGE_WIDTH = 640,
     parameter IMAGE_HEIGHT = 480,
     parameter COLOR_RANGE = 256
)
(clk,arstn,data_in,data_valid,addr,addr_valid,start,data_out,dout_valid,raddr,raddr_valid,clear,done);


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
input [DATA_WIDTH-1:0]data_in;
input data_valid;
output [ADDRESS_WIDTH-1:0]addr;
output addr_valid;
input start;
output [DATA_WIDTH-1:0]data_out;
output dout_valid;
input [ADDRESS_WIDTH-1:0]raddr;
input raddr_valid;
input clear;
output done;
wire [DATA_WIDTH-1:0]acculator_out;
wire wreq;
wire adder_done;
Accumulator #(
    .DATA_WIDTH(DATA_WIDTH)
)Inst_accumulator(
    .clk(clk),
    .arstn(arstn),
    .data_in(data_in),
    .data_valid(data_valid),
    .data_out(acculator_out),
    .clear(done)
);

Addr_Controller #(
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .COLOR_RANGE(256)
)Inst_adder_comtroller(
    .clk(clk),
    .arstn(arstn),
    .start(start),
    .done(adder_done),
    .addr(addr),
    .addr_valid(addr_valid),
    .wreq(wreq)
);

reg [ADDRESS_WIDTH-1:0]addr_dely0;
reg [ADDRESS_WIDTH-1:0]addr_dely1;
reg wreq_dely0;
reg wreq_dely1;
reg done_dely0;
reg done_dely1;


always@(posedge clk or negedge arstn)
    begin
        if(~arstn)
            begin
                addr_dely0 <= 0;
                addr_dely1 <= 0;
                wreq_dely0 <= 0;
                wreq_dely1 <= 0;
                done_dely0 <= 0;
                done_dely1 <= 0;
            end
        else
            begin
                addr_dely0 <= addr;
                addr_dely1 <= addr_dely0;
                wreq_dely0 <= wreq;
                wreq_dely1 <= wreq_dely0;
                done_dely0 <= done;
                done_dely1 <= done_dely0;
            end
    end
assign done = done_dely1;

Accumulator_Ram #(
    .DATA_WIDTH(DATA_WIDTH),
    .DATA_DEPTH(COLOR_RANGE)
)Inst_accumulatorram(
    .clk(clk),
    .arstn(arstn),
    .write_addr_A(addr_dely1),
    .write_data_A(acculator_out),
    .wvalid_A(wreq_dely1),
    .read_addr_A(raddr),
    .read_data_A(data_out),
    .rvalid_A(raddr_valid),
    .dvalid_A(dout_valid),
    .clear(clear)
);
endmodule









