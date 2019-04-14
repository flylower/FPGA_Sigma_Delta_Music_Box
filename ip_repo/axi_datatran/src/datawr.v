`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/03/12 21:02:40
// Design Name: 
// Module Name: datawr
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


module datawr(
    input clk,
    input rst_n,
    output [3:0] we_wr,
    output en_wr,
    output reg [11:0] addr_rd_o
    );
    
    reg [4:0] counter;
    assign we_wr = 4'hF;
    assign en_wr = 1'b1;
    
    always @( posedge clk )
        begin
          if ( rst_n == 1'b0 )
            counter <= 1'b0;
          else if(counter == 5'd19)
            counter <= 1'b0;
          else
            counter <= counter + 1'b1;
       end     
        
     always @( posedge clk )
       begin
         if (rst_n == 1'b0 )
            addr_rd_o <=  1'b0;
         else if(counter == 10'd19)
            addr_rd_o <= addr_rd_o + 1'b1;
       end
    
endmodule
