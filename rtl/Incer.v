module Incer #(
    parameter DATA_WIDTH = 8
)
(clk,arstn,din,dout,mode);
localparam INC_STATE = 1'b1;
localparam ADD_STATE = 1'b0;

input clk;
input arstn;
input mode;
input [DATA_WIDTH-1:0]din;
output [DATA_WIDTH-1:0]dout;

reg [DATA_WIDTH-1:0]counter;
reg state;

always@(posedge clk or negedge arstn)
    begin
        if(~arstn)
            begin
                state <= ADD_STATE;
                counter <= 0;
            end
        else
            begin
                case(state)
                        ADD_STATE:
                            begin
                                if(mode == 1'b1)
                                    begin
                                        state <= INC_STATE;
                                        counter <= din + 2'd2;
                                    end
                                 else
                                    begin
                                        state <= state;
                                        counter <= din + 1'b1;
                                    end
                            end
                        INC_STATE:
                            begin
                                if(mode == 1'b0)
                                    begin
                                        state <= ADD_STATE;
                                        counter <= 0;
                                    end
                                else
                                    begin
                                        state <= state;
                                        counter <= counter + 1'b1;
                                    end
                            end
                endcase
            end
    end

endmodule
