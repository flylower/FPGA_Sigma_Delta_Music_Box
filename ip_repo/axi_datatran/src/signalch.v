`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/03/12 17:02:56
// Design Name: 
// Module Name: signalch
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


module signalch(
    input clk,
    input rst_n,
    input [15:0] din,
    output [3:0] we_rd,
    output en_rd,
    output reg fs_enb,
    output reg [10:0] addr_rd,
    output reg [15:0]  ram_rd_out
    //output reg [11:0] addr_o
    );
    
    reg [9:0] counter;
        
    assign we_rd = 4'b0;
    assign en_rd = 1'b1;
    
    //clock period 44.1kHz*640
    always @( posedge clk )
    begin
      if ( rst_n == 1'b0 )
        counter <= 1'b0;
      else if(counter == 10'd639)
        counter <= 1'b0;
      else
        counter <= counter + 1'b1;
   end     
   
   //提供输入地址
   always @( posedge clk )
   begin
      if ( rst_n == 1'b0 )
           addr_rd <=  1'b0;
       else if(counter == 10'd639)
           addr_rd <= addr_rd + 1'b1;
   end
   
   //对输出数据进行整形，保证稳定性相对于输入地址改变后10个时钟内
   always@(posedge clk)
   begin
        if(!rst_n)
            ram_rd_out <= 1'b0;
        else if(counter == 10'd10)
            ram_rd_out <= din;      
   end
   
   //提供输入数据的采样时钟
   always@(posedge clk)
   begin
        if(!rst_n)
            fs_enb <= 1'b0;
        else if(counter == 10'd10)
            fs_enb <= 1'b1;
        else
            fs_enb <= 1'b0;      
   end
        

    
endmodule
