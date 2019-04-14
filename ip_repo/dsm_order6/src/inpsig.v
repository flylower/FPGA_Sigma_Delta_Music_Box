`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/02/05 08:57:18
// Design Name: 
// Module Name: inpsig
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


module inpsig(
    input [15:0] sine,
    output [35:0] inpb1,
    output [35:0] inpb2,
    output [35:0] inpb3,
    output [35:0] inpb4,
    output [35:0] inpb5,
    output [35:0] inpb6
    );
    
     wire[15:0] inpus;
       
     wire[35:0] inpusb1;
        
     parameter B1 = 250 * 14;
       
    assign inpus = sine[15]?(~(sine-1'b1)):sine;
    
    assign inpusb1 = B1 * inpus;
    
    assign inpb1 = sine[15]?(~inpusb1+1'b1):inpusb1;
    assign inpb2 = 1'b0;
    assign inpb3 = 1'b0;
    assign inpb4 = 1'b0;
    assign inpb5 = 1'b0;
    assign inpb6 = 1'b0;
       
endmodule
