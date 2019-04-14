`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/02/05 07:14:21
// Design Name: 
// Module Name: non_delay_integrator
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


module non_delay_integrator(
    input clk,
    input rst_n,
    input [35:0] xin,
    output [35:0] sum,
    input fs_enb
    );
    
    reg [35:0] delay;
    //wire [35:0] fs_sum;    
    assign sum = delay + xin;
    
        
    always@(posedge clk, negedge rst_n)
        if(~rst_n)
            delay <= 1'b0;
       else if(fs_enb)
            delay <= sum;
            
endmodule
