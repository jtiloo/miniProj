`timescale 1ns / 1ps

module UART_TX(
    input clk, rst, tx_start,
    input[7:0] tx_data,
    output tx_done,
    output reg tx
    );
    
localparam IDLE = 3'd0;
localparam START = 3'd1;
localparam DATA = 3'd2;
localparam STOP = 3'd3;
localparam DONE = 3'd4;

    reg[2:0] state;
    reg[2:0] next_state;
    
    reg[9:0] baud_ctr;
    reg[2:0] bit_ctr;
    
    reg[7:0] data_reg;
    
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
            if(tx_start)
                next_state = START;
            else
                next_state = IDLE;
            
            end
            
            START : begin
            if(baud_ctr==10'd867) 
                    next_state = DATA;
            end
            
            DATA : begin
            if(baud_ctr == 10'd867 && bit_ctr == 3'b111)
                next_state = STOP;
            end
            
            STOP : begin
            if(baud_ctr==10'd867)
                    next_state = DONE;
           
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
    if(baud_ctr == 10'd867)
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

//store 8-bit byte before transmission
always @(posedge clk or posedge rst) begin
    if(rst)
        data_reg <= 8'b0;
    else begin
        if(state==IDLE && tx_start)
            data_reg <= tx_data;
end
end

//state logic
always @(*) begin
    case(state)
        IDLE : tx=1'b1;
        
        START : tx=1'b0;
        
        DATA : tx = data_reg[bit_ctr];
        
        STOP : tx=1'b1;
        
        DONE: tx=1'b1;
        
        default: tx=1'b1;
    endcase

end

assign tx_done = (state == DONE);
    
endmodule

