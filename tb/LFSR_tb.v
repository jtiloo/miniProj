`timescale 1ns / 1ps
module LFSR_tb;

reg clock, reset, en;
reg[3:0] the_seed;
wire[3:0] theQ;


LFSR dut(.clk(clock), .rst(reset), .enable(en), .seed(the_seed), .Q(theQ));


initial clock = 0;
always begin 
#10 clock = ~clock;
end

initial begin
 the_seed = 4'b1010;
reset = 1;

#15 reset = 0;

#320 $finish;
end
endmodule
