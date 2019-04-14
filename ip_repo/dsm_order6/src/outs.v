`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/02/04 12:06:28
// Design Name: 
// Module Name: outs
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


module outs(
	input clk, 
	input rst_n,
	input fs_enb,
    input [35:0] xout,
    output [35:0] outa1,
    output [35:0] outa2,
    output [35:0] outa3,
    output [35:0] outa4,
    output [35:0] outa5,
    output [35:0] outa6,
    output reg [3:0] outsig
    );
    
    wire [3:0] us_outsig;
    wire [19:0] us_outgain;
    wire [35:0] us_outa1;
    wire [35:0] us_outa2;
    wire [35:0] us_outa3;
    wire [35:0] us_outa4;
    wire [35:0] us_outa5;
    wire [35:0] us_outa6;
    
    parameter A1 = 32'd250;
    parameter A2 = 32'd486;
    parameter A3 = 32'd795;
    parameter A4 = 32'd1030;
    parameter A5 = 32'd2027;
    parameter A6 = 32'd2589;
    
    always@(posedge clk, negedge rst_n)
		if(~rst_n)
			outsig = 1'b0;
		else if(fs_enb)
			outsig= (xout[35:31]+1'b1)>>1'b1;
			
    assign us_outsig = outsig[3]?(~(outsig-1'b1)):outsig;
    assign us_outgain = {us_outsig, 16'b0};
    
    assign us_outa1 = us_outgain * A1;
    assign outa1 = outsig[3]?us_outa1:(~us_outa1+1'b1);
    
    assign us_outa2 = us_outgain * A2;
    assign outa2 = outsig[3]?us_outa2:(~us_outa2+1'b1);
    
    assign us_outa3 = us_outgain * A3;
    assign outa3 = outsig[3]?us_outa3:(~us_outa3+1'b1);
    
    assign us_outa4 = us_outgain * A4;
    assign outa4 = outsig[3]?us_outa4:(~us_outa4+1'b1);
    
    assign us_outa5 = us_outgain * A5;
    assign outa5 = outsig[3]?us_outa5:(~us_outa5+1'b1);
    
    assign us_outa6 = us_outgain * A6;
    assign outa6 = outsig[3]?us_outa6:(~us_outa6+1'b1);
    
endmodule
