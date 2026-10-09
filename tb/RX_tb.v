`timescale 1ns / 1ps

module RX_tb();

reg clock, reset, therx;

wire[7:0] the_data;
wire rx_isdone;
reg[7:0] tx_byte;

integer i;

//instance of module
UART_RX dut(.clk(clock), .rst(reset), .rx(therx) ,.rx_data(the_data), .rx_done(rx_isdone));  

//clk -> 10ns (100MHz) 
initial clock = 0;
always begin 
#5 clock = ~clock;
end

//actual sim
initial begin
reset = 1;
therx=1;

#20 reset = 0;

//full byte we're simualting that's being sent to the transmitter
tx_byte = 8'b01110111;

//set rx = 0 (HIGH *active lo) to start tranmission. this
//is the start bit
therx = 0;
#8680;

//loop thru each position from lsb->msb to transmit each bit at a time. 
for(i=0; i<8; i=i+1) begin
    therx = tx_byte[i];
    #8680;
end

//stop bit to end the transmission.  
therx = 1;
#8680;

#100;
$finish;
end

endmodule


