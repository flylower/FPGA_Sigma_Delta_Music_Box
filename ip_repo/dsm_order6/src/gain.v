`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/02/05 07:23:10
// Design Name: 
// Module Name: gain
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


module gain
    #(parameter GAIN = 0,
    parameter CG = 0)(//1代表C增益,0代表G增益
    input [35:0] inp,
    output reg [35:0] out
    );
    
    wire [35:0] us_inp;
    wire [63:0] us_ginp;
    wire [63:0] ginp;
    wire [35:0] r_ginp;
    
    assign us_inp = inp[35]?(~(inp-1'b1)):inp;
    assign us_ginp = us_inp * GAIN;
    assign ginp = inp[35]?(~us_ginp+1'b1):us_ginp;
    assign r_ginp = ginp[51:16];
 
    always@(*)
    begin
        if(CG)
        begin
           out = r_ginp;
        end
        else
        begin
            out = r_ginp[35]?(~(r_ginp-1'b1)):(~r_ginp+1'b1);
        end
        
    end
        
    //assign ginp = inp[35]?(~inp+1'b1):inp;
    //assign r_ginp = rec?us_ginp >> 16:us_ginp; 
    //assign out = r_ginp;
        
endmodule
