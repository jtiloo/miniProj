`timescale 1ns / 1ps

module UART_RX(
    input clk, rst, rx,
    output reg[7:0] rx_data,
    output rx_done 
    );
    
localparam IDLE = 3'd0;
localparam START = 3'd1;
localparam DATA = 3'd2;
localparam STOP = 3'd3;
localparam DONE = 3'd4;

    reg rx_meta;
    reg rx_sync;
    
    reg[2:0] state;
    reg[2:0] next_state;
    
    reg[9:0] baud_ctr;
    reg[2:0] bit_ctr;
    
    //state register
    always @(posedge clk or posedge rst)
    begin 
    if(rst)
        state<=IDLE;
    else
        state <= next_state;
    end
    
    //next state logic
    always @(*)
    begin 
        next_state = state;
        
        case(state)
            IDLE : begin    
            if(rx_sync)
                next_state = IDLE;
            else
                next_state = START;
            
            end
            
            START : begin
            if(baud_ctr==10'd433) begin
                if(!rx_sync)
                    next_state = DATA;
                else begin 
                    next_state = IDLE;
                    end
            end    
            end
            
            DATA : begin
            if(baud_ctr == 10'd867 && bit_ctr == 3'b111)
                next_state = STOP;
            end
            
            STOP : begin
            if(baud_ctr==10'd867) begin
                if(rx_sync)
                    next_state = DONE;
            else next_state = IDLE;
            end
            end
            
            DONE : begin
            
            next_state = IDLE;
            
            end   
            endcase
    end
    
//baud counter logic
always @(posedge clk or posedge rst)
begin 

if(rst)
    baud_ctr <= 10'd0;
else if(state==START) begin
    if(baud_ctr == 10'd433)
        baud_ctr <=10'd0;
    else baud_ctr <= baud_ctr + 1'b1;
end
else if(state==DATA || state==STOP) begin
    if(baud_ctr == 10'd867)
        baud_ctr <=10'd0;
    else baud_ctr <= baud_ctr + 1'b1;
end
else
    baud_ctr <= 10'd0;
end

//bit logic
always @(posedge clk or posedge rst) begin

if(rst)
    bit_ctr <= 0;
else begin
    if(state==DATA && baud_ctr==867) begin
        if(bit_ctr < 3'b111)
            bit_ctr <= bit_ctr + 1'b1;
        else bit_ctr<=0;
        end
end
end

//storing bits in rx_data
always @(posedge clk or posedge rst) begin
    if(rst)
        rx_data <= 8'b0;
    else begin
    if(state==DATA && baud_ctr==10'd867)
        rx_data[bit_ctr] <= rx_sync;
    end
end

//logic for 2-FF synchronizer to reduce risk of metastability when receiving the data.
always @(posedge clk or posedge rst) begin
if(rst) begin
    rx_meta <= 1'b1;
    rx_sync <= 1'b1;
 end else begin 
    rx_meta <= rx;
    rx_sync <= rx_meta;
    end
end

assign rx_done = (state == DONE);
    
endmodule
