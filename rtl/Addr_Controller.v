module Addr_Controller #(
    parameter ADDRESS_WIDTH = 8,
    parameter COLOR_RANGE = 256
)(clk,arstn,start,done,addr,addr_valid,wreq);

input clk;
input arstn;
input start;
output done;
output [ADDRESS_WIDTH-1:0]addr;
output wreq;
output addr_valid;

reg done_reg;
reg [ADDRESS_WIDTH-1:0]addr_reg;
reg wreq_reg;
reg working;
reg addr_valid_reg;
assign done = done_reg;
assign addr = addr_reg;
assign wreq = wreq_reg;
assign addr_valid = addr_valid_reg;

always@(posedge clk or negedge arstn)
    begin
        if(~arstn)
            working <= 0;
        else
            begin
                if(start)
                    working <= 1'b1;
                else if(done)
                    working <= 1'b0;
            end 
    end

always@(posedge clk or negedge arstn)
    begin
        if(~arstn)
            done_reg <= 0;
        else
            begin
                if(addr_reg == COLOR_RANGE - 1'b1)
                    done_reg <= 1'b1;
                else if(start)
                    done_reg <= 1'b0;
            end
    end

always@(posedge clk or negedge arstn)
    begin
        if(~arstn)
            begin
                addr_reg <= 0;
                wreq_reg <= 0;
                addr_valid_reg <= 0;
            end
        else
            begin
                if(working & (~done))
                    begin
                        addr_reg <= addr_reg + 1'b1;
                        wreq_reg <= 1'b1;
                        addr_valid_reg <= 1'b1;
                    end
                else
                    begin
                        addr_reg <= 0;
                        wreq_reg <= 1'b0;
                        addr_valid_reg <= 1'b0;
                    end
            end
    end
endmodule













