`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/02/05 07:58:19
// Design Name: 
// Module Name: xa
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


module xa
    #(parameter CGAINA = 0)
    (
    input clk,
    input rst_n,
    input fs_enb,
    input [35:0] inpb,
    input [35:0] outa,
    input [35:0] csump,
    input [35:0] gsum,
    output [35:0] csum
    );
    
    wire [35:0] xin;
    wire [35:0] sum;
    
    assign xin = csump + gsum + inpb + outa;
        
    non_delay_integrator d1(
        .clk(clk),
        .rst_n(rst_n),
        .xin(xin),
        .sum(sum),
        .fs_enb(fs_enb)
        );
        
    gain #(.GAIN(CGAINA),.CG(1)) ca(
            .inp(sum),
            .out(csum)
            );
endmodule
