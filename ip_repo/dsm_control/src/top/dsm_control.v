`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/03/07 07:51:41
// Design Name: 
// Module Name: top
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


module dsm_control(
    input clk,
    input rst_n,
    input signed [15:0] inpsig,
    output signed [15:0] outsig,
    output ce_out,
    output enb_cic8,
    
    output signed [15:0] In1,
    output signed [15:0] In2,
    output signed[15:0] Out1,
    output signed[15:0] Out2,
    
    output enb_hbf1,
    output enb_hbf2
    );
    
//    wire signed [15:0] In1;
//    wire signed [15:0] In2;
//    wire signed[15:0] Out1;
//    wire signed[15:0] Out2;
    
//    wire enb_hbf1;
//    wire enb_hbf2;
    wire reset = rst_n;
    
    insert_value i1(
        .clk(clk),
        .rst_n(reset),
        .inpsig(inpsig),
        .In1(In1),
        .In2(In2),
        .Out1(Out1),
        .enb_hbf1(enb_hbf1),
        .enb_hbf2(enb_hbf2),
        .enb_cic8(enb_cic8)
        );
    filter  f1(
        .clk(clk),
        .clk_enable(enb_hbf1),
        .reset(reset),
        .filter_in(In1),
        .filter_out(Out1)
        );
        
   hbf2  h1(
        .clk(clk),
        .clk_enable(enb_hbf2),
        .reset(reset),
        .filter_in(In2),
        .filter_out(Out2)
        );
        
   cic8 c1(
        .clk(clk),
        .clk_enable(enb_cic8),
        .reset(rst_n),
        .filter_in(Out2),
        .filter_out(outsig),
        .ce_out(ce_out)
        );
                        
endmodule
