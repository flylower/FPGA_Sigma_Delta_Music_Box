`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/02/05 08:34:35
// Design Name: 
// Module Name: fac
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


module fac
    #(parameter CGAINA = 0,
    parameter CGAINB = 0,
    parameter CGAING = 0)(
    input clk,
    input rst_n,
    input fs_enb,
    input [35:0] csump,
    input [35:0] inpba,
    input [35:0] inpbb,
    input [35:0] outaa,
    input [35:0] outab,
    output [35:0] xout
    );
    
    wire [35:0] gsum;
    wire [35:0] csum;
    
    xa #(.CGAINA(CGAINA)) xai
        (
        .clk(clk),
        .rst_n(rst_n),
        .fs_enb(fs_enb),
        .inpb(inpba),
        .outa(outaa),
        .csump(csump),
        .gsum(gsum),
        .csum(csum)
        );
        
     xb #(.CGAINB(CGAINB),.CGAING(CGAING)) xbi
     (
       .clk(clk),
       .rst_n(rst_n),
       .fs_enb(fs_enb),
       .inpb(inpbb),
       .outa(outab),
       .csump(csum),
       .gsum(gsum),
       .csum(xout)
       );
           
endmodule
