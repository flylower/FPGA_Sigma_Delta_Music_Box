`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/02/05 07:14:21
// Design Name: 
// Module Name: delay_integrator
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


module delay_integrator(
    input clk,
    input rst_n,
    input fs_enb,
    input [35:0] xin,
    output reg [35:0] sum
    );
    
    wire [35:0] delay;
    
    assign delay = sum + xin;
    
    always@(posedge clk, negedge rst_n)
        if(~rst_n)
            sum <= 1'b0;
       else if(fs_enb)
            sum <= delay;
            
endmodule
