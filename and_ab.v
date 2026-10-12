module and_ab (
input wire a,
input wire b,
output wire y);

//intentionally missing the semicolon to test hook
assign y = a & b; //now we put it to show that it works!

endmodule
