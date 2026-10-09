`timescale 1ns / 1ps

module LFSR
(
input clk, rst, enable,
input[3:0] seed,
output[3:0] Q
);

reg[3:0] lfsr_reg;
wire taps;
    
//flip flop
always@(posedge clk or posedge rst) begin
 
if(rst)
    lfsr_reg <= seed;
else begin
if(enable) begin
    lfsr_reg <= {taps, lfsr_reg[3:1]};
end
end
end

assign Q = lfsr_reg;
assign taps = lfsr_reg[1] ^ lfsr_reg[0];

endmodule
