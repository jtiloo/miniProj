`timescale 1ns / 1ps


module CLOCK(
input clk, rst,
output enable
    );
reg[26:0] ctr;

always @(posedge clk or posedge rst)
begin 

if(rst)
begin
    ctr <= 27'd0;
   
end
else begin
if(ctr==27'd99999999) begin

ctr <= 27'd0;
end
else begin

    ctr <= ctr + 1;
end
end
end

assign enable = (ctr == 27'd99999999) && !rst;
    
endmodule
