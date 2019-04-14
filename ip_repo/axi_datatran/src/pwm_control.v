`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/03/15 10:17:06
// Design Name: 
// Module Name: pwm_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pwm_control(
    input clk,
    input globalresetn,
    output pwm_o,
    input [3:0] outsig
    );
    
    wire [3:0] outsig_t;
    reg [4:0] counter;
    //reg [9:0]counter_1;
    
    assign outsig_t = outsig + 4'd8;
    assign pwm_o = outsig_t>counter?1:0;
    
    always@(posedge  clk)
    begin
        if(globalresetn == 1'b0)
        begin
            counter <= 1'b0;
        end
        else if(counter == 5'd19)
            counter <= 1'b0;
        else
            counter = counter + 'b1; 
     end
                
endmodule
